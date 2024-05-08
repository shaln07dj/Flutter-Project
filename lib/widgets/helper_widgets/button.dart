import 'package:flutter/material.dart';
import 'package:pauzible_app/widgets/helper_widgets/text_widget.dart';

class Button extends StatelessWidget {
  Function(bool val)? onHover;
  Function? onClick;
  final String displayText;
  final FontWeight fontWeight;
  final double fontSize;
  final TextAlign textAlign;
  final Color fontBackgroundColor;
  bool? hoverEffect;
  BorderStyle borderStyle;
  double? borderWidth;
  double? hoveredBorderWidth;
  BorderStyle? isHoveredBorderStyle;
  bool center;
  Color? fontColor;
  Button(
      {super.key,
      required this.displayText,
      this.fontWeight = FontWeight.normal,
      this.fontSize = 12,
      this.textAlign = TextAlign.left,
      this.fontColor,
      this.fontBackgroundColor = Colors.transparent,
      this.onClick,
      this.onHover,
      this.hoverEffect,
      this.borderWidth,
      this.hoveredBorderWidth,
      this.center = false,
      this.borderStyle = BorderStyle.none});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: center == true
          ? Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  side: MaterialStateBorderSide.resolveWith(
                    (states) {
                      // Border color and thickness when not hovered
                      if (states.contains(MaterialState.hovered)) {
                        return const BorderSide(width: 0.5);
                      }
                      // Border color and thickness when hovered
                      return const BorderSide(
                          style: BorderStyle.none,
                          width: 0.0); // Adjust as needed
                    },
                  ),
                ),
                onPressed: () {
                  onClick!();
                },
                child: TextWidget(
                  displayText: displayText,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            )
          : ElevatedButton(
              style: hoverEffect == true
                  ? ButtonStyle(
                      side: MaterialStateBorderSide.resolveWith(
                        (states) {
                          // Border color and thickness when not hovered
                          if (states.contains(MaterialState.hovered)) {
                            return BorderSide(width: hoveredBorderWidth!);
                          }
                          // Border color and thickness when hovered
                          return BorderSide(
                              style: borderStyle,
                              width: 0.0); // Adjust as needed
                        },
                      ),
                    )
                  : const ButtonStyle(),
              onPressed: () {
                onClick!();
              },
              child: TextWidget(
                displayText: displayText,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
    );
  }
}
