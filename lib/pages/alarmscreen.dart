import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/models/alarm.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlarmScreen extends StatefulWidget {
  final _vehicleModel;
  final _deviceID;

  const AlarmScreen(this._vehicleModel, this._deviceID);

  @override
  _AlarmScreenState createState() =>
      _AlarmScreenState(this._vehicleModel, this._deviceID);
}

class _AlarmScreenState extends State<AlarmScreen> {
  final _vehicleModel;
  final _deviceID;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _AlarmScreenState(this._vehicleModel, this._deviceID);

  final _formKey = GlobalKey<FormState>();
  final _speedController = TextEditingController();
  final _tempMinController = TextEditingController();
  final _tempMaxController = TextEditingController();

  final _prefs = EncryptedSharedPreferences();

  Alarm alarm;


  @override
  void initState() {
    super.initState();
  }

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
                  "Alarms",
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
        body: FutureBuilder(
          future: _getDeviceAlarmSettings(),
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.data.message,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[200]))),
                      child: TextFormField(
                        controller: _speedController,
                        decoration: InputDecoration(
                            labelText: "speed",
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            hintText: "speed",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                        onChanged: (context) {
                          _formKey.currentState.validate();
                        },
                        // validator: (String value) {},
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.startUp,
                      onChanged: (bool newValue) async {
                        setState(() {
                          print(newValue);
                          alarm.startUp = newValue;
                          print(alarm.startUp);
                        });
                      },
                      title: Text(
                        'Start Up',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.battery,
                      onChanged: (bool newValue) async {
                        setState(() {
                          alarm.battery = newValue;
                        });
                      },
                      title: Text(
                        'Me notifier si la véhicule a demarré',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.disconnect,
                      onChanged: (bool newValue) async {
                        setState(() {
                          alarm.disconnect = newValue;
                        });
                      },
                      title: Text(
                        'Me notifier si la véhicule a demarré',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.bonnet,
                      onChanged: (bool newValue) async {
                        setState(() {
                          alarm.bonnet = newValue;
                        });
                      },
                      title: Text(
                        'Me notifier si la véhicule a demarré',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.towing,
                      onChanged: (bool newValue) async {
                        setState(() {
                          alarm.towing = newValue;
                        });
                      },
                      title: Text(
                        'Me notifier si la véhicule a demarré',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.crash,
                      onChanged: (bool newValue) async {
                        setState(() {
                          alarm.crash = newValue;
                        });
                      },
                      title: Text(
                        'Me notifier si la véhicule a demarré',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.driver,
                      onChanged: (bool newValue) async {
                        setState(() {
                          alarm.driver = newValue;
                        });
                      },
                      title: Text(
                        'Me notifier si la véhicule a demarré',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[200]))),
                      child: TextFormField(
                        controller: _tempMinController,
                        decoration: InputDecoration(
                            labelText: "tempmin",
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            hintText: "tempmin",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                        onChanged: (context) {
                          _formKey.currentState.validate();
                        },
                        // validator: (String value) {},
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[200]))),
                      child: TextFormField(
                        controller: _tempMaxController,
                        decoration: InputDecoration(
                            labelText: "tempmax",
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            hintText: "tempmax",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                        onChanged: (context) {
                          _formKey.currentState.validate();
                        },
                        // validator: (String value) {},
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
    );
  }

  _getDeviceAlarmSettings() async {
    String _userID = await _prefs.getString("userID");
    String _accountID = await _prefs.getString("accountID");
    var alarmJson =
        Alarm.id(accountID: _accountID, userID: _userID, deviceID: _deviceID)
            .toJson();
    return Api.getDeviceAlarmSettings(jsonEncode(alarmJson)).then(
      (value) {
        if(value.responseBody == null) {
          alarm = Alarm.byDefault(accountID: _accountID, userID: _userID, deviceID: _deviceID);
        } else {
          alarm = value.responseBody;
        }
        return value;
      },
    ).catchError(
      (error) => ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: error, type: 'error'),
    );
  }
}
