import 'package:dcsmobile/widgets/dashboard/roundedcontainer.dart';
import 'package:flutter/material.dart';

import '../../animations/fadeanimation.dart';

class DashboardSecondRow extends StatefulWidget {
  @override
  _DashboardSecondRowState createState() => _DashboardSecondRowState();
}

class _DashboardSecondRowState extends State<DashboardSecondRow> {
  var _indexStack = 0;
  var _visible = [true, false, false];
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
                        maxValue: "140.25 Km",
                        model: "ID128"),
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
                        maxValue: "250 Km/h",
                        model: "ID128"),
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
                        maxValue: "2:50:30",
                        model: "ID256"),
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
      return FadeAnimation(
        2.2,
        Row(
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
                maxValue: "140.25 Km",
                model: "ID128"),
            RoundedContainer(colors: [
              Colors.deepOrange.shade400,
              Colors.deepOrange.shade500,
            ], maxSubject: "Vitesse", maxValue: "250 Km/h", model: "ID128"),
            RoundedContainer(
                colors: [
                  Colors.deepOrange.shade500,
                  Colors.deepOrange.shade600,
                ],
                maxSubject: "T. en Marche",
                maxValue: "2:50:30",
                model: "ID256"),
          ],
        ),
      );
    }
  }
}
