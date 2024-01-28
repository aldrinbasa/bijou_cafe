import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class Notifications {
  final DatabaseReference _newOrderNotifReference;
  final StreamController<bool> _newOrderNotifController;
  final StreamController<Map<String, dynamic>> _orderStatusController;

  Notifications()
      : _newOrderNotifReference =
            FirebaseDatabase.instance.ref().child('newOrderNotif'),
        _newOrderNotifController = StreamController<bool>(),
        _orderStatusController = StreamController<Map<String, dynamic>>();

  Stream<bool> get newOrderNotifStream => _newOrderNotifController.stream;
  Stream<Map<String, dynamic>> get newStatusStream =>
      _orderStatusController.stream;

  void listenToNewOrderNotif() {
    _newOrderNotifReference.onValue.listen((event) {
      bool value = event.snapshot.value as bool;
      _newOrderNotifController.add(value);
    });
  }

  void dispose() {
    _newOrderNotifController.close();
  }

  Future<void> updateNewOrderNotifValue(bool newValue) async {
    try {
      await _newOrderNotifReference.set(newValue);
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> addUserNotif(
      String nodeName, String process, bool notify) async {
    DatabaseReference nodeReference =
        FirebaseDatabase.instance.ref().child(nodeName);

    try {
      await nodeReference.set({
        'process': process,
        'notify': notify,
      });
      // ignore: empty_catches
    } catch (error) {}
  }

  void listenToUserNotif(String nodeName) {
    DatabaseReference userNotifReference =
        FirebaseDatabase.instance.ref().child(nodeName);

    userNotifReference.onValue.listen((event) {
      var data = event.snapshot.value as Map<dynamic, dynamic>;
      _orderStatusController.add(Map<String, dynamic>.from(data));
    });
  }
}
