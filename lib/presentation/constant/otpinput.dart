import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pinput/pinput.dart';
class OTPInput extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String> onCompleted;
  final Function(String)? onChanged;
  final Key? key;

  OTPInput({
    this.key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  @override
  OTPInputState createState() => OTPInputState();
}

// Remove the underscore to make this public
class OTPInputState extends State<OTPInput> {
  late FocusNode focusNode;
  late TextEditingController controller;
  late final PinTheme defaultPinTheme = _initDefaultPinTheme();
  late final PinTheme focusedPinTheme = _initFocusedPinTheme();

  PinTheme _initDefaultPinTheme() => PinTheme(
        width: 56,
        height: 56,
        textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(53, 53, 53, 1),
          fontWeight: FontWeight.w600,
        ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          border: Border.all(color: Color.fromRGBO(193, 193, 193, 1)),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  PinTheme _initFocusedPinTheme() => defaultPinTheme.copyDecorationWith(
        border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
        borderRadius: BorderRadius.circular(8),
      );

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    controller = widget.controller!;
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void reset() {
    controller.clear();
    focusNode.requestFocus();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: widget.length,
      focusNode: focusNode,
      controller: controller,
      onCompleted: widget.onCompleted,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      showCursor: true,
      onChanged: widget.onChanged,
    );
  }
}
