import 'dart:async';
import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/datepickertimeline/date_picker_timeline.dart';
import 'package:dcsmobile/models/activity.dart';
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
  DateTime _selectedDate = DateTime(2020, 10, 3);
  DateTime _endDate = DateTime(2020, 10, 3, 23, 59, 59);

  StreamController _streamController;
  Stream _stream;

  List<Activity> _timeline = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _ActivityHistoryState(this.deviceID, this.vehicleModel);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _getHistoryTimeLine();
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
                "History",
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
      ),
      drawer: FEDrawer(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            color: Colors.deepOrange,
            height: 100,
            child: DatePicker(
              //TODO: give this datetime DateTime.now().subtract(Duration(days: 30)), instead
              DateTime(2020, 10, 3),
              daysCount: 31,
              width: 60,
              height: 80,
              controller: _controller,
              //TODO: change initialSelectedDateValue to DateTime.now(),
              initialSelectedDate: _selectedDate,
              selectionColor: Colors.orange,
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
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height: 50,
                          color: Colors.grey.shade300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: Colors.greenAccent,
                              ),
                              SvgPicture.asset(
                                'assets/historytimeline/distance.svg',
                                color: Colors.orange,
                              ),
                              SvgPicture.asset(
                                'assets/historytimeline/parking.svg',
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height - 230,
                          child: ListView.builder(
                              // physics: NeverScrollableScrollPhysics(),
                              // shrinkWrap: true,
                              itemCount: _timeline.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          _timeline[index].startTimeAsString,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        _timeline[index].activity == "running"
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Icon(
                                                  Icons.directions_car,
                                                  color: Colors.greenAccent,
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: SvgPicture.asset(
                                                  'assets/historytimeline/parking.svg',
                                                  color: Colors.blue,
                                                ),
                                              ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: SvgPicture.asset(
                                            'assets/historytimeline/clock.svg',
                                            color: Colors.red,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            '${_timeline[index].activityTimeAsString}',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        _timeline[index].activity == "running"
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset(
                                                  'assets/historytimeline/distance.svg',
                                                  color: Colors.orange,
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                        _timeline[index].activity == "running"
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  '${_timeline[index].distanceKM}',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                        _timeline[index].activity == "running"
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset(
                                                  'assets/historytimeline/speedometer.svg',
                                                  color: Colors.orange,
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                        _timeline[index].activity == "running"
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Text(
                                                  '${_timeline[index].avgSpeed}',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                                width: 0,
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error),
                  );
                } else {
                  return SizedBox(
                    height: 0,
                    width: 0,
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
      "startTime": (_selectedDate.millisecondsSinceEpoch / 1000).toString(),
      "endTime": (_endDate.millisecondsSinceEpoch / 1000).toString()
    });
    Api.getHistoryTimeLine(body).then((value) {
      // _timeline = [];
      if (value.status == Status.COMPLETED) {
        for (int i = 0; i < value.responseBody.length; i++) {
          var engineOnTime = value.responseBody[i].startTime;
          var engineOffTime = value.responseBody[i].endTime;
          if (value.responseBody.length == 1) {
            _timeline.add(Activity(
                engineOnTime,
                engineOffTime,
                value.responseBody[i].avgSpeed,
                value.responseBody[i].distanceKM,
                "running"));
            if (DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                .hour !=
                0 ||
                DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                    .minute !=
                    59) {
              _timeline.add(Activity.parking(
                  _selectedDate.millisecondsSinceEpoch / 1000,
                  engineOnTime,
                  "parking"));
            }
            if (engineOffTime == _endDate &&
                DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                    .hour <
                    23 ||
                DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                    .minute !=
                    59) {
              _timeline.add(Activity.parking(engineOffTime,
                  _endDate.millisecondsSinceEpoch / 1000, "parking"));
            }
          } else {
            _timeline.add(Activity(
                engineOnTime,
                engineOffTime,
                value.responseBody[i].avgSpeed,
                value.responseBody[i].distanceKM,
                "running"));
            if (i == 0) {
              if (DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                          .hour !=
                      0 ||
                  DateTime.fromMillisecondsSinceEpoch(engineOnTime * 1000)
                          .minute !=
                      59) {
                _timeline.add(Activity.parking(
                    _selectedDate.millisecondsSinceEpoch / 1000,
                    engineOnTime,
                    "parking"));
              }
            } else if (i == value.responseBody.length - 1) {
              if (engineOffTime == _endDate &&
              DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                  .hour <
                  23 ||
                  DateTime.fromMillisecondsSinceEpoch(engineOffTime * 1000)
                      .minute !=
                      59) {
                _timeline.add(Activity.parking(engineOffTime,
                    _endDate.millisecondsSinceEpoch / 1000, "parking"));
              }
            } else if (i > 0 && i < value.responseBody.length - 1) {
              _timeline.add(Activity.parking(engineOffTime,
                  value.responseBody[i + 1].startTime, "parking"));
            }
          }
        }
        _streamController.add(Response.completed(_timeline));
      } else {
        _streamController.add(value);
      }
    }).catchError((error) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
    });
  }
}
