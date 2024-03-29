import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
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
  DateTime _pickedDateTimeEnd = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 59);
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
        title: Text(AppLocalizations.of(context).translate("Report")),
        backgroundColor: Colors.green,
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
                  AppLocalizations.of(context).translate("Report"),
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
                      AppLocalizations.of(context)
                          .translate("Choose the type of report"),
                      style: _textStyle,
                    ),
                    value: _selectedType,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("Consumption report"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context)
                            .translate("Consumption report"),
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context).translate("Maintenance"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context).translate("Maintenance"),
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("Summary report"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context)
                            .translate("Summary report"),
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("Speed report"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context)
                            .translate("Speed report"),
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context).translate("Temperature"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context).translate("Temperature"),
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context).translate("Probe"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context).translate("Probe"),
                      ),
                      DropdownMenuItem(
                        child: Text(
                          AppLocalizations.of(context)
                              .translate("Driver behavior"),
                          style: _textStyle,
                        ),
                        value: AppLocalizations.of(context)
                            .translate("Driver behavior"),
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
                    "${AppLocalizations.of(context).translate("Start date")}:",
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
                    "${AppLocalizations.of(context).translate("End date")}:",
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate("Validate"),
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
                      if (_selectedType == AppLocalizations.of(context).translate("Summary report")) {
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
                      } else if (_selectedType == AppLocalizations.of(context).translate("Speed report")) {
                        TextEditingController _controller =
                            TextEditingController();
                        showDialog(
                            context: this.context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)
                                      .translate("Speed"),
                                  style: TextStyle(color: Colors.blue),
                                ),
                                content: TextFormField(
                                  controller: _controller,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9.]")),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)
                                        .translate("Speed"),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text(AppLocalizations.of(context)
                                          .translate("Validate")),
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
                        // ApiShowDialog.dialog(
                        //     scaffoldKey: _scaffoldKey,
                        //     message:
                        //         'veuillez chosir soit rapport de vitesse soit rapport sommaire',
                        //     type: 'error');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text('$_selectedType'),
                                  backgroundColor: Colors.green,
                                ),
                                drawer: FEDrawer(),
                                body: Container(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        );
                      }
                    } else if (_deviceID == "choisir véhicule(s)") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('veuillez chosir un ou plusieurs véhicules'),
                        ),
                      );
                      // ApiShowDialog.dialog(
                      //     scaffoldKey: _scaffoldKey,
                      //     message: 'veuillez chosir un ou plusieurs véhicules',
                      //     type: 'error');
                    } else if (_selectedType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Veuillez choisir un type de rapport'),
                        ),
                      );
                      // ApiShowDialog.dialog(
                      //     scaffoldKey: _scaffoldKey,
                      //     message: 'veuillez chosir un type de rapport',
                      //     type: 'error');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('date fin doit être supérieure à date début'),
                        ),
                      );
                      // ApiShowDialog.dialog(
                      //     scaffoldKey: _scaffoldKey,
                      //     message:
                      //         'veuillez chosir date fin grande que date début',
                      //     type: 'error');
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
            dialogBackgroundColor: Colors.green,
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
      cancelText: AppLocalizations.of(context).translate("Cancel"),
      confirmText: AppLocalizations.of(context).translate("Validate"),
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
      cancelText: AppLocalizations.of(context).translate("Cancel"),
      confirmText: AppLocalizations.of(context).translate("Validate"),
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
