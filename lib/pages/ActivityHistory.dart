import 'dart:async';
import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/datepickertimeline/date_picker_timeline.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/activity.dart';
import 'package:dcsmobile/pages/vehicleliveposition.dart';
import 'package:dcsmobile/pages/openstreetmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivityHistory extends StatefulWidget {
  final String deviceID;
  final String vehicleModel;

  const ActivityHistory({Key key, this.deviceID, this.vehicleModel})
      : super(key: key);

  @override
  _ActivityHistoryState createState() =>
      _ActivityHistoryState(deviceID, vehicleModel);
}

class _ActivityHistoryState extends State<ActivityHistory> {
  final String deviceID;
  final String vehicleModel;

  DatePickerController _controller = DatePickerController();
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  StreamController _streamController;
  Stream _stream;

  List<Activity> _timeline;

  // these variables for summary statistics in the first row;
  // NB parking time will be Duration(hours: 24) - _runningTime
  double _sumDistance;
  Duration _runningTime;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _ActivityHistoryState(this.deviceID, this.vehicleModel);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.jumpToSelection();
      _getHistoryTimeLine();
    });
  }

  String translate(key) {
    return AppLocalizations.of(context).translate(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                translate('History'),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                vehicleModel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.green.shade900,
            ),
            onPressed: () => Navigator.of(context).canPop()
                ? Navigator.of(context).pop()
                : null,
          ),
        ],
      ),
      drawer: FEDrawer(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            color: Colors.green,
            height: 100,
            child: DatePicker(
              DateTime.now().subtract(Duration(days: 30)),
              daysCount: 31,
              width: 60,
              height: 80,
              controller: _controller,
              initialSelectedDate: DateTime.now(),
              selectionColor: Colors.green,
              selectedTextColor: Colors.white,
              onDateChange: (date) {
                if (_selectedDate != date) {
                  setState(() {
                    _selectedDate = date;
                    _endDate = DateTime(_selectedDate.year, _selectedDate.month,
                        _selectedDate.day, 23, 59, 59);
                    _getHistoryTimeLine();
                  });
                }
              },
              //fr_FR, en_US, ar_AR
              locale: 'en_US',
            ),
          ),
          StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.status == Status.ERROR) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 3),
                      child: Text(
                        snapshot.data.message,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return OpenStreetMap.History(
                                      deviceID: this.deviceID,
                                      option: "History",
                                      startTime: _selectedDate
                                              .millisecondsSinceEpoch ~/
                                          1000,
                                      endTime:
                                          _endDate.millisecondsSinceEpoch ~/
                                              1000,
                                    );
                                  },
                                ),
                              );
                              /*showDialog(
                                context: context,
                                builder: (__) => Dialog(
                                  child: Container(
                                    width: 200,
                                    height: 100,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RaisedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return VehicleLivePosition
                                                      .History(
                                                    deviceID: this.deviceID,
                                                    option: "History",
                                                    startTime: _selectedDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                    endTime: _endDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 200,
                                            child: Center(
                                              child: Text(
                                                'OpenStreet Map',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          color: Colors.blueAccent,
                                        ),
                                        RaisedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return VehicleLivePosition
                                                      .History(
                                                    deviceID: this.deviceID,
                                                    option: "History",
                                                    startTime: _selectedDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                    endTime: _endDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 200,
                                            child: Center(
                                              child: Text(
                                                'Google Maps',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          color: Colors.greenAccent.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );*/
                            },
                            child: Container(
                              height: 50,
                              color: Colors.grey.shade300,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 30,
                                    color: Colors.greenAccent.shade400,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      Activity.printDuration(_runningTime),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: VerticalDivider(
                                      endIndent: 10,
                                      indent: 10,
                                      thickness: 2,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: SvgPicture.asset(
                                      'assets/historytimeline/distance.svg',
                                      height: 30,
                                      width: 30,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '$_sumDistance KM',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: VerticalDivider(
                                      endIndent: 10,
                                      indent: 10,
                                      thickness: 2,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: SvgPicture.asset(
                                      'assets/historytimeline/parking.svg',
                                      height: 30,
                                      width: 30,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      Activity.printDuration(
                                          Duration(hours: 24) - _runningTime),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _timeline.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return OpenStreetMap.History(
                                              deviceID: this.deviceID,
                                              option: "History",
                                              startTime: _timeline[index]
                                                  .startTime
                                                  .toInt(),
                                              endTime: _timeline[index]
                                                  .endTime
                                                  .toInt(),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Card(
                                      child: ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              _timeline[index]
                                                  .startTimeAsString,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
                                            ),
                                            _timeline[index].activity ==
                                                    "running"
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Icon(
                                                      Icons.directions_car,
                                                      color: Colors
                                                          .greenAccent.shade400,
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: SvgPicture.asset(
                                                      'assets/historytimeline/parking.svg',
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: SvgPicture.asset(
                                                'assets/historytimeline/clock.svg',
                                                color: Colors.red,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                '${_timeline[index].activityTimeAsString}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            _timeline[index].activity ==
                                                    "running"
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SvgPicture.asset(
                                                      'assets/historytimeline/distance.svg',
                                                      color: Colors.green,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  ),
                                            _timeline[index].activity ==
                                                    "running"
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      '${_timeline[index].distanceKM} Km',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  ),
                                            _timeline[index].activity ==
                                                    "running"
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SvgPicture.asset(
                                                      'assets/historytimeline/speedometer.svg',
                                                      color: Colors.green,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  ),
                                            _timeline[index].activity ==
                                                    "running"
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      '${_timeline[index].avgSpeed} Km/h',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                    width: 0,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ],
      ),
    );
  }

  _getHistoryTimeLine() {
    var body = jsonEncode({
      "deviceID": deviceID,
      "startTime": (_selectedDate.millisecondsSinceEpoch ~/ 1000).toString(),
      "endTime": (_endDate.millisecondsSinceEpoch ~/ 1000).toString()
    });
    Api.getHistoryTimeLine(body).then((value) {
      _timeline = [];
      if (value.status == Status.COMPLETED) {
        _runningTime = Duration();
        _sumDistance = 0;

        for (int i = 0; i < value.responseBody.length; i++) {
          _runningTime += value.responseBody[i].activityTimeAsDuration;
          _sumDistance += value.responseBody[i].distanceKM ?? 0;

          var engineOnTime = value.responseBody[i].startTime;
          var engineOffTime = value.responseBody[i].endTime;
          if (value.responseBody.length == 1) {
            if (DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000).hour !=
                    0 ||
                DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                        .minute !=
                    0) {
              _timeline.add(Activity.parking(
                  _selectedDate.millisecondsSinceEpoch / 1000,
                  engineOnTime - 1,
                  "parking"));
            }
            _timeline.add(Activity(
                engineOnTime,
                engineOffTime,
                value.responseBody[i].avgSpeed,
                value.responseBody[i].distanceKM,
                "running"));

            if (engineOffTime != _endDate &&
                (DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                            .hour <
                        23 ||
                    DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                            .minute !=
                        59)) {
              _timeline.add(Activity.parking(engineOffTime + 1,
                  _endDate.millisecondsSinceEpoch / 1000, "parking"));
            }
          } else {
            if (i == 0) {
              if (DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                          .hour !=
                      0 ||
                  DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                          .minute !=
                      0) {
                _timeline.add(Activity.parking(
                    _selectedDate.millisecondsSinceEpoch / 1000,
                    engineOnTime - 1,
                    "parking"));
              }
              _timeline.add(Activity(
                  engineOnTime,
                  engineOffTime,
                  value.responseBody[i].avgSpeed,
                  value.responseBody[i].distanceKM,
                  "running"));

              _timeline.add(Activity.parking(engineOffTime + 1,
                  value.responseBody[i + 1].startTime - 1, "parking"));
            } else if (i == value.responseBody.length - 1) {
              _timeline.add(Activity(
                  engineOnTime,
                  engineOffTime,
                  value.responseBody[i].avgSpeed,
                  value.responseBody[i].distanceKM,
                  "running"));

              if (engineOffTime != _endDate &&
                  (DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                              .hour <
                          23 ||
                      DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                              .minute !=
                          59)) {
                _timeline.add(Activity.parking(engineOffTime + 1,
                    _endDate.millisecondsSinceEpoch / 1000, "parking"));
              }
            } else if (i > 0 && i < value.responseBody.length - 1) {
              _timeline.add(Activity(
                  engineOnTime,
                  engineOffTime,
                  value.responseBody[i].avgSpeed,
                  value.responseBody[i].distanceKM,
                  "running"));

              _timeline.add(Activity.parking(engineOffTime + 1,
                  value.responseBody[i + 1].startTime - 1, "parking"));
            }
          }
        }
        _streamController.add(Response.completed(_timeline));
      } else {
        _streamController.add(value);
      }
    }).catchError((error) {
      //   ApiShowDialog.dialog(
      //       scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
      // });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
