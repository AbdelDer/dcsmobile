import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/models/summaryreport.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class SummaryReportScreen extends StatefulWidget {
  final String _deviceID;
  final String _vehicleModel;
  final DateTime _pickedDateTimeStart;
  final DateTime _pickedDateTimeEnd;

  const SummaryReportScreen(this._deviceID, this._vehicleModel,
      this._pickedDateTimeStart, this._pickedDateTimeEnd);

  @override
  _SummaryReportScreenState createState() => _SummaryReportScreenState(
      this._deviceID,
      this._vehicleModel,
      this._pickedDateTimeStart,
      this._pickedDateTimeEnd);
}

class _SummaryReportScreenState extends State<SummaryReportScreen> {
  final String _deviceID;
  final String _vehicleModel;
  final DateTime _pickedDateTimeStart;
  final DateTime _pickedDateTimeEnd;

  double _fontSize = 15;
  Color _cardColor = Colors.grey.shade200;

  EncryptedSharedPreferences _encryptedSharedPreferences =
      EncryptedSharedPreferences();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _SummaryReportScreenState(this._deviceID, this._vehicleModel,
      this._pickedDateTimeStart, this._pickedDateTimeEnd);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Rapport sommaire",
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                _vehicleModel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            )
          ],
        ),
        backgroundColor: Colors.deepOrange,
      ),
      drawer: FEDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // return ApiShowDialog.dialog(scaffoldKey: _scaffoldKey,
              //     message: snapshot.error,
              //     type: 'error');
              print(snapshot.error);
              return SizedBox();
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'FROM: ${_pickedDateTimeStart.year}-${_pickedDateTimeStart.month}-${_pickedDateTimeStart.day} ${_pickedDateTimeStart.hour}:${_pickedDateTimeStart.minute}',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          'TO: ${_pickedDateTimeEnd.year}-${_pickedDateTimeEnd.month}-${_pickedDateTimeEnd.day} ${_pickedDateTimeEnd.hour}:${_pickedDateTimeEnd.minute}',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'Device',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          _vehicleModel,
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'ODOMETER START',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          snapshot.data.odometerStart.toString(),
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'ODOMETER END',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          snapshot.data.odometerEnd.toString(),
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'DISTANCE',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          snapshot.data.distance.toString(),
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'SPEED MAX',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          snapshot.data.speedMax.toString(),
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'SPEED AVG',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          snapshot.data.speedAvg.toString(),
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'Vehicle Running Time',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          'XXXXXXXXXXXXX',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'STOPS',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          'XXXXXXXXXXXXX',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Container(
                      color: _cardColor,
                      child: ListTile(
                        title: Text(
                          'PARKING',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                        subtitle: Text(
                          'XXXXXXXXXXXXX',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.black),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future _fetchData() async {
    var _body;
    String _userID = await _encryptedSharedPreferences.getString("userID");
    String _accountID =
        await _encryptedSharedPreferences.getString("accountID");
    if (_deviceID == "" && _userID == '') {
      _body = jsonEncode({
        'accountID': _accountID,
      });
    } else if (_deviceID == '' && _userID != '') {
      _body = jsonEncode({
        'userID': _userID,
      });
    } else {
      _body = jsonEncode({
        'deviceID': _deviceID,
      });
    }

    return Api.getSummaryReport(_body).then(
      (value) {
        if (_deviceID == '') {
          return value.data;
        } else {
          return value.data[0];
        }
      },
    ).catchError(
      (error) => ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: error, type: 'error'),
    );
  }
}
