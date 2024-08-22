import 'package:blogs_app/constants/constants.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text, style: TextStyle(color: Constants.bg),),
      backgroundColor: Constants.yellow,
    ),
  );
}
