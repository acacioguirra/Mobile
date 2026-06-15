import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadVideo(File file) async {
    final id = const Uuid().v4();
    final ref = _storage.ref('videos/$id.mp4');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}