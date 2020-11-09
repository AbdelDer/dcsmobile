import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/models/Report.dart';
import 'package:flutter/material.dart';

class ReportView extends StatefulWidget {
  final _deviceID;
  final _vehicleModel;
  final _scaffoldKey;

  ReportView(this._scaffoldKey, this._deviceID, this._vehicleModel);

  @override
  _ReportViewState createState() =>
      _ReportViewState(this._scaffoldKey, this._deviceID, this._vehicleModel);
}

class _ReportViewState extends State<ReportView> {
  final _deviceID;
  final _vehicleModel;
  final _scaffoldKey;
  Report _report = Report(
      deviceID: '',
      avgSpeed: 0.0,
      distance: 0.0,
      maxSpeed: 0.0,
      parkingTime: 0.0,
      runningTime: 0.0);

  _ReportViewState(this._scaffoldKey, this._deviceID, this._vehicleModel);

  final double _warningSpeed = 100;

  final _title = 'Rapport';

  int _indexStack = 0;
  var _visible = [true, false, false, false, false];

  StreamSubscription<Report> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = _reportStream(_deviceID).listen((report) {
      setState(() {
        _report = report;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Stream<Report> _reportStream(deviceID) async* {
    var response;
    while (true) {
      await Api.getReport(deviceID).then((r) {
        response = r;
      }).catchError((err) {
        ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
      });
      yield response.responseBody;
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(25.0),
          topRight: const Radius.circular(25.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  roundedContainer("Vitesse maximale",
                      '${_report?.maxSpeed?.roundToDouble()} Km/h', _vehicleModel),
                  roundedContainer("Vitesse moyenne",
                      '${_report?.avgSpeed?.roundToDouble()} Km/h', _vehicleModel),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  roundedContainer("Distance",
                      '${_report?.distance?.roundToDouble()} Km', _vehicleModel),
                  roundedContainer("Temps en marche",
                      '${_report?.runningTimeAsString}', _vehicleModel),
                ],
              ),
            ),
            roundedContainer("Temps en parking",
                '${_report?.parkingTimeAsString}', _vehicleModel),
          ],
        ),
      ),
    );
  }

  Container roundedContainer(subject, value, model) {
    double _heightContainer;
    double _widthContainer;
    double _fontSize;
    var colors = [Colors.deepOrange.shade300, Colors.deepOrange.shade400];
    if (MediaQuery.of(context).orientation == Orientation.portrait &&
        MediaQuery.of(context).size.shortestSide >= 600) {
      _heightContainer = 210;
      _widthContainer = 210;
      _fontSize = 23;
    } else if (MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.shortestSide >= 550) {
      _heightContainer = 210;
      _widthContainer = 210;
      _fontSize = 22;
    } else {
      _heightContainer = 160;
      _widthContainer = 160;
      _fontSize = 16;
    }
    return Container(
      padding: EdgeInsets.all(10),
      height: _heightContainer,
      width: _widthContainer,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors),
        // boxShadow: [
        //   BoxShadow(color: Colors.black, blurRadius: 10.0),
        // ],
        // borderRadius: BorderRadius.circular(60.0),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              subject,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              model,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
