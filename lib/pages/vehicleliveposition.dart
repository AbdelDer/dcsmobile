import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:geodesy/geodesy.dart' as gdesy;

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/animations/speedometer.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/models/EventData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleLivePosition extends StatefulWidget {
  String deviceID;
  final option;
  int startTime;
  int endTime;

  VehicleLivePosition({Key key, @required this.deviceID, @required this.option})
      : super(key: key);

  VehicleLivePosition.History(
      {@required this.deviceID,
      @required this.option,
      @required this.startTime,
      @required this.endTime});

  VehicleLivePosition.Group({@required this.option});

  @override
  _VehicleLivePositionState createState() {
    if (option == "History") {
      return _VehicleLivePositionState.History(
          deviceID, option, startTime, endTime);
    } else if (option == "Live") {
      return _VehicleLivePositionState(this.deviceID, this.option);
    } else if (option == "Group") {
      return _VehicleLivePositionState.Group(this.option);
    }
  }
}

class _VehicleLivePositionState extends State<VehicleLivePosition> {
  String _deviceID;
  final _option;
  GoogleMapController _googleMapController;
  Uint8List _carPin;
  Uint8List _markerPin;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<MarkerId, Marker> _markers = Map();
  Set<Polyline> _polylines = {};
  List<LatLng> _route = List();
  StreamSubscription<EventData> _streamSubscription;
  Position _lastPosition;
  Marker _marker;
  double _speedKPH = 0;
  double _odometer = 0;
  final double _warningSpeed = 100;
  gdesy.Geodesy _geodesy = gdesy.Geodesy();
  MapType _mapType = MapType.normal;
  List<String> _choices = ["normal", "hybrid", "satellite", "terrain"];
  bool _first = true;
  Timer _timer;
  double _dialogTextSize = 16;
  int _startTime;
  int _endTime;

  _VehicleLivePositionState(this._deviceID, this._option);

  _VehicleLivePositionState.History(
      this._deviceID, this._option, this._startTime, this._endTime);

  _VehicleLivePositionState.Group(this._option);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  // double _getMyBearing(Position lastPosition, Position currentPosition) {
  //   double dLon = (lastPosition.longitude - currentPosition.longitude);
  //   double y = math.sin(dLon) * math.cos(lastPosition.latitude);
  //   double x =
  //       math.cos(currentPosition.latitude) * math.sin(lastPosition.latitude) -
  //           math.sin(currentPosition.latitude) *
  //               math.cos(lastPosition.latitude) *
  //               math.cos(dLon);
  //   double brng = (math.atan2(y, x)) * 180 / math.pi;
  //   brng = (360 - ((brng + 360) % 360));
  //   return 180 + brng;
  // }

  _positionDetails() async {
    if (_option == "History") {
      Timer.run(() async {
        await Api.getHistory(this._deviceID, this._startTime, this._endTime)
            .then((r) async {
          for (EventData ed in r.responseBody) {
            await Future.delayed(Duration(milliseconds: 1000));
            _setData(ed);
          }
        }).catchError((err) {
          ApiShowDialog.dialog(
              scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
        });
      });
    } else if (_option == "Live") {
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
      _setData(r.responseBody);
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
    });
  }

  _getGroupActualPosition() async {
    await Api.getGroupActualPosition().then((r) {
      _setData(r.responseBody);
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
    });
  }

