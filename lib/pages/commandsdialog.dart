import 'dart:io';

import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommandsDialog extends StatefulWidget {
  String _deviceID;
  String _vehicleModel;
  String _simPhoneNumber;
  bool _late;

  CommandsDialog(this._deviceID, this._vehicleModel, this._simPhoneNumber, this._late);

  @override
  _CommandsDialogState createState() =>
      _CommandsDialogState(_deviceID, _vehicleModel, _simPhoneNumber, _late);
}

class _CommandsDialogState extends State<CommandsDialog> {
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  String _deviceID;
  String _vehicleModel;
  String _simPhoneNumber;

  //in on tap functions we will verify if last we'll disable some buttons
  bool _late;

  _CommandsDialogState(this._deviceID, this._vehicleModel, this._simPhoneNumber, this._late);

  String translate(key) {
    try {
      return AppLocalizations.of(context).translate(key);
    } catch(e) {
      return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      title: Center(
        child: Text(
          "${_vehicleModel}",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      ),
      children: [
        !_late
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    child: Container(
                      width: 180,
                      child: Center(
                        child: Text(
                          translate("Turn on"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      //change number to _simPhoneNumber
                      _late
                          ? null
                          : await _textDevice(_simPhoneNumber, "turnOn");
                    },
                    color: Colors.green.shade500,
                  ),
                ),
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
        !_late
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    child: Container(
                      width: 180,
                      child: Center(
                        child: Text(
                          translate("Turn off"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      _late
                          ? null
                          : await _textDevice(_simPhoneNumber, "turnOff");
                    },
                    color: Colors.green.shade500,
                  ),
                ),
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Container(
                width: 180,
                child: Center(
                  child: Text(
                    translate("Unblock"),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              onPressed: () async {
                await _textDevice(_simPhoneNumber, "unblock");
              },
              color: Colors.red.shade500,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Container(
                width: 180,
                child: Center(
                  child: Text(
                    translate("Resetting the flush"),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              onPressed: () async {
                await _textDevice(_simPhoneNumber, "flush");
              },
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
        !_late
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    child: Container(
                      width: 180,
                      child: Center(
                        child: Text(
                          translate("HONK"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      _late ? null : await _textDevice(_simPhoneNumber, "honk");
                    },
                    color: Colors.lightBlueAccent.shade700,
                  ),
                ),
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
        !_late
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    child: Container(
                      width: 180,
                      child: Center(
                        child: Text(
                          translate("SMS LOCATION"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      _late
                          ? null
                          : await _textDevice(_simPhoneNumber, "smsLocation");
                    },
                    color: Colors.lightBlueAccent.shade700,
                  ),
                ),
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
      ],
    );
  }

  _textDevice(phoneNumber, command) async {
    /*
      here you can check the operator of the simphonenumber
      and change the body value of APN AND Login based on the operator
    */
    String body = "";

    switch (command) {
      case 'turnOn':
        body = "lex trk setdigout 00";
        break;
      case 'turnOff':
        body = "lex trk setdigout 11";
        break;
      case 'unblock':
        body = "lex trk cpureset";
        break;
      case 'flush':
        body =
            "lex trk flush $_deviceID,internet1.meditel.ma,MEDINET,MEDINET,37.187.149.86,5027,0";
        break;
      case 'honk':
        body = "lex trk setdigout 01 0 2";
        break;
      case 'smsLocation':
        body = "lex trk ggps";
        break;
    }

    //if body contains space change it with %20
    if (Platform.isAndroid) {
      var uri = 'sms:$phoneNumber?body=$body';
      await launch(uri);
    } else if (Platform.isIOS) {
      // iOS
      phoneNumber = phoneNumber.replaceAll('+212', '00');
      var uri = 'sms:$phoneNumber&body=$body';
      await launch(uri);
    }
  }
}
