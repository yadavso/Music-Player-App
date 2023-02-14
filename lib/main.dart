import 'package:flutter/material.dart';
import 'package:music_player/screens/bottom_navBar.dart';

void main() {
  // AwesomeNotifications().initialize(
  //   null,
  //   [
  //     NotificationChannel(
  //       channelKey: 'basic_channel',
  //       channelName: 'Basic Notifications',
  //       channelDescription: 'Channel Description',
  //       defaultColor: Colors.teal,
  //       importance: NotificationImportance.None,
  //       channelShowBadge: true,
  //     ),
  //   ],
  //   channelGroups: [
  //     NotificationChannelGroup(
  //         channelGroupKey: 'basic_channel_group',
  //         channelGroupName: 'Basic group')
  //   ],
  // );
  // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
  //   if (!isAllowed) {
  //     AwesomeNotifications().requestPermissionToSendNotifications();
  //   }
  // });
  // AwesomeNotifications().setListeners(
  //   onActionReceivedMethod: (ReceivedAction receivedAction) async {
  //     NotificationController.onActionReceivedMethod(receivedAction);
  //   },
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'S Player',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: BottomNavBar(),
    );
  }
}
