import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/pages/Report/summaryreport.dart';
import 'package:dcsmobile/pages/speedreportscreen.dart';
import 'package:dcsmobile/widgets/devicechooser.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportScreen extends StatefulWidget {
  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  DateTime _pickedDateTimeStart = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  DateTime _pickedDateTimeEnd = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);
  var _vehicleModel = "choisir véhicule(s)";
  var _deviceID = "choisir véhicule(s)";
  var _selectedType;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Rapport"),
        backgroundColor: Colors.deepOrange,
      ),
      drawer: FEDrawer(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Text(
                  "Rapport",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                  child: DropdownButton(
                    isExpanded: true,
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
                padding:
                    const EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    var result = await showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                              title: DeviceChooser(_scaffoldKey));
                        });

                    if (result != null) {
                      setState(() {
                        _vehicleModel = result[0];
                        _deviceID = result[1];
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _vehicleModel,
                        style: TextStyle(fontSize: 18),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Date début:",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
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
                          Icon(Icons.arrow_drop_down),
                        ]),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Date fin:",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
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
                            Icon(Icons.arrow_drop_down),
                          ]),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                ),
                child: RaisedButton(
                  color: Colors.deepOrange,
                  child: Text(
                    'Valider',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    if (_pickedDateTimeEnd
                                .difference(_pickedDateTimeStart)
                                .inMilliseconds >
                            0 &&
                        _deviceID != "choisir véhicule(s)" &&
                        _selectedType != null) {
                      if (_selectedType == "Rapport sommaire") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SummaryReportScreen(
                                _deviceID,
                                _vehicleModel,
                                _pickedDateTimeStart,
                                _pickedDateTimeEnd),
                          ),
                        );
                      } else if (_selectedType == "Rapport de vitesse") {
                        TextEditingController _controller =
                            TextEditingController();
                        showDialog(
                            context: this.context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  'vitesse',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                content: TextFormField(
                                  controller: _controller,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'vitesse',
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text('ok'),
                                      onPressed: () {
                                        double _speed =
                                            double.parse(_controller.text);
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SpeedReportScreen(
                                                    _deviceID,
                                                    _speed,
                                                    _vehicleModel,
                                                    _pickedDateTimeStart,
                                                    _pickedDateTimeEnd),
                                          ),
                                        );
                                      })
                                ],
                              );
                            });
                      } else {
                        ApiShowDialog.dialog(
                            scaffoldKey: _scaffoldKey,
                            message:
                                'veuillez chosir soit rapport de vitesse soit rapport sommaire',
                            type: 'error');
                      }
                    } else if (_deviceID == "choisir véhicule(s)") {
                      ApiShowDialog.dialog(
                          scaffoldKey: _scaffoldKey,
                          message: 'veuillez chosir un ou plusieurs véhicules',
                          type: 'error');
                    } else if (_selectedType == null) {
                      ApiShowDialog.dialog(
                          scaffoldKey: _scaffoldKey,
                          message: 'veuillez chosir un type de rapport',
                          type: 'error');
                    } else {
                      ApiShowDialog.dialog(
                          scaffoldKey: _scaffoldKey,
                          message:
                              'veuillez chosir date fin grande que date début',
                          type: 'error');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pickDateTime(startOrEnd) async {
    DateTime pickedDate;
    TimeOfDay time;
    DateTime date = await showDatePicker(
      /*builder: (context, child) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Colors.deepOrange,
            buttonColor: Colors.white
          ),// This will change to light theme.
          child: child,
        );
      },*/
      context: context,
      firstDate: DateTime(DateTime.now().month - 1),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
      helpText: 'Choisir une date',
      // Can be used as title
      cancelText: 'annuler',
      confirmText: 'ok',
      fieldLabelText: 'date',
      fieldHintText: 'Mois/Jour/Année',
    );
    if (date != null) {
      pickedDate = date;
    }
    TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Choisir une heure',
      // Can be used as title
      cancelText: 'annuler',
      confirmText: 'ok',
    );
    if (t != null) {
      time = t;
    }
    setState(() {
      if (pickedDate != null) {
        if (startOrEnd == "start") {
          _pickedDateTimeStart = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, time.hour, time.minute);
        } else {
          _pickedDateTimeEnd = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, time.hour, time.minute);
        }
      }
    });
  }
}
