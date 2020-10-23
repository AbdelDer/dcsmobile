import 'dart:io';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommandsDialog extends StatefulWidget {
  String _vehicleModel;
  String _simPhoneNumber;
  bool _late;

  CommandsDialog(this._vehicleModel, this._simPhoneNumber, this._late);

  @override
  _CommandsDialogState createState() =>
      _CommandsDialogState(_vehicleModel, _simPhoneNumber, _late);
}

class _CommandsDialogState extends State<CommandsDialog> {
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  String _vehicleModel;
  String _simPhoneNumber;

  //in on tap functions we will verify if last we'll disable some buttons
  bool _late;

  _CommandsDialogState(this._vehicleModel, this._simPhoneNumber, this._late);

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
          "Commandes: ${_vehicleModel}",
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      ),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 85),
              child: Text(
                _late ? "" : "Allumer",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                //change number to _simPhoneNumber
                _late ? null : await _textDevice(_simPhoneNumber, "turnOn");
              },
              color: Colors.green.shade500,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 85),
              child: Text(
                _late ? "" : "Eteindre",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                _late ? null : await _textDevice(_simPhoneNumber, "turnOff");
              },
              color: Colors.green.shade500,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Text(
                "DÉBLOQUER",
                style: TextStyle(color: Colors.white),
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
              // padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                "RÉINITIALISATION DU FLUSH",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _textDevice(_simPhoneNumber, "flush");
              },
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Text(
                _late ? "" : "KLAXONNER",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                _late ? null : await _textDevice(_simPhoneNumber, "honk");
              },
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text(
                _late ? "" : "SMS LOCATION",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                _late ? null : await _textDevice(_simPhoneNumber, "smsLocation");
              },
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
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

    switch(command) {
      case 'turnOn': body = "lex trk setdigout 00";break;
      case 'turnOff': body = "lex trk setdigout 10";break;
      case 'unblock': body = "lex trk cpureset";break;
      case 'flush': body = "lex trk flush 359633101511090,internet1.meditel.ma,MEDINET,MEDINET,145.239.67.90,5027,0";break;
      case 'honk': body = "lex trk setdigout 01 0 2";break;
      case 'smsLocation': body = "lex trk ggps";break;
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
