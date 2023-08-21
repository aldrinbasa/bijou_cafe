import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bijou_cafe/models/user_model.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _userCollection = 'users';

  Future<Map<String, dynamic>?> getUserInfoByUUID(String uid) async {
    try {
      final snapshot = await _firestore
          .collection(_userCollection)
          .where('uid', isEqualTo: uid)
          .get();

      final userDocument = snapshot.docs.first.data();

      return userDocument;
    } catch (e) {
      return null;
    }
  }

  Future<void> createNewUser(UserModel newUser) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection(_userCollection);

      await usersCollection.doc(newUser.uid).set(newUser.toMap());
    } catch (e) {
      return;
    }
  }
}
