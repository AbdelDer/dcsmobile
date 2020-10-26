import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/models/summaryreport.dart';
import 'package:dcsmobile/widgets/devicecard.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class SpeedReportScreen extends StatefulWidget {
  final String _deviceID;
  final double _speed;
  final String _vehicleModel;

  const SpeedReportScreen(this._deviceID, this._speed, this._vehicleModel);

  @override
  _SpeedReportScreenState createState() =>
      _SpeedReportScreenState(this._deviceID, this._speed, this._vehicleModel);
}

class _SpeedReportScreenState extends State<SpeedReportScreen> {
  final String _deviceID;
  final double _speed;
  final String _vehicleModel;

  double _modelFontSize = 24;
  double _addressFontSize = 18;
  double _detailsFontSize = 16;

  EncryptedSharedPreferences _encryptedSharedPreferences =
      EncryptedSharedPreferences();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _SpeedReportScreenState(this._deviceID, this._speed, this._vehicleModel);

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
              return Center(
                child: Text(snapshot.error),
              );
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            child: ExpansionTile(
                              initiallyExpanded: false,
                              backgroundColor: Colors.transparent,
                              onExpansionChanged: (val) async {

                              },
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    snapshot.data[index].iconPath(),
                                    width: 30,
                                  ),
                                  Text(snapshot.data[index].activityTime(), style: TextStyle(fontSize: 15),),
                                ],
                              ),
                              title: Row(children: <Widget>[
                                Icon(Icons.directions_car),
                                Text(
                                  snapshot.data[index].vehicleModel,
                                  style: TextStyle(
                                      fontSize: _modelFontSize, color: Colors.black),
                                )
                              ]),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FutureBuilder(
                                    future: snapshot.data[index].address,
                                    builder: (context, snapshot) {
                                      return Text(
                                        '${snapshot.data}',
                                        style: TextStyle(
                                            color: Colors.lightBlue,
                                            fontSize: _addressFontSize),
                                      );
                                    },
                                  ),
                                  Text(
                                    "${snapshot.data[index].timestampAsString} ${snapshot.data[index].distanceKM} Km/J",
                                    style: TextStyle(fontSize: _detailsFontSize),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.network_wifi,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }),
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
      _body = jsonEncode({'accountID': _accountID, 'speed': _speed});
    } else if (_deviceID == '' && _userID != '') {
      _body = jsonEncode({'userID': _userID, 'speed': _speed});
    } else {
      _body = jsonEncode({'deviceID': _deviceID, 'speed': _speed});
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
