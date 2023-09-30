import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FireBaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImageAndGetURL(File image) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          _storage.ref().child('products/$fileName');

      final UploadTask uploadTask = storageReference.putFile(image);
      final TaskSnapshot storageTaskSnapshot =
          await uploadTask.whenComplete(() => null);

      final String downloadURL = await storageTaskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      return '';
    }
  }
}
