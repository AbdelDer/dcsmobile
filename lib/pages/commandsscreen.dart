import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class CommandsScreen extends StatefulWidget {
  @override
  _CommandsScreenState createState() => _CommandsScreenState();
}

class _CommandsScreenState extends State<CommandsScreen> {
  var _selectedType;
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
  );

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
          "Commandes",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Text("cm 1"),
              onPressed: () {},
              color: Colors.blueAccent,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Text("cm 2"),
              onPressed: () {},
              color: Colors.blue,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Text("cm 3"),
              onPressed: () {},
              color: Colors.greenAccent,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Text("cm 4"),
              onPressed: () {},
              color: Colors.redAccent,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              child: Text("cm 5"),
              onPressed: () {},
              color: Colors.indigoAccent,
            ),
          ),
        ),
      ],
    );
  }
}
