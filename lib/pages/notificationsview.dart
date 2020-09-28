import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text("Notifications"),
        ),
        drawer: FEDrawer(),
        body: Center(
          child: Container(
            child: Text(
              "Aucune Notification",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
