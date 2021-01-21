import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
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
                AppLocalizations.of(context).translate("Summary report"),
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
        backgroundColor: Colors.green,
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
              return SizedBox();
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.max,
                  // textDirection: TextDirection.ltr,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Image.asset('assets/report/calendar.png'),
                      tileColor: _cardColor,
                      title: Text(
                        '${AppLocalizations.of(context).translate("From")}: ${_pickedDateTimeStart.year}-${_pickedDateTimeStart.month}-${_pickedDateTimeStart.day} ${_pickedDateTimeStart.hour}:${_pickedDateTimeStart.minute}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        '${AppLocalizations.of(context).translate("To")}: ${_pickedDateTimeEnd.year}-${_pickedDateTimeEnd.month}-${_pickedDateTimeEnd.day} ${_pickedDateTimeEnd.hour}:${_pickedDateTimeEnd.minute}',
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/car.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("Device")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        _vehicleModel,
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/odometer.png'),
                      title: Text(
                        'ODOMETER ${AppLocalizations.of(context).translate("Start")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        snapshot.data.odometerStart.toStringAsFixed(2),
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/odometer.png'),
                      title: Text(
                        'ODOMETER ${AppLocalizations.of(context).translate("End")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        snapshot.data.odometerEnd.toStringAsFixed(2),
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/car.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("Distance")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        snapshot.data.distance.toStringAsFixed(2),
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/speed.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("SPEED MAX")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        snapshot.data.speedMax?.toStringAsFixed(2)??'',
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/speed.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("SPEED AVG")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        snapshot.data.speedAvg?.toStringAsFixed(2)??'',
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/running.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("Running time")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        snapshot.data.runningTime(),
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/stop.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("Stops")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        '${snapshot.data.stops.toStringAsFixed(2)}',
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    ListTile(
                      tileColor: _cardColor,
                      leading: Image.asset('assets/report/parking.png'),
                      title: Text(
                        '${AppLocalizations.of(context).translate("Parked")}',
                        style: TextStyle(fontSize: _fontSize),
                      ),
                      subtitle: Text(
                        '${snapshot.data.parkingTimes}',
                        style:
                            TextStyle(fontSize: _fontSize, color: Colors.black),
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
        'startTime': _pickedDateTimeStart.millisecondsSinceEpoch ~/ 1000,
        'endTime': _pickedDateTimeEnd.millisecondsSinceEpoch ~/ 1000
      });
    } else if (_deviceID == '' && _userID != '') {
      _body = jsonEncode({
        'userID': _userID,
        'startTime': _pickedDateTimeStart.millisecondsSinceEpoch ~/ 1000,
        'endTime': _pickedDateTimeEnd.millisecondsSinceEpoch ~/ 1000
      });
    } else {
      _body = jsonEncode({
        'deviceID': _deviceID,
        'startTime': _pickedDateTimeStart.millisecondsSinceEpoch ~/ 1000,
        'endTime': _pickedDateTimeEnd.millisecondsSinceEpoch ~/ 1000
      });
    }

    return Api.getSummaryReport(_body).then(
      (value) {
        return value.responseBody[0];
      },
    ).catchError(
        (error) => _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        ),
      // (error) => ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: error, type: 'error'),
    );
  }
}
