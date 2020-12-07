import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/alarm.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String translate(key) {
    try {
      return AppLocalizations.of(context).translate(key);
    } finally {
      return key;
    }
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
                translate("Alarms"),
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
      body: FutureBuilder(
          future: _getDeviceAlarmSettings(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.directions_car,
                        color: Colors.black,
                        size: 40,
                      ),
                      title: Text(
                        translate("Device"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        _deviceID,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Image.asset('assets/alarm/speed.png'),
                      title: Text(
                        translate("Speed"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Container(
                        width: 80,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[200]))),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _speedController,
                          //this will allow the user to insert only numbers with "."
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          // validator: (String value) {},
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: Image.asset('assets/alarm/startup.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.startUp,
                      onChanged: (bool value) {
                        setState(() {
                          alarm.startUp = value;
                        });
                      },
                      title: Text(
                        translate('Start Up'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary:
                          Image.asset('assets/alarm/battery&disconnect.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.battery,
                      onChanged: (bool newValue) {
                        setState(() {
                          alarm.battery = newValue;
                        });
                      },
                      title: Text(
                        translate('Battery'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary:
                          Image.asset('assets/alarm/battery&disconnect.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.disconnect,
                      onChanged: (bool newValue) {
                        setState(() {
                          alarm.disconnect = newValue;
                        });
                      },
                      title: Text(
                        translate('Disconnect'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: Image.asset('assets/alarm/bonnet.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.bonnet,
                      onChanged: (bool newValue) {
                        setState(() {
                          alarm.bonnet = newValue;
                        });
                      },
                      title: Text(
                        translate('Bonnet'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: Image.asset('assets/alarm/towing.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.towing,
                      onChanged: (bool newValue) {
                        setState(() {
                          alarm.towing = newValue;
                        });
                      },
                      title: Text(
                        translate('Towing'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: Image.asset('assets/alarm/crash.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.crash,
                      onChanged: (bool newValue) {
                        setState(() {
                          alarm.crash = newValue;
                        });
                      },
                      title: Text(
                        translate('Crash'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      secondary: Image.asset('assets/alarm/driver.png'),
                      activeColor: Colors.greenAccent,
                      value: alarm.driver,
                      onChanged: (bool newValue) {
                        setState(() {
                          alarm.driver = newValue;
                        });
                      },
                      title: Text(
                        translate('Driver'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Image.asset('assets/alarm/temp.png'),
                      title: Text(
                        translate('MIN Temp'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Container(
                        width: 80,
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[200]))),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _tempMinController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          // validator: (String value) {},
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Image.asset('assets/alarm/temp.png'),
                      title: Text(
                        translate('MAX Temp'),
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Container(
                        width: 80,
                        height: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[200]))),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _tempMaxController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                          ],
                          // validator: (String value) {},
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      child: IconButton(
                        icon: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/alarm/save.png'),
                            Text(
                              translate('Save'),
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async => await _verifyAndSubmit(context),
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
              .toJsonID();

      return Api.getDeviceAlarmSettings(jsonEncode(alarmJson)).then(
        (value) {
          alarm = value.responseBody;
          _queryResponse = value;
          _initFormFields();
          return _queryResponse;
        },
      ).catchError(
        (error) {
          //here if the table does not contain any record we will create an alarm instance with default values
          if (error == '404') {
            print('404');
            _create = true;
            alarm = Alarm.byDefault(
                accountID: _accountID, userID: _userID, deviceID: _deviceID);
            // _initFormFields();
            _queryResponse = Response.completed(alarm);
            print(_queryResponse);
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

  void _verifyAndSubmit(context) async {
    if (_speedController.text != "" &&
        (double.parse(_speedController.text) <= 0 ||
            double.parse(_speedController.text) > 140)) {
      showBottomSheet(
          context: context,
          builder: (context) => Container(
                color: Colors.green,
                child: Center(
                    child: Text(
                  translate('speedErrMsg'),
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )),
                height: 50,
                width: double.infinity,
              ));
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    } else {
      alarm.maxSpeed = _speedController.value.text != ""
          ? double.parse(_speedController.value.text)
          : null;
      alarm.maxTemp = _tempMaxController.value.text != ""
          ? double.parse(_tempMaxController.value.text)
          : null;
      alarm.minTemp = _tempMinController.value.text != ""
          ? double.parse(_tempMinController.value.text)
          : null;
      if (_create) {
        await Api.saveDeviceAlarmSettings(jsonEncode(alarm.toJson()))
            .then((value) async {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(translate("Updated")),
          ));
          await Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        }).catchError((error) {
          ApiShowDialog.dialog(
              scaffoldKey: _scaffoldKey, message: error, type: 'error');
        });
      } else {
        await Api.updateDeviceAlarmSettings(jsonEncode(alarm.toJson()))
            .then((value) async {
          if (value.status == Status.ERROR) {
            ApiShowDialog.dialog(
                scaffoldKey: _scaffoldKey,
                message: value.message,
                type: 'info');
          } else {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(translate("Updated")),
            ));
            await Future.delayed(Duration(seconds: 1), () {
              Navigator.pop(context);
            });
          }
        }).catchError((error) {
          ApiShowDialog.dialog(
              scaffoldKey: _scaffoldKey, message: error, type: 'error');
        });
      }
    }
  }

  void _initFormFields() {
    setState(() {
      _speedController.value =
          TextEditingValue(text: alarm.maxSpeed?.toString() ?? '');
      _tempMinController.value =
          TextEditingValue(text: alarm.minTemp?.toString() ?? '');
      _tempMaxController.value =
          TextEditingValue(text: alarm.maxTemp?.toString() ?? '');
    });
  }

  _successDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Opacity(
              opacity: .8,
              child: Center(
                child: Container(
                  height: 100,
                  width: 200,
                  // color: Colors.white,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: Center(
                      child: Text(
                    translate("Success"),
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.green.shade300,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
          );
        });
  }
}
