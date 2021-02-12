import 'package:dcsmobile/pages/Position.dart';
import 'package:dcsmobile/pages/commandsdialog.dart';
import 'package:dcsmobile/pages/commandsscreen.dart';
import 'package:dcsmobile/pages/notificationsview.dart';
import 'package:dcsmobile/pages/subscriptionscreen.dart';
import 'package:flutter/material.dart';

class DashboardBtn extends StatefulWidget {

  final int quantity;
  final String description;
  final Color color;

  DashboardBtn({@required this.quantity, @required this.description, @required this.color});

  @override
  _DashboardBtnState createState() => _DashboardBtnState(this.quantity, this.description, this.color);
}

class _DashboardBtnState extends State<DashboardBtn> {

  int quantity;
  String description;
  Color color;

  final _height = 110.0;
  final _width = 110.0;


  _DashboardBtnState(this.quantity, this.description, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    size: 25,
                  ),
                  Text(
                    "${quantity ?? 0}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white, fontSize: 11),
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
    );
  }
}
