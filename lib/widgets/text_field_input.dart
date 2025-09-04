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
    return TextField(
      cursorColor: Colors.blueAccent,
      controller: textEditingController,
      decoration: InputDecoration(
        label: Text(hintText),
        labelStyle: const TextStyle(color: Color(0xff8f8f8f)),
        // hintText: hintText,
        // hintStyle: TextStyle(color: Color(0xff8f8f8f)),
        fillColor: const Color(0xff121212),
        border: OutlineInputBorder(
          borderSide: Divider.createBorderSide(context),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: .6),
            width: 1,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff3b3b3b), width: 1),
        ),
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
