import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource src) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: src);

  if (file != null) {
    return await file.readAsBytes();
  }

  if (kDebugMode) {
    print('No Image selected');
  }
}

void showSnackBar(String content, BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.clearSnackBars();
  // messenger.hideCurrentSnackBar();

  messenger.showSnackBar(SnackBar(content: Text(content)));
}
