import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:psychesail/model/places.dart';
import 'package:psychesail/pages/activitymaps.dart';
import 'package:psychesail/pages/call.dart';
import 'package:psychesail/pages/history.dart';
import 'package:psychesail/pages/past_calls.dart';
import 'package:psychesail/pages/monkeybotchatroom.dart';
// import 'package:psychesail/pages/serenitychatroom.dart';
import 'package:psychesail/pages/video_screen.dart';
import 'package:psychesail/utils/local_notifications.dart';
import './pages/onboarding.dart';
import './pages/login.dart';
import './pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import './pages/signup.dart';
import './pages/chatroom.dart';
import './pages/settings.dart';
import 'firebase_options.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
// listen to background changes

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification received in the background");
  }
}

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "918788496148996",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "Serenova",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  Gemini.init(apiKey: 'AIzaSyBVOgf5N_kO5_BdX7lZ-DDCRv7bRzYSOOs');

  await NotificationsFirebase.init();
  await NotificationsFirebase.localNotiInit();
  // background
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
    }
  });

  // foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got message in foreground");
    print(payloadData);

    if (message.notification != null) {
      NotificationsFirebase.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  // terminated
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print("Launched from terminated state");
  }
  ;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const double _globalTextScale = 0.92;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Places(),
      child: MaterialApp(
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: const TextScaler.linear(_globalTextScale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        navigatorObservers: [routeObserver],
        title: 'Serenova',
        initialRoute: '/',
        routes: {
          '/': (context) => const onboarding(),
          '/login': (context) => const Login(),
          '/Signup': (context) => const Signup(),
          '/home': (context) => const home(),
          '/chatroom': (context) => const ChatRoom(),
          '/monkeybot': (context) => MonkeyBotChatRoom(),
          '/settings': (context) => const Setting(),
          '/call_page': (context) => const CallPage(),
          '/progress': (context) => const Progress(),
          '/past-calls': (context) => const PastCallsPage(),
          '/activity-maps': (context) => ActivityMaps(),
          '/video': (context) => VideoSDKQuickStart(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
      ),
    );
  }
}
