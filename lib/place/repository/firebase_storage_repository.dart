import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platzi_trips_app/place/repository/firebase_storage_api.dart';

class FirebaseStorageRepository{

  final _firebaseStorageAPI = FirebaseStorageAPI();

  Future<StorageUploadTask> uploadFile(String path, PickedFile image) => _firebaseStorageAPI.uploadFile(path, image);
}