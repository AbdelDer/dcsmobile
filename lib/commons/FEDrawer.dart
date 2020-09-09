import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/introduction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FEDrawer extends StatelessWidget {
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
                child:
                Image.asset('assets/images/logo.png')
//                Icon(
//                  Icons.track_changes,
//                  size: 100.0,
//                  color: Colors.white,
//                )
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Tableau de bord'),
              onTap: () => Navigator.of(context).pushNamed("/dashboard"),
            ),
            ListTile(
              leading: Icon(Icons.place),
              title: Text('Position'),
              //NOTE: change this because constructor is changed
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("Tous", "Live"),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Historique'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("Tous", "History"),
                ),
              ),
            ),
//            ListTile(
//              leading: Icon(Icons.group_work),
//              title: Text('Groupe de véhicules'),
//            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Rapport'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("Tous", "Report"),
                ),
              ),
            ),
//            ListTile(
//              leading: Icon(Icons.accessibility_new),
//              title: Text('Commandes'),
//            ),
//            ListTile(
//              leading: Icon(Icons.alarm),
//              title: Text('Alarmes'),
//            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position("Tous", "Notifications"),
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
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false),
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
