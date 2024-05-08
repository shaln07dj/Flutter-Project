import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'session_config.dart';

enum SessionState { startListening, stopListening }

class SessionTimeoutManager extends StatefulWidget {
  final SessionConfig _sessionConfig;
  final Widget child;

  final Stream<SessionState>? _sessionStateStream;
  static final listenerKey = GlobalKey();
  static final keyboardListenerKey = GlobalKey();

  final Duration userActivityDebounceDuration;
  const SessionTimeoutManager(
      {required sessionConfig,
      required this.child,
      sessionStateStream,
      this.userActivityDebounceDuration = const Duration(seconds: 1),
      super.key})
      : _sessionConfig = sessionConfig,
        _sessionStateStream = sessionStateStream;

  @override
  _SessionTimeoutManagerState createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager>
    with WidgetsBindingObserver {
  Timer? _appLostFocusTimer;
  Timer? _userInactivityTimer;
  bool _isListensing = false;

  bool _userTapActivityRecordEnabled = true;

  void _closeAllTimers() {
    if (_isListensing == false) {
      return;
    }

    if (_appLostFocusTimer != null) {
      _clearTimeout(_appLostFocusTimer!);
    }

    if (_userInactivityTimer != null) {
      _clearTimeout(_userInactivityTimer!);
    }
    if (mounted) {
      _isListensing = false;
      _userTapActivityRecordEnabled = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget._sessionStateStream == null) {
      _isListensing = true;
    }

    widget._sessionStateStream?.listen((SessionState sessionState) {
      if (sessionState == SessionState.startListening && mounted) {
        _isListensing = true;

        recordEvent();
      } else if (sessionState == SessionState.stopListening) {
        _closeAllTimers();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_isListensing == true &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused)) {
      if (widget._sessionConfig.invalidateSessionForAppLostFocus != null) {
        _appLostFocusTimer ??= _setTimeout(
          () => widget._sessionConfig.pushAppFocusTimeout(),
          duration: widget._sessionConfig.invalidateSessionForAppLostFocus!,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_appLostFocusTimer != null) {
        _clearTimeout(_appLostFocusTimer!);
        _appLostFocusTimer = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget._sessionConfig.invalidateSessionForUserInactivity != null) {
      final GlobalKey combinedListenerKey = GlobalKey();

      return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Listener(
              key: combinedListenerKey,
              onPointerDown: (_) {
                recordEvent();
              },
              onPointerUp: (_) {
                recordEvent();
              },
              onPointerMove: (_) {
                recordEvent();
              },
              onPointerHover: (_) {
                recordEvent();
              },
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (value) {
                  recordEvent();
                },
                child: widget.child,
              ),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }

  void recordEvent() {
    if (!_isListensing) {
      return;
    }

    if (_userTapActivityRecordEnabled &&
        widget._sessionConfig.invalidateSessionForUserInactivity != null) {
      _userInactivityTimer?.cancel();
      _userInactivityTimer = _setTimeout(
        () => widget._sessionConfig.pushUserInactivityTimeout(),
        duration: widget._sessionConfig.invalidateSessionForUserInactivity!,
      );

      /// lock the button for next [userActivityDebounceDuration] duration
      if (mounted) {
        _userTapActivityRecordEnabled = false;
      }

      // Enable it after [userActivityDebounceDuration] duration

      Timer(
        widget.userActivityDebounceDuration,
        () {
          if (mounted) {
            _userTapActivityRecordEnabled = true;
          }
        },
      );
    }
  }

  Timer _setTimeout(callback, {required Duration duration}) {
    return Timer(duration, callback);
  }

  void _clearTimeout(Timer t) {
    t.cancel();
  }
}
