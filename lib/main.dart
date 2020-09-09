import 'package:dcsmobile/pages/notificationview.dart';
import 'package:flutter/material.dart';
import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/dashboard.dart';
import 'package:dcsmobile/pages/introduction.dart';
import 'package:dcsmobile/pages/login.dart';

void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tracking App",
      initialRoute: '/login',
      routes: {
        // When navigating to the "/" rou
        // te, build the FirstScreen widget.
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => Login(),
        '/introduction': (context) => IntroductionPage(),
        '/dashboard': (context) => Dashboard(),
        '/position': (context) => Position("Tous", ""),
        '/notification': (context) => Position("Tous", "Notifications"),
      },
      // home: Home(),
    )
);
