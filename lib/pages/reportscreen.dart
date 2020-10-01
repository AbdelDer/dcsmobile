import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  var _selectedType;
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
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
          "Rapport",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: DropdownButton(
              onChanged: (Value) {
                setState(() {
                  _selectedType = Value;
                });
              },
              hint: Text(
                "Choisissez le type du rapport",
                style: _textStyle,
              ),
              value: _selectedType,
              items: [
                DropdownMenuItem(
                  child: Text(
                    "Rapport de consommation",
                    style: _textStyle,
                  ),
                  value: "Rapport de consommation",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Maintenance",
                    style: _textStyle,
                  ),
                  value: "Maintenance",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Rapport sommaire",
                    style: _textStyle,
                  ),
                  value: "Rapport sommaire",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Rapport de vitesse",
                    style: _textStyle,
                  ),
                  value: "Rapport de vitesse",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Température",
                    style: _textStyle,
                  ),
                  value: "Température",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Probe",
                    style: _textStyle,
                  ),
                  value: "Probe",
                ),
                DropdownMenuItem(
                  child: Text(
                    "Comportement du conducteur",
                    style: _textStyle,
                  ),
                  value: "Comportement du conducteur",
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Date début:",
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(
            child: GestureDetector(
              onTap: () async {
                _pickDateTime("start");
              },
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_pickedDateTimeStart.year}-${_pickedDateTimeStart.month}-${_pickedDateTimeStart.day} ${_pickedDateTimeStart.hour}:${_pickedDateTimeStart.minute}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Date fin:",
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await _pickDateTime("end");
                },
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_pickedDateTimeEnd.year}-${_pickedDateTimeEnd.month}-${_pickedDateTimeEnd.day} ${_pickedDateTimeEnd.hour}:${_pickedDateTimeEnd.minute}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ]),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 20,
          ),
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                // gradient: LinearGradient(
                //     begin: Alignment.topRight,
                //     end: Alignment.bottomLeft,
                //     colors: [Colors.deepOrange, Colors.orange]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              height: 45,
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: Center(
                child: Text(
                  "Valider",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  _pickDateTime(startOrEnd) async {
    DateTime pickedDate;
    TimeOfDay time;
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      pickedDate = date;
    }
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      time = t;
    }
    setState(() {
      if (startOrEnd == "start") {
        _pickedDateTimeStart = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, time.hour, time.minute);
      } else {
        _pickedDateTimeEnd = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, time.hour, time.minute);
      }
    });
  }
}
