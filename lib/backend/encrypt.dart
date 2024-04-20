import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class Encrypting {
  final String vectorKey;
  final iv = IV.fromBase64('yourVector');
  Encrypting({required this.vectorKey});

  Uint8List encrypterData(String data) {
    final key = Key.fromUtf8(vectorKey);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.bytes;
  }

  String decrypterData(Uint8List data) {
    final key = Key.fromUtf8(vectorKey);
    final decrypter = Encrypter(AES(key));
    final decrypted = decrypter.decrypt(Encrypted(data), iv: iv);
    final plaintext = decrypted.toString();
    return plaintext;
  }
}
