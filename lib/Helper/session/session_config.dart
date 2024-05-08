import 'dart:async';

enum SessionTimeoutState { appFocusTimeout, userInactivityTimeout }

class SessionConfig {
  final Duration? invalidateSessionForUserInactivity;

  final Duration? invalidateSessionForAppLostFocus;

  SessionConfig({
    this.invalidateSessionForUserInactivity,
    this.invalidateSessionForAppLostFocus,
  });

  final _controller = StreamController<SessionTimeoutState>();

  Stream<SessionTimeoutState> get stream => _controller.stream;

  void pushAppFocusTimeout() {
    _controller.sink.add(SessionTimeoutState.appFocusTimeout);
  }

  void pushUserInactivityTimeout() {
    _controller.sink.add(SessionTimeoutState.userInactivityTimeout);
  }

  void dispose() {
    _controller.close();
  }
}
