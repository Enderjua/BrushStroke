// ignore_for_file: depend_on_referenced_packages

import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class GeneratedImage extends HiveObject {
  @HiveField(0)
  late String prompt;

  @HiveField(1)
  late String imagePath;

}

// Adaptörü ekleyin
class GeneratedImageAdapter extends TypeAdapter<GeneratedImage> {
  @override
  final int typeId = 0;

  @override
  GeneratedImage read(BinaryReader reader) {
    return GeneratedImage()
      ..prompt = reader.readString()
      ..imagePath = reader.readString();

  }

  @override
  void write(BinaryWriter writer, GeneratedImage obj) {
    writer.writeString(obj.prompt);
    writer.writeString(obj.imagePath);

  }
}

Future<Box<GeneratedImage>> addRecord(String prompt, String imagePath) async {
  await Hive.openBox<GeneratedImage>('images');

  final box = Hive.box<GeneratedImage>('images');

  final post = GeneratedImage()
  ..prompt = prompt
  ..imagePath = imagePath;

  box.add(post);
  return box;
}


Future<List<GeneratedImage>> getRecords() async {
  await Hive.openBox<GeneratedImage>('images');

  final box = Hive.box<GeneratedImage>('images');
  final List<GeneratedImage> posts = box.values.toList();
  return posts;
}


