import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;

  const TextFieldInput({
    super.key,
    this.isPass = false,
    required this.textEditingController,
    required this.hintText,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    // final inputBorder = OutlineInputBorder(
    //   borderSide: Divider.createBorderSide(context),
    // );

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        
        hintText: hintText,
        hintStyle: TextStyle(color: Color(0xff8f8f8f)),
        fillColor: Color(0xff121212),
        border: OutlineInputBorder(
          borderSide: Divider.createBorderSide(context),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: .6),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff3b3b3b), width: 1),
        ),
        filled: true,
        contentPadding: EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
