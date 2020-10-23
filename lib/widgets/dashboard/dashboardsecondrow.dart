import 'package:dcsmobile/widgets/dashboard/roundedcontainer.dart';
import 'package:flutter/material.dart';

import '../../animations/fadeanimation.dart';

class DashboardSecondRow extends StatefulWidget {

  final maxSpeed;
  final maxDistance;
  final maxRunningTime;

  DashboardSecondRow({this.maxSpeed, this.maxDistance, this.maxRunningTime});

  @override
  _DashboardSecondRowState createState() => _DashboardSecondRowState(this.maxSpeed, this.maxDistance, this.maxRunningTime);
}

class _DashboardSecondRowState extends State<DashboardSecondRow> {
  var _indexStack = 0;
  var _visible = [true, false, false];

  final maxSpeed;
  final maxDistance;
  final maxRunningTime;

  _DashboardSecondRowState(this.maxSpeed, this.maxDistance, this.maxRunningTime);

  String runningTimeAsString(runningTime) {
    var d = Duration(minutes: runningTime?.toInt());
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 410) {
      return FadeAnimation(
          2.2,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              GestureDetector(
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onTap: () {
                  setState(() {
                    if (_indexStack < 2) {
                      _indexStack++;
                    } else {
                      _indexStack = 0;
                    }
                    if (_indexStack == 0)
                      _visible = [true, false, false];
                    else if (_indexStack == 1)
                      _visible = [false, true, false];
                    else if (_indexStack == 2) _visible = [false, false, true];
                  });
                },
              ),
              IndexedStack(
                index: _indexStack,
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: _visible[0] ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: RoundedContainer(
                        colors: [
                          Colors.deepOrange.shade300,
                          Colors.deepOrange.shade400
                        ],
                        maxSubject: "Kilometrage",
                        maxValue: maxDistance['maxDistance'],
                        model: maxDistance['vehicleModel']),
                  ),
                  AnimatedOpacity(
                    opacity: _visible[1] ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: RoundedContainer(
                        colors: [
                          Colors.deepOrange.shade400,
                          Colors.deepOrange.shade500
                        ],
                        maxSubject: "Vitesse",
                        maxValue: maxSpeed['maxSpeed'],
                        model: maxSpeed['vehicleModel']),
                  ),
                  AnimatedOpacity(
                    opacity: _visible[2] ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: RoundedContainer(
                        colors: [
                          Colors.deepOrange.shade500,
                          Colors.deepOrange.shade600
                        ],
                        maxSubject: "T. en Marche",
                        maxValue: runningTimeAsString(maxRunningTime['maxRunningTime']),
                        model: maxRunningTime['vehicleModel']),
                  ),
                ],
              ),
              GestureDetector(
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                ),
                onTap: () {
                  setState(() {
                    if (_indexStack > 0) {
                      _indexStack--;
                    } else {
                      _indexStack = 2;
                    }
                    if (_indexStack == 0)
                      _visible = [true, false, false];
                    else if (_indexStack == 1)
                      _visible = [false, true, false];
                    else if (_indexStack == 2) _visible = [false, false, true];
                  });
                },
              ),
            ],
          ));
    } else {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            RoundedContainer(
                colors: [
                  Colors.deepOrange.shade300,
                  Colors.deepOrange.shade400,
                ],
                maxSubject: "Kilometrage",
                maxValue: maxDistance['maxDistance'],
                model: maxDistance['vehicleModel']),
            RoundedContainer(colors: [
              Colors.deepOrange.shade400,
              Colors.deepOrange.shade500,
            ], maxSubject: "Vitesse", maxValue: maxSpeed['maxSpeed'],
                model: maxSpeed['vehicleModel']),
            RoundedContainer(
                colors: [
                  Colors.deepOrange.shade500,
                  Colors.deepOrange.shade600,
                ],
                maxSubject: "T. en Marche",
                maxValue: maxRunningTime['maxRunningTime'],
                model: maxRunningTime['vehicleModel']),
          ],
      );
    }
  }
}
