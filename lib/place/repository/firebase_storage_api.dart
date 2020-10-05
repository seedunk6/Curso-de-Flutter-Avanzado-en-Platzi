import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageAPI{
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  Future<StorageUploadTask> uploadFile(String path, PickedFile image) async{
    StorageUploadTask storageUploadTask = _storageReference.child(path).putFile(File(image.path));

    return storageUploadTask;
  }
}