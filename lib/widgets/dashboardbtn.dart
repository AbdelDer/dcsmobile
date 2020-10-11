import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/commandsscreen.dart';
import 'package:dcsmobile/pages/notificationsview.dart';
import 'package:dcsmobile/pages/subscriptionscreen.dart';
import 'package:flutter/material.dart';

class DashboardBtn extends StatefulWidget {

  int quantity;
  String description;
  Color color;

  DashboardBtn({this.quantity, this.description, this.color});

  @override
  _DashboardBtnState createState() => _DashboardBtnState(this.quantity, this.description, this.color);
}

class _DashboardBtnState extends State<DashboardBtn> {

  int quantity;
  String description;
  Color color;

  final _height = 120.0;
  final _width = 120.0;


  _DashboardBtnState(this.quantity, this.description, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        containedInkWell: true,
        splashColor: Colors.black,
        onTap: () {
          if(description == 'En retard') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Position("Tous", "Commands"),
              ),
            );
          }else if(description == 'Renouvellement') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubscriptionScreen(),
              ),
            );
          }else if(description == "Alerte") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsView(),
              ),
            );
          }else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Position(description, "Live"),
                ),
              );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: _width,
                height: _height,
                color: Colors.grey.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.place,
                        color: color,
                        size: 30,
                      ),
                      Text(
                        "${quantity ?? 0}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 5,
                width: _width,
                color: color,
              )
            ],
          ),
        ),
      ),
    );
  }
}
