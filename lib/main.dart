import 'dart:io';

import 'package:dcsmobile/pages/commandsscreen.dart';
import 'package:dcsmobile/pages/helpscreen.dart';
import 'package:dcsmobile/pages/notificationsview.dart';
import 'package:dcsmobile/pages/openstreetmap.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:dcsmobile/pages/subscriptionscreen.dart';
import 'package:dcsmobile/pages/vehicleliveposition.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/dashboard.dart';
import 'package:dcsmobile/pages/introduction.dart';
import 'package:dcsmobile/pages/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'lang/app_localizations.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(EnteryPoint());
}

class EnteryPoint extends StatefulWidget {
  const EnteryPoint({
    Key key,
  }) : super(key: key);

  @override
  _EnteryPointState createState() => _EnteryPointState();
}

class _EnteryPointState extends State<EnteryPoint> {
  final EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
  AppLocalizations appLocalizations = AppLocalizations(Locale('en'));

  onLocaleChange(Locale l) {
    setState(() {
      appLocalizations.locale = l;
      appLocalizations.delegate.load(l);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: appLocalizations.locale ?? Locale('en'),
      debugShowCheckedModeBanner: false,
      title: "Tracking App",
      initialRoute: '/login',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.green,
      ),
      // List all of the app's supported locales here
      supportedLocales: [
        Locale('fr'),
        Locale('en'),
      ],
      // These delegates make sure that the localization data for the proper language is loaded
      localizationsDelegates: [
        // THIS CLASS WILL BE ADDED LATER
        // A class which loads the translations from JSON files
        appLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ],
      // Returns a locale which will be used by the app
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      routes: {
        // When navigating to the "/" route,
        // build the FirstScreen widget.
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => Login(
              onLocaleChange: onLocaleChange,
            ),
        '/history': (context) => Position("all", "History"),
        '/introduction': (context) => IntroductionPage(),
        '/dashboard': (context) => Dashboard(routeObserver),
        '/position': (context) => Position("all", "Live"),
        '/group': (context) => Position("all", "Group"),
        '/alarm': (context) =>
            Position("all", AppLocalizations.of(context).translate("Alarms")),
        '/notifications': (context) => NotificationsView(),
        '/help': (context) => HelpScreen("Assistance"),
        '/report': (context) => ReportScreen(),
        '/commands': (context) => CommandsScreen(title: AppLocalizations.of(context).translate("Commands"),),
        '/maintenance': (context) => Position("all", "Maintenance"),
        // '/activityhistory': (context) => ActivityHistory(deviceID: "demo3", vehicleModel: "citroen"),
      },
    );
  }
}

class FEDrawer extends StatefulWidget {
  @override
  _FEDrawerState createState() => _FEDrawerState();
}

class _FEDrawerState extends State<FEDrawer> {
  EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();

  String _username;

  String translate(context, key) {
    return AppLocalizations.of(context).translate(key);
  }

  getUsername() async {
    if (_username == null || _username == '') {
      _username = await _preferences.getString("userID");
      if (_username == null || _username == '') {
        _username = await _preferences.getString("accountID");
      }
    }
    return _username;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      child: Center(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white70,
                ),
                child: Stack(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(child: Image.asset('assets/images/logo.png')),
                    Container(
                      child: FutureBuilder(
                        future: getUsername(),
                        builder: (context, snapshot) {
                          return Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${translate(context, 'Logged as')} ${snapshot.data}',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
//                Icon(
//                  Icons.track_changes,
//                  size: 100.0,
//                  color: Colors.white,
//                )
                ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('${translate(context, 'Dashboard')}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Dashboard(routeObserver),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.place),
              title: Text('${translate(context, 'Position')}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "Live"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('${translate(context, 'History')}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Position("all", translate(context, "History"));
                  },
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.group_work),
              title: Text('${translate(context, 'Vehicle group')}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenStreetMap.Group(option: "Group"),
                  ),
                );
                /*showDialog(
                  context: context,
                  builder: (__) => Dialog(
                    child: Container(
                      width: 200,
                      height: 100,
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpenStreetMap(option: "Group"),
                                ),
                              );
                            },
                            child: Container(
                              width: 200,
                              child: Center(
                                child: Text(
                                  'OpenStreet Map',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            color: Colors.blueAccent,
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleLivePosition(option: "Group"),
                                ),
                              );
                            },
                            child: Container(
                              width: 200,
                              child: Center(
                                child: Text(
                                  'Google Maps',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            color: Colors.greenAccent.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                );*/
              }
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('${translate(context, 'Report')}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportScreen(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.accessibility_new),
              title: Text('${translate(context, 'Commands')}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommandsScreen(title: AppLocalizations.of(context).translate("Commands"),),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text(translate(context, 'Notifications')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsView(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text(translate(context, 'Alarms')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "Alarms"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text(translate(context, 'Radar')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(translate(context, 'Radar')),
                      backgroundColor: Colors.green,
                    ),
                    drawer: FEDrawer(),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text(translate(context, 'Maintenance')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "Maintenance"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text(translate(context, 'Subscription')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionScreen(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.live_help),
              title: Text(translate(context, 'Help')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpScreen(translate(context, 'Help')),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text(translate(context, 'Guide')),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntroductionPage(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(translate(context, 'Logout')),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false),
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text(translate(context, 'Close')),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