  _loadCarPin() async {
    final byteData = await rootBundle.load("assets/icons/car.png");
    _carPin = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(_carPin,
        targetWidth: 80, targetHeight: 80);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    _carPin = (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.0, -9.0),
    zoom: 5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: FEDrawer(),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              zoomControlsEnabled: false,
              markers: Set.of(_markers.values),
              polylines: Set.of(_polylines),
              mapType: _mapType,
              onMapCreated: (GoogleMapController googleMapController) {
                _googleMapController = googleMapController;
                _loadCarPin();
                _option == 'Live' ? _getActualPosition() : null;
                _positionDetails();
                // _streamSubscription =
                //     _eventDataStream(_deviceID).listen((eventData) {
                //   _setData(eventData);
                // });
              },
            ),
            _option != "Group"
                ? Padding(
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
                          currentValue: _speedKPH?.roundToDouble(),
                          displayNumericStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              backgroundColor: Colors.white,
                              color: _speedKPH < _warningSpeed
                                  ? Colors.lightBlueAccent
                                  : Colors.red),
                          warningValue: _warningSpeed,
                          displayText: '${_odometer?.toStringAsFixed(2)}',
                          displayTextStyle: TextStyle(
                              fontSize: 20,
                              backgroundColor: Colors.white,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton(
                        icon: Container(
                          width: 80,
                          height: 80,
                          decoration: new BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(30.0),
                              topRight: const Radius.circular(30.0),
                              bottomLeft: const Radius.circular(30.0),
                              bottomRight: const Radius.circular(30.0),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.green.shade700,
                              size: 25,
                            ),
                          ),
                        ),
                        color: Colors.white,
                        tooltip:
                            AppLocalizations.of(context).translate("Map style"),
                        itemBuilder: (BuildContext context) {
                          return _choices.map((choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        onSelected: (choice) {
                          setState(() {
                            switch (choice) {
                              // "normal", "hybrid", "satellite", "terrain"
                              case "normal":
                                _mapType = MapType.normal;
                                break;
                              case "hybrid":
                                _mapType = MapType.hybrid;
                                break;
                              case "satellite":
                                _mapType = MapType.satellite;
                                break;
                              case "terrain":
                                _mapType = MapType.terrain;
                                break;
                            }
                          });
                        }),
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
                            "http://maps.google.com/?q=${_marker.position.latitude},${_marker.position.longitude}";

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

  _setData(data) {
    if (_option == "Group") {
      Map<MarkerId, Marker> markers = Map();
      for (int i=0; i< data.length; i++) {
        var infoWindow = InfoWindow(
            snippet: "Speed: ${data[i].speedKPH.toStringAsFixed(2)} Km/h more...",
            title: "${data[i].vehicleModel}",
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
                                    "${data[i].vehicleModel}",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Speed")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${data[i].speedKPH.toStringAsFixed(2)} km/h",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Time")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    data[i].timestampAsString,
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Latitude")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${data[i].latitude}",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Longitude")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${data[i].longitude}",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Oil level")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${data[i].oilLevel} L",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Status")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${AppLocalizations.of(context).translate(data.speedKPH > 3 ? "Moving" : "Parked")}",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Battery")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${data[i].batteryVolts} V",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Engine temp")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Text(
                                    "${data[i].engineTemp} °C",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.green),
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
                                    "${AppLocalizations.of(context).translate("Signal")}: ",
                                    style: TextStyle(
                                        fontSize: _dialogTextSize,
                                        decoration: TextDecoration.none,
                                        color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.signal_wifi_4_bar_outlined,
                                    color: Colors.green.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            });
        var markerID = MarkerId(data[i].deviceID.toString());
        var position = LatLng(data[i].latitude, data[i].longitude);
        BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: Size(25, 25)), data[i].iconPath())
            .then((markerIcon) {
          _marker = Marker(
              markerId: markerID,
              position: position,
              icon: markerIcon,
              infoWindow: infoWindow
          );
          markers[markerID] = _marker;
        });
      }
      setState(() {
        _markers.clear();
        _markers = markers;
      });
    } else {
      final infoWindow = InfoWindow(
          snippet: "Speed: ${data.speedKPH.toStringAsFixed(2)} Km/h more...",
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
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Speed")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${data.speedKPH.toStringAsFixed(2)} km/h",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Time")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  data.timestampAsString,
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Latitude")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${data.latitude}",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Longitude")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${data.longitude}",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Oil level")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${data.oilLevel} L",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Status")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${AppLocalizations.of(context).translate(data.speedKPH > 3 ? "Moving" : "Parked")}",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Battery")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${data.batteryVolts} V",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Engine temp")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${data.engineTemp} °C",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.green),
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
                                  "${AppLocalizations.of(context).translate("Signal")}: ",
                                  style: TextStyle(
                                      fontSize: _dialogTextSize,
                                      decoration: TextDecoration.none,
                                      color: Colors.black),
                                ),
                                Icon(
                                  Icons.signal_wifi_4_bar_outlined,
                                  color: Colors.green.shade700,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          });
      final markerID = MarkerId("${_markers.length}");
      final position = LatLng(data.latitude, data.longitude);
      if (_option == "History") {
        _route.add(position);
        final customPolyline = Polyline(
            polylineId: PolylineId("custom"),
            points: _route,
            color: Colors.greenAccent,
            width: 2);
        BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: Size(25, 25)), data.iconPath())
            .then((markerIcon) {
          _marker = Marker(
              markerId: markerID,
              position: position,
              icon: markerIcon,
              infoWindow: infoWindow);
          setState(() {
            _markers[markerID] = _marker;
            _speedKPH = data.speedKPH;
            _odometer = data.odometerKM;
            _polylines.add(customPolyline);
          });
          _googleMapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
        });
      } else if (_option == "Live") {
        BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: Size(25, 25)), data.iconPath())
            .then((markerIcon) {
          _marker = Marker(
              markerId: markerID,
              position: position,
              icon: markerIcon,
              infoWindow: infoWindow);
          setState(() {
            _markers.clear();
            _markers[markerID] = _marker;
            _speedKPH = data.speedKPH;
            _odometer = data.odometerKM;
            // _polylines.add(customPolyline);
          });
          _googleMapController
              ?.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
        });
      }
    }
  }
}
