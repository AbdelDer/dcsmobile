import 'package:dcsmobile/pages/ActivityHistory.dart';
import 'package:dcsmobile/pages/commandsscreen.dart';
import 'package:dcsmobile/pages/helpscreen.dart';
import 'package:dcsmobile/pages/notificationsview.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:dcsmobile/pages/subscriptionscreen.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/dashboard.dart';
import 'package:dcsmobile/pages/introduction.dart';
import 'package:dcsmobile/pages/login.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Tracking App",
        initialRoute: '/maintenance',
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          primaryColor: Colors.deepOrange,
          accentColor: Colors.deepOrange,
        ),
        routes: {
          // When navigating to the "/" rou
          // te, build the FirstScreen widget.
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/login': (context) => Login(),
          '/history': (context) => Position("all", "History"),
          '/introduction': (context) => IntroductionPage(),
          '/dashboard': (context) => Dashboard(routeObserver),
          '/position': (context) => Position("all", "Live"),
          '/alarm': (context) => Position("all", "Alarms"),
          '/notifications': (context) => NotificationsView(),
          '/help': (context) => HelpScreen("Assistance"),
          '/report': (context) => ReportScreen(),
          '/commands': (context) => CommandsScreen(),
          '/maintenance': (context) => Position("all", "Maintenance"),
          // '/activityhistory': (context) => ActivityHistory(deviceID: "demo3", vehicleModel: "citroen"),
        },
        // home: Home(),
      )
  );
}

class FEDrawer extends StatelessWidget {
  EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();
  String _username;

  getUsername() async {
    if(_username == null || _username == '') {
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
                              'Logged as ${snapshot.data}',
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
              title: Text('Tableau de bord'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Dashboard(routeObserver),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.place),
              title: Text('Position'),
              //NOTE: change this because constructor is changed
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "Live"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Historique'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "History"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.group_work),
              title: Text('Groupe de véhicules'),
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Rapport'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportScreen(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.accessibility_new),
              title: Text('Commandes'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommandsScreen(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text('Notifications'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsView(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Alarms'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "Alarms"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text('Radar'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text("Radar"),
                      backgroundColor: Colors.deepOrange,
                    ),
                    drawer: FEDrawer(),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('Maintenance'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("all", "Maintenance"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text('Abonnement'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionScreen(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.live_help),
              title: Text('Assistance'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpScreen("Assistance"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('guide'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntroductionPage(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false),
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Fermer'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}