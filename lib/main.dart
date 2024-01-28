import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bijou_cafe/constants/colors.dart';
import 'package:bijou_cafe/init/splash/splash_screen.dart';
import 'package:bijou_cafe/utils/notification_controller.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bijou_cafe/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelGroupKey: "basic_channel_group",
            channelKey: "basic_channel",
            channelName: "Basic Notification",
            channelDescription: "Basic Notifications Channel")
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: "basic_channel_group",
            channelGroupName: "Basic Group")
      ],
      debug: true);

  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.storage.request();
  await Permission.camera.request();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayed,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        primaryColor: primaryColor,
        secondaryHeaderColor: secondaryColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
