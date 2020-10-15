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
  bool _last;

  _CommandsDialogState(this._vehicleModel, this._simPhoneNumber, this._last);

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
                "Allumer",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                //change number to _simPhoneNumber
                await _textDevice(_simPhoneNumber, "Allumer");
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
                "Eteindre",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _textDevice(_simPhoneNumber, "Eteindre");
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
                await _textDevice(_simPhoneNumber, "DÉBLOQUER");
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
                await _textDevice(_simPhoneNumber, "RÉINITIALISATION DU FLUSH");
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
                "KLAXONNER",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _textDevice(_simPhoneNumber, "KLAXONNER");
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
                "SMS LOCATION",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await _textDevice(_simPhoneNumber, "SMS LOCATION");
              },
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
      ],
    );
  }

  _textDevice(phoneNumber, body) async {
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
