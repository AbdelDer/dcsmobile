import 'package:dcsmobile/pages/ActivityHistory.dart';
import 'package:dcsmobile/pages/commandsscreen.dart';
import 'package:dcsmobile/pages/helpscreen.dart';
import 'package:dcsmobile/pages/notificationsview.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:flutter/material.dart';
import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/dashboard.dart';
import 'package:dcsmobile/pages/introduction.dart';
import 'package:dcsmobile/pages/login.dart';

void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tracking App",
      initialRoute: '/history',
      theme: ThemeData(
          primaryColor: Colors.deepOrange,
          accentColor: Colors.deepOrange,
      ),
      routes: {
        // When navigating to the "/" rou
        // te, build the FirstScreen widget.
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => Login(),
        '/history': (context) => Position("Tous", "History"),
        '/introduction': (context) => IntroductionPage(),
        '/dashboard': (context) => Dashboard(),
        '/position': (context) => Position("Tous", "Live"),
        '/alarm': (context) => Position("Tous", "Alarms"),
        '/notifications': (context) => NotificationsView(),
        '/help': (context) => HelpScreen("Assistance"),
        '/report' : (context) => ReportScreen(),
        // '/report' : (context) => SummaryReport(),
        '/commands' : (context) => CommandsScreen(),
        '/activityhistory' : (context) => ActivityHistory(),
      },
      // home: Home(),
    )
);