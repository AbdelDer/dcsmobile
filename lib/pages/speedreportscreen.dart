import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/summaryreport.dart';
import 'package:dcsmobile/widgets/devicecard.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class SpeedReportScreen extends StatefulWidget {
  final String _deviceID;
  final double _speed;
  final String _vehicleModel;
  final DateTime _pickedDateTimeStart;
  final DateTime _pickedDateTimeEnd;

  const SpeedReportScreen(this._deviceID, this._speed, this._vehicleModel,
      this._pickedDateTimeStart, this._pickedDateTimeEnd);

  @override
  _SpeedReportScreenState createState() =>
      _SpeedReportScreenState(this._deviceID, this._speed, this._vehicleModel,
          this._pickedDateTimeStart, this._pickedDateTimeEnd);
}

class _SpeedReportScreenState extends State<SpeedReportScreen> {
  final String _deviceID;
  final double _speed;
  final String _vehicleModel;
  final DateTime _pickedDateTimeStart;
  final DateTime _pickedDateTimeEnd;

  double _modelFontSize = 24;
  double _addressFontSize = 18;
  double _detailsFontSize = 16;

  EncryptedSharedPreferences _encryptedSharedPreferences =
      EncryptedSharedPreferences();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _SpeedReportScreenState(this._deviceID, this._speed, this._vehicleModel,
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
                "Rapport Vitesse",
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
              ApiShowDialog.dialog(
                  scaffoldKey: _scaffoldKey,
                  message: '${snapshot.error}',
                  type: 'error');
            } else if (snapshot.hasData) {
              return SingleChildScrollView(
                  child:
                      DeviceCard(snapshot.data, "speedReport", _scaffoldKey));
            }
            return Center(child: CircularProgressIndicator());
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
        'speed': _speed,
        'startTime': _pickedDateTimeStart.millisecondsSinceEpoch ~/ 1000,
        'endTime': _pickedDateTimeEnd.millisecondsSinceEpoch ~/ 1000
      });
    } else if (_deviceID == '' && _userID != '') {
      _body = jsonEncode({
        'userID': _userID,
        'speed': _speed,
        'startTime': _pickedDateTimeStart.millisecondsSinceEpoch ~/ 1000,
        'endTime': _pickedDateTimeEnd.millisecondsSinceEpoch ~/ 1000
      });
    } else {
      _body = jsonEncode({
        'deviceID': _deviceID,
        'speed': _speed,
        'startTime': _pickedDateTimeStart.millisecondsSinceEpoch ~/ 1000,
        'endTime': _pickedDateTimeEnd.millisecondsSinceEpoch ~/ 1000
      });
    }

    return Api.getSpeedReport(_body).then(
      (value) {
        return value.responseBody;
      },
    ).catchError(
      (error) => ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: error, type: 'error'),
    );
  }
}
