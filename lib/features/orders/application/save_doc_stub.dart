import 'package:flutter/material.dart';

Future<void> saveDoc(String content, String filename, BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('DOC saving is not supported on this platform.')),
  );
}
