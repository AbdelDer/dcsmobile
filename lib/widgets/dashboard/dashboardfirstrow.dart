import 'dart:io';

import 'package:dcsmobile/Api/Api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'transparentcontainer.dart';

class DashboardFirstRow extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final data;

  DashboardFirstRow(this.scaffoldKey, this.data);

  @override
  _DashboardFirstRowState createState() =>
      _DashboardFirstRowState(this.scaffoldKey, this.data);
}

class _DashboardFirstRowState extends State<DashboardFirstRow> {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final data;

  _DashboardFirstRowState(this.scaffoldKey, this.data);

  var _indexStack = 0;
  double _top = 50;
  double _bottom = 10;
  double _left = 50;
  double _right = 50;

  @override
  Widget build(BuildContext context) {
    if ((MediaQuery.of(context).size.width < 550 &&
            MediaQuery.of(context).orientation == Orientation.landscape) ||
        (MediaQuery.of(context).size.width < 400 &&
            MediaQuery.of(context).orientation == Orientation.portrait)) {
      _top = 30;
      _bottom = 10;
      _left = 10;
      _right = 10;
    } else {}

    return Positioned(
      top: _top,
      left: _left,
      bottom: _bottom,
      right: _right,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            setState(() {
              if (_indexStack > 0) {
                _indexStack--;
              } else {
                _indexStack = 2;
              }
            });
          }else if(details.delta.dx < 0) {
            setState(() {
              if (_indexStack < 2) {
                _indexStack++;
              } else {
                _indexStack = 0;
              }
            });
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            GestureDetector(
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onTap: () {
                setState(() {
                  if (_indexStack < 2) {
                    _indexStack++;
                  } else {
                    _indexStack = 0;
                  }
                });
              },
            ),
            IndexedStack(
              index: _indexStack,
              children: <Widget>[
                TransparentContainer(
                    icon: Icons.place, quantity: data['Tous'], description: "Tous"),
                TransparentContainer(
                    icon: Icons.place, quantity: data['En marche'], description: "En marche"),
                TransparentContainer(
                    icon: Icons.place, quantity: data['En parking'], description: "En parking"),
              ],
            ),
            GestureDetector(
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              onTap: () {
                setState(() {
                  if (_indexStack > 0) {
                    _indexStack--;
                  } else {
                    _indexStack = 2;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
