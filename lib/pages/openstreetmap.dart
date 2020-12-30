import 'dart:async';
import 'dart:io';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/animations/speedometer.dart';
import 'package:dcsmobile/models/EventData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenStreetMap extends StatefulWidget {
  String deviceID;
  final option;
  int startTime;
  int endTime;

  OpenStreetMap({Key key, @required this.deviceID, @required this.option})
      : super(key: key);

  OpenStreetMap.History(
      {@required this.deviceID,
      @required this.option,
      @required this.startTime,
      @required this.endTime});

  OpenStreetMap.Group({@required this.option});

  @override
  _OpenStreetMapState createState() {
    if (option == "History") {
      return _OpenStreetMapState.History(deviceID, option, startTime, endTime);
    } else if (option == "Live") {
      return _OpenStreetMapState(this.deviceID, this.option);
    } else if (option == "Group") {
      return _OpenStreetMapState.Group(this.option);
    }
  }
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  String _deviceID;
  final _option;
  int _startTime;
  int _endTime;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MapController _mapController;
  Position _lastPosition;
  Marker _marker;
  double _speedKPH = 0;
  double _odometer = 0;
  final double _warningSpeed = 100;
  bool _first = true;
  Timer _timer;
  double _dialogTextSize = 16;
  List<Marker> _markers;
  List<EventData> _data;

  // Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();

  _OpenStreetMapState(this._deviceID, this._option);

  _OpenStreetMapState.History(
      this._deviceID, this._option, this._startTime, this._endTime);

  _OpenStreetMapState.Group(this._option);

  @override
  void initState() {
    super.initState();
    _markers = [];
    _data = [];
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _positionDetails();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _positionDetails() async {
    if (_option == "History") {
      Timer.run(() async {
        await Api.getHistory(this._deviceID, this._startTime, this._endTime)
            .then((r) async {
          for (EventData ed in r.responseBody) {
            await Future.delayed(Duration(milliseconds: 1000));
            _setHistory(ed);
          }
        }).catchError((err) {
          ApiShowDialog.dialog(
              scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
        });
      });
    } else if (_option == "Live") {
      _getActualPosition();
      _timer = Timer.periodic(Duration(seconds: 60), (timer) async {
        await _getActualPosition();
      });
    } else if (_option == "Group") {
      _getGroupActualPosition();
      _timer = Timer.periodic(Duration(seconds: 60), (timer) async {
        await _getGroupActualPosition();
      });
    }
  }

  _getActualPosition() async {
    await Api.getActualPosition(this._deviceID).then((r) {
      var data = r.responseBody;
      _markers?.clear();
      _data?.clear();
      setState(() {
        _markers?.add(Marker(
            point: LatLng(
              data.latitude,
              data.longitude,
            ),
            width: 30,
            height: 30,
            anchorPos: AnchorPos.align(AnchorAlign.top),
            builder: (context) {
              return Image.asset(data.iconPath());
            }));
        _data?.add(data);
        _mapController.move(_markers?.last?.point, 14);
        _popupLayerController.togglePopup(_markers?.last);
      });
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
    });
  }

  _getGroupActualPosition() async {
    await Api.getGroupActualPosition().then((r) {
      List<EventData> data = r.responseBody;
      List<Marker> markers = [];
      for(EventData ed in data) {
        markers?.add(Marker(
            point: LatLng(
              ed.latitude,
              ed.longitude,
            ),
            width: 30,
            height: 30,
            anchorPos: AnchorPos.align(AnchorAlign.top),
            builder: (context) {
              return Image.asset(ed.iconPath());
            }));
      }
      _markers?.clear();
      setState(() {
        _markers = markers;
        _data = data;
        // _mapController.move(_markers?.last?.point, 14);
        // _popupLayerController.togglePopup(_markers?.last);
      });
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Container(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                plugins: [PopupMarkerPlugin()],
                onTap: (_) => _popupLayerController
                    .hidePopup(), // Hide popup when the map is tapped.
                center: LatLng(30.0, -9.0),
                zoom: 5.0,
              ),
              layers: [
                PopupMarkerLayerOptions(
                    markers: _markers,
                    popupSnap: PopupSnap.top,
                    popupController: _popupLayerController,
                    popupBuilder: (BuildContext _, Marker marker) {
                      EventData data = _data.firstWhere((element) =>
                          element.latitude == marker.point.latitude &&
                          element.longitude == marker.point.longitude);
                      return Container(
                        width: 280,
                        height: 90,
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Table(
                                defaultColumnWidth: FixedColumnWidth(150.0),
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.directions_car_rounded,
                                              color: Colors.black,
                                            ),
                                            Text(
                                              data.vehicleModel,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                          child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: '${data.timestampAsString}',
                                              style: TextStyle(
                                                  color:
                                                      Colors.lightBlueAccent),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' (${data.engineTemp ?? ''}°C/${_data.last.batteryVolts ?? ''}V)',
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Text(
                                          '${data.state()}',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: 'Fuel level: ',
                                              ),
                                              TextSpan(
                                                text:
                                                    '${data.oilLevel ?? ''} L',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            VerticalDivider(
                              endIndent: 12,
                              indent: 10,
                              thickness: 2,
                              color: Colors.green,
                            ),
                            Center(
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          '${data.speedKPH?.toStringAsFixed(2) ?? ''}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\n Km/h',
                                    ),
                                  ])),
                            ),
                            VerticalDivider(
                              endIndent: 12,
                              indent: 10,
                              thickness: 2,
                              color: Colors.green,
                            ),
                            Center(
                              child: Icon(
                                Icons.signal_wifi_4_bar_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
              children: <Widget>[
                TileLayerWidget(
                  options: TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                ),
              ],
            ),
            _option != "Group" ? Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 220,
                  height: 220,
                  child: Speedometer(
                    size: 220,
                    minValue: 0,
                    maxValue: 220,
                    currentValue: _data.length != 0
                        ? _data.last.speedKPH?.roundToDouble()
                        : 0,
                    displayNumericStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        backgroundColor: Colors.white,
                        color: _speedKPH < _warningSpeed
                            ? Colors.lightBlueAccent
                            : Colors.red),
                    warningValue: _warningSpeed,
                    displayText: _data.length != 0
                        ? '${_data.last.odometerKM?.toStringAsFixed(2)}'
                        : '0',
                    displayTextStyle: TextStyle(
                        fontSize: 20,
                        backgroundColor: Colors.white,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ) : SizedBox(height: 0, width: 0,),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PopupMenuButton(
                    //     icon: Container(
                    //       width: 80,
                    //       height: 80,
                    //       decoration: new BoxDecoration(
                    //         color: Colors.greenAccent,
                    //         borderRadius: new BorderRadius.only(
                    //           topLeft: const Radius.circular(30.0),
                    //           topRight: const Radius.circular(30.0),
                    //           bottomLeft: const Radius.circular(30.0),
                    //           bottomRight: const Radius.circular(30.0),
                    //         ),
                    //       ),
                    //       child: Center(
                    //         child: Icon(
                    //           Icons.more_vert,
                    //           color: Colors.green.shade700,
                    //           size: 25,
                    //         ),
                    //       ),
                    //     ),
                    //     color: Colors.white,
                    //     tooltip:
                    //         AppLocalizations.of(context).translate("Map style"),
                    //     itemBuilder: (BuildContext context) {
                    //       return _choices.map((choice) {
                    //         return PopupMenuItem<String>(
                    //           value: choice,
                    //           child: Text(choice),
                    //         );
                    //       }).toList();
                    //     },
                    //     onSelected: (choice) {
                    //       setState(() {
                    //         switch (choice) {
                    //           // "normal", "hybrid", "satellite", "terrain"
                    //           case "normal":
                    //             _mapType = MapType.normal;
                    //             break;
                    //           case "hybrid":
                    //             _mapType = MapType.hybrid;
                    //             break;
                    //           case "satellite":
                    //             _mapType = MapType.satellite;
                    //             break;
                    //           case "terrain":
                    //             _mapType = MapType.terrain;
                    //             break;
                    //         }
                    //       });
                    //     }),
                    IconButton(
                      icon: Container(
                        width: 45,
                        height: 40,
                        decoration: new BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(25.0),
                            topRight: const Radius.circular(25.0),
                            bottomLeft: const Radius.circular(25.0),
                            bottomRight: const Radius.circular(25.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.share,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        String body =
                            "http://maps.google.com/?q=${_markers.last.point.latitude},${_markers.last.point.longitude}";

                        //if body contains space change it with %20
                        if (Platform.isAndroid) {
                          var uri = 'sms:?body=$body';
                          await launch(uri);
                        } else if (Platform.isIOS) {
                          // iOS
                          // phoneNumber = phoneNumber.replaceAll('+212', '00');
                          var uri = 'sms:&body=$body';
                          await launch(uri);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setHistory(EventData ed) {
    setState(() {
      _markers?.add(Marker(
          point: LatLng(
            ed.latitude,
            ed.longitude,
          ),
          width: 30,
          height: 30,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context) {
            return Image.asset(ed.iconPath());
          }));
      _data?.add(ed);
      _mapController.move(_markers?.last.point, 14);
    });
  }
}
