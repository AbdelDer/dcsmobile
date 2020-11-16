import 'dart:async';
import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/notifications/device.dart';
import 'package:dcsmobile/models/notifications/filter.dart';
import 'package:dcsmobile/widgets/customdatepicker.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _choices = ["vehicles filtering", "events filtering", "new date"];
  var _devices = [];

  DateTime _dateStartChose = DateTime.now();
  TimeOfDay _timeStartChose = TimeOfDay.now();
  DateTime _dateEndChose = DateTime.now();
  TimeOfDay _timeEndChose = TimeOfDay.now();

  var _eventFilters = [
    Filter(filterName: "battery"),
    Filter(filterName: "bonnet"),
    Filter(filterName: "crash"),
    Filter(filterName: "disconnect"),
    Filter(filterName: "driver"),
    Filter(filterName: "maxSpeed"),
    Filter(filterName: "maxTemp"),
    Filter(filterName: "mintTemp"),
    Filter(filterName: "startUp"),
    Filter(filterName: "towing"),
  ];

  StreamController _streamController;
  Stream _stream;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _getNotifications();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text("Notifications"),
          actions: [
            PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 30,
                ),
                color: Colors.white,
                tooltip: 'filter',
                itemBuilder: (BuildContext context) {
                  return _choices.map((choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                onSelected: (choice) async {
                  switch (choice) {
                    case "vehicles filtering":
                      await _vehiclesFilter();
                      break;
                    case "events filtering":
                      _modalEventFilters();
                      break;
                    case "new date":
                      _dateStartChose = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(
                          days: 60,
                        )),
                        lastDate: DateTime.now(),
                        initialDate: _dateStartChose ?? DateTime.now(),
                        helpText: 'Choisir une date',
                        // Can be used as title
                        cancelText: 'annuler',
                        confirmText: 'ok',
                        fieldLabelText: 'date',
                        fieldHintText: 'Mois/Jour/Année',
                      );
                      _timeStartChose = await showTimePicker(
                        context: context,
                        initialTime: _timeStartChose ?? TimeOfDay.now(),
                        helpText: 'Choisir une heure',
                        // Can be used as title
                        cancelText: 'annuler',
                        confirmText: 'ok',
                      );
                      _dateEndChose = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(
                          days: 60,
                        )),
                        lastDate: DateTime.now(),
                        initialDate: _dateEndChose ?? DateTime.now(),
                        helpText: 'Choisir une date',
                        // Can be used as title
                        cancelText: 'annuler',
                        confirmText: 'ok',
                        fieldLabelText: 'date',
                        fieldHintText: 'Mois/Jour/Année',
                      );
                      _timeEndChose = await showTimePicker(
                        context: context,
                        initialTime: _timeEndChose ?? TimeOfDay.now(),
                        helpText: 'Choisir une heure',
                        // Can be used as title
                        cancelText: 'annuler',
                        confirmText: 'ok',
                      );
                      await _getNotifications();
                      break;
                  }
                }),
          ],
        ),
        drawer: FEDrawer(),
        body: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.value.status == Status.ERROR) {
                return Center(
                  child: Container(
                    child: Text(
                      snapshot.data.value.message,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile();
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future _getVehicles() async {
    EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();
    final _params = {
      "accountID": await _preferences.getString("accountID"),
      "userID": await _preferences.getString("userID"),
    };
    await Api.getVehicles(jsonEncode(_params)).then((value) {
      if (value.status == Status.ERROR) {
        throw ('${value.message}');
      } else {
        _devices = value.responseBody;
      }
    });
  }

  _vehiclesFilter() async {
    await _getVehicles().then((value) {
      return showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) => Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //without behavior we'll encounter a problem
                            //when user tap on row blank space
                            behavior: HitTestBehavior.translucent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _devices.elementAt(index).vehicleModel,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.deepOrange,
                                          width:
                                              _devices.elementAt(index).selected
                                                  ? 10
                                                  : 1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _devices.elementAt(index).selected =
                                    !_devices.elementAt(index).selected;
                              });
                            },
                          );
                        }),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.deepOrange)),
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Text(
                          'ok',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.deepOrange,
                        onPressed: () async {
                          await _getNotifications();
                        }),
                  ],
                ),
              ),
            );
          });
    }).catchError((error) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  error,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 22,
                  ),
                ),
              ),
            );
          });
    });
  }

  _modalEventFilters() {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) => Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _eventFilters.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //without behavior we'll encounter a problem
                            //when user tap on row blank space
                            behavior: HitTestBehavior.translucent,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _eventFilters.elementAt(index).filterName,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.deepOrange,
                                          width: _eventFilters
                                                  .elementAt(index)
                                                  .filterValue
                                              ? 10
                                              : 1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _eventFilters.elementAt(index).filterValue =
                                    !_eventFilters.elementAt(index).filterValue;
                              });
                            },
                          );
                        }),
                  ),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.deepOrange)),
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        'ok',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.deepOrange,
                      onPressed: () async {
                        await _getNotifications();
                      }),
                ],
              ),
            ),
          );
        });
  }

  _choicesToJson() {
    _dateStartChose = _dateStartChose ?? DateTime.now();
    _dateStartChose = _dateStartChose ?? DateTime.now();
    _timeStartChose = _timeStartChose ?? TimeOfDay(hour: 0, minute: 0);
    _timeEndChose = _timeEndChose ?? TimeOfDay(hour: 23, minute: 59);

    return jsonEncode({
      'deviceIDs': _devices.where((element) => element.selected).toList(),
      'filters': _eventFilters.toList(),
      'timestamp start': DateTime(
                  _dateStartChose.year,
                  _dateStartChose.month,
                  _dateStartChose.day,
                  _timeStartChose.hour,
                  _timeStartChose.minute)
              .millisecondsSinceEpoch ~/
          1000,
      'timestamp end': DateTime(_dateEndChose.year, _dateEndChose.month,
                  _dateEndChose.day, _timeEndChose.hour, _timeEndChose.minute)
              .millisecondsSinceEpoch ~/
          1000
    });
  }

  _getNotifications() async {
    await Api.getNotifications(_choicesToJson()).then((value) {
      _streamController.add(value);
    }).catchError((error) {
      ApiShowDialog.dialog(
          type: 'error', message: error, scaffoldKey: _scaffoldKey);
    });
  }
}
