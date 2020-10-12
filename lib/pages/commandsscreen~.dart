import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class CommandsScreenDeprecated extends StatefulWidget {
  String _vehicleModel;

  CommandsScreenDeprecated(this._vehicleModel);

  @override
  _CommandsScreenDeprecatedState createState() => _CommandsScreenDeprecatedState(_vehicleModel);
}

class _CommandsScreenDeprecatedState extends State<CommandsScreenDeprecated> {
  var _selectedType;
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

  String _vehicleModel;


  String get vehicleModel => _vehicleModel;

  _CommandsScreenDeprecatedState(this._vehicleModel);

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
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text("Allumer / éteindre", style: TextStyle(color: Colors.white),),
              onPressed: () {},
              color: Colors.green.shade500,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Text("DÉBLOQUER", style: TextStyle(color: Colors.white),),
              onPressed: () {},
              color: Colors.red.shade500,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              // padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text("RÉINITIALISATION DU FLUSH", style: TextStyle(color: Colors.white),),
              onPressed: () {},
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Text("KLAXONNER", style: TextStyle(color: Colors.white),),
              onPressed: () {},
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Text("SMS LOCATION", style: TextStyle(color: Colors.white),),
              onPressed: () {},
              color: Colors.lightBlueAccent.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
