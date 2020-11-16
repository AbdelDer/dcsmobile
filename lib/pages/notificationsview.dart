import 'dart:async';
import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/notifications/filter.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NotificationsView extends StatefulWidget {
  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _choices = ["vehicles filtering", "events filtering", "new date"];
  var _devices = [];
  String _vehicleErrorMsg = "";

  DateTime _dateStartChose = DateTime.now();
  TimeOfDay _timeStartChose = TimeOfDay(hour: 0, minute: 0);
  DateTime _dateEndChose = DateTime.now();
  TimeOfDay _timeEndChose = TimeOfDay(hour: 23, minute: 59);

  var _eventFilters = [
    Filter(filterName: "battery", filterAbbreviation: "BA"),
    Filter(filterName: "bonnet", filterAbbreviation: "BO"),
    Filter(filterName: "crash", filterAbbreviation: "CR"),
    Filter(filterName: "disconnect", filterAbbreviation: "DI"),
    Filter(filterName: "driver", filterAbbreviation: "DR"),
    Filter(filterName: "speed", filterAbbreviation: "SP"),
    Filter(filterName: "maxTemp", filterAbbreviation: "TMAX"),
    Filter(filterName: "mintTemp", filterAbbreviation: "TMIN"),
    Filter(filterName: "startUp", filterAbbreviation: "SU"),
    Filter(filterName: "towing", filterAbbreviation: "TO"),
  ];

  StreamController _streamController;
  Stream _stream;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _getVehicles('init').then((value) => _getNotifications());
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
              if (snapshot.data.status == Status.ERROR) {
                return Center(
                  child: Container(
                    child: Text(
                      snapshot.data.message,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.responseBody.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      initiallyExpanded: false,
                      children: <Widget>[
                        _childrenWidgets(
                            snapshot.data.responseBody[index].deviceID,
                            snapshot.data.responseBody[index].timestamp)
                      ],
                      backgroundColor: Colors.transparent,
                      // onExpansionChanged: (value) {
                      //   if (value) {}
                      // },
                      leading: Image.asset(
                        snapshot.data.responseBody[index].getAssetPath(),
                        color: Colors.black,
                      ),
                      title: Text(
                        '${snapshot.data.responseBody[index].vehicleModel}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${snapshot.data.responseBody[index].message}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueAccent,
                                ),
                              )),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${snapshot.data.responseBody[index]
                                  .timestampAsString}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.map_outlined,
                        color: Colors.black,
                      ),
                    );
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

  Future _getVehicles(state) async {
    EncryptedSharedPreferences _preferences = EncryptedSharedPreferences();
    final _params = {
      "accountID": await _preferences.getString("accountID"),
      "userID": await _preferences.getString("userID"),
    };
    await Api.getVehicles(jsonEncode(_params)).then((value) {
      if (value.status == Status.ERROR) {
        _vehicleErrorMsg = value.message;
      } else {
        if (_vehicleErrorMsg != "") _vehicleErrorMsg = "";
        _devices = value.responseBody;
        if (state != 'init') _vehiclesFilter();
      }
    });
  }

  _vehiclesFilter() async {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext context) {
          return _vehicleErrorMsg == ""
              ? StatefulBuilder(
            builder: (context, setState) =>
                Container(
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
                                        _devices
                                            .elementAt(index)
                                            .vehicleModel,
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
                                            width: _devices
                                                .elementAt(index)
                                                .selected
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
                                  _devices
                                      .elementAt(index)
                                      .selected =
                                  !_devices
                                      .elementAt(index)
                                      .selected;
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
          )
              : Container(
            color: Colors.white,
            child: Text(
              _vehicleErrorMsg,
              style: TextStyle(fontSize: 22),
            ),
          );
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
            builder: (context, setState) =>
                Container(
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
                                          _eventFilters
                                              .elementAt(index)
                                              .filterName,
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
                                    _eventFilters
                                        .elementAt(index)
                                        .filterValue =
                                    !_eventFilters
                                        .elementAt(index)
                                        .filterValue;
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
                            print(_choicesToJson());
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
      'filters': _eventFilters.where((element) => element.filterValue).toList(),
      'timestampStart': DateTime(
          _dateStartChose.year,
          _dateStartChose.month,
          _dateStartChose.day,
          _timeStartChose.hour,
          _timeStartChose.minute)
          .millisecondsSinceEpoch ~/
          1000,
      'timestampEnd': DateTime(_dateEndChose.year, _dateEndChose.month,
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

  _getPositionDetails(deviceID, timestamp) async {
    return await Api.getPositionByTimestampAndDeviceID(
        jsonEncode({"deviceID": deviceID, "timestamp": timestamp}))
        .catchError((error) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: error, type: 'error');
      throw (error);
    });
  }

  _childrenWidgets(deviceID, timestamp) {
    return FutureBuilder(
        future: _getPositionDetails(deviceID, timestamp),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.status == Status.ERROR) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Text(snapshot.data.message),
                ),
              );
            } else {
              var data = snapshot.data.responseBody;
              return Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(snapshot.data.responseBody.latitude,
                          snapshot.data.responseBody.longitude),
                      zoom: 17),
                  zoomControlsEnabled: false,
                  markers: Set.of([
                    Marker(
                        markerId:
                        MarkerId('${data.timestamp}'),
                        position: LatLng(data.latitude,
                            data.longitude),
                        infoWindow: InfoWindow(
                            snippet: "Speed: ${data.speedKPH} Km/h more...",
                            title: "${data.vehicleModel}",
                            onTap: () {
                              showDialog(
                                  context: _scaffoldKey.currentContext,
                                  builder: (context) {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: MediaQuery.of(context).size.height / 2,
                                        width: MediaQuery.of(context).size.width / 1.5,
                                        color: Colors.white,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Center(
                                                  child: Text(
                                                    "${data.vehicleModel}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                thickness: 3,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "speed: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${data.speedKPH} km/h",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "time: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    data.timestampAsString,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "latitude: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${data.latitude}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "longitude: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${data.longitude}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "oil level: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${data.oilLevel} L",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "status: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text("en marche", style: TextStyle(fontSize: 16, decoration: TextDecoration.none, color: Colors.deepOrange),),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "battery: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${data.batteryVolts} V",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "engine temp: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Text(
                                                    "${data.engineTemp} °C",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.deepOrange),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Signal: ",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        decoration: TextDecoration.none, color: Colors.black),
                                                  ),
                                                  Icon(
                                                    Icons.signal_wifi_4_bar_outlined,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            })
                    ),
                  ]),
                  mapType: MapType.hybrid,
                  onMapCreated: (GoogleMapController googleMapController) {},
                ),
              );
            }
          } else {
            return SizedBox(
              height: 0,
              width: 0,
            );
          }
        });
  }
}
