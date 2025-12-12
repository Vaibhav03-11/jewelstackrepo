import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

Future<void> saveDoc(String content, String filename, BuildContext context) async {
  final blob = html.Blob([content], 'application/msword');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Download started: $filename'),
      backgroundColor: AppColors.success,
    ),
  );
}
