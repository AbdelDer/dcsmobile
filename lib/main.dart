import 'package:dcsmobile/pages/helpscreen.dart';
import 'package:dcsmobile/pages/notificationsview.dart';
import 'package:flutter/material.dart';
import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/dashboard.dart';
import 'package:dcsmobile/pages/introduction.dart';
import 'package:dcsmobile/pages/login.dart';

void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tracking App",
      initialRoute: '/dashboard',
      routes: {
        // When navigating to the "/" rou
        // te, build the FirstScreen widget.
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => Login(),
        '/history': (context) => Position("Tous", "History"),
        '/introduction': (context) => IntroductionPage(),
        '/dashboard': (context) => Dashboard(),
        '/position': (context) => Position("Tous", ""),
        '/alarm': (context) => Position("Tous", "Alarms"),
        '/notifications': (context) => NotificationsView(),
        '/help': (context) => HelpScreen("Assistance"),
        '/report' : (context) => Position("Tous", "Report"),
        '/commands' : (context) => Position("Tous", "Commands"),
      },
      // home: Home(),
    )
);
