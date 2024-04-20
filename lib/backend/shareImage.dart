// ignore: file_names
// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void shareImage(String prompt, String imagePath) async {
    final http.Response response = await http.get(Uri.parse(imagePath));
  final Directory directory = await getTemporaryDirectory();
  final File file = await File('${directory.path}/Image.png').writeAsBytes(response.bodyBytes);
  await Share.shareXFiles(
    [
      XFile(file.path),
    ],
    text: prompt,
  );
}
