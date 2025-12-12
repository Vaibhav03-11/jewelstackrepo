import 'dart:typed_data';
import 'package:flutter/material.dart';

// Fallback when neither IO nor web is available
Future<void> savePdf(Uint8List bytes, String filename, BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('PDF saving is not supported on this platform.')),
  );
}
