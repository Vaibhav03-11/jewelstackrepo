import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/colors.dart';

Future<void> savePdf(Uint8List bytes, String filename, BuildContext context) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(file.path);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('PDF saved to ${file.path}'),
      backgroundColor: AppColors.success,
    ),
  );
}
