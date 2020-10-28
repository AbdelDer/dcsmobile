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

  String _userID;
  String _accountID;

  //this property will allow us to know if user will update a record or create a new one.
  bool _create = false;

  Response _queryResponse;

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
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[200]))),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
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
                        onChanged: (value) {
                          if(value.contains(',')) {
                            setState(() {
                              _speedController.value = TextEditingValue(text: value.replaceAll(',', ''));
                              _speedController.selection = TextSelection.fromPosition(TextPosition(offset: _speedController.text.length));
                            });
                          }
                          _formKey.currentState.validate();
                        },
                        // validator: (String value) {},
                      ),
                    ),
                    SwitchListTile(
                      activeColor: Colors.deepOrangeAccent,
                      value: alarm.startUp,
                      onChanged: (bool value) {
                        setState(() {
                          alarm.startUp = value;
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
                      onChanged: (bool newValue) {
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
                      onChanged: (bool newValue) {
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
                      onChanged: (bool newValue) {
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
                      onChanged: (bool newValue) {
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
                      onChanged: (bool newValue) {
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
                      onChanged: (bool newValue) {
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
                        keyboardType: TextInputType.number,
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
                        onChanged: (value) {
                          if(value.contains(',')) {
                            setState(() {
                              _speedController.value = TextEditingValue(text: value.replaceAll(',', ''));
                              _speedController.selection = TextSelection.fromPosition(TextPosition(offset: _speedController.text.length));
                            });
                          }
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
                        keyboardType: TextInputType.number,
                        controller: _tempMaxController,
                        initialValue: alarm.maxTemp?.toString() ?? '',
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
                        onChanged: (value) {
                          if(value.contains(',')) {
                            setState(() {
                              _speedController.value = TextEditingValue(text: value.replaceAll(',', ''));
                              _speedController.selection = TextSelection.fromPosition(TextPosition(offset: _speedController.text.length));
                            });
                          }
                          _formKey.currentState.validate();
                        },
                        // validator: (String value) {},
                      ),
                    ),
                  ],
                ),
              );
            } else {
              if (snapshot.hasError && snapshot.data.status == Status.ERROR) {
                return Center(
                  child: Text(
                    snapshot.data.message,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    "",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                );
              }
            }
          }),
    );
  }

  Future<Response> _getDeviceAlarmSettings() async {
    //this test because each time the user change value of a boolean field, the method setState will cause
    //a rebuild and this test will avoid the user to call the API each time
    //our method will verify if the first time will do call API else will return the saved response
    if (alarm == null) {
      _userID = await _prefs.getString("userID");
      _accountID = await _prefs.getString("accountID");

      var alarmJson =
          Alarm.id(accountID: _accountID, userID: _userID, deviceID: _deviceID)
              .toJson();

      return Api.getDeviceAlarmSettings(jsonEncode(alarmJson)).then(
        (value) {
          alarm = value.responseBody;
          _queryResponse = value;
          return _queryResponse;
        },
      ).catchError(
        (error) {
          //here if the table does not contain any record we will create an alarm instance with default values
          if (error == '404') {
            _create = true;
            alarm = Alarm.byDefault(
                accountID: _accountID, userID: _userID, deviceID: _deviceID);
            _queryResponse = Response.completed(alarm);
            return _queryResponse;
          } else {
            //if we encounter another problem, for example the user doesn't have internet we'll open dialog
            //with specific message
            ApiShowDialog.dialog(
                scaffoldKey: _scaffoldKey, message: error, type: 'error');
          }
        },
      );
    }
    return _queryResponse;
  }
}
