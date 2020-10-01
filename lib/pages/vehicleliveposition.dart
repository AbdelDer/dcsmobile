import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

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

class VehicleLivePosition extends StatefulWidget {
  final deviceID;
  final option;

  const VehicleLivePosition({Key key, this.deviceID, this.option})
      : super(key: key);

  @override
  _VehicleLivePositionState createState() =>
      _VehicleLivePositionState(this.deviceID, this.option);
}

class _VehicleLivePositionState extends State<VehicleLivePosition> {
  final _deviceID;
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
  final double _warningSpeed = 100;
  gdesy.Geodesy _geodesy = gdesy.Geodesy();

  _VehicleLivePositionState(this._deviceID, this._option);

  @override
  void initState() {
    super.initState();
  }

  double _getMyBearing(Position lastPosition, Position currentPosition) {
    double dLon = (lastPosition.longitude - currentPosition.longitude);
    double y = math.sin(dLon) * math.cos(lastPosition.latitude);
    double x =
        math.cos(currentPosition.latitude) * math.sin(lastPosition.latitude) -
            math.sin(currentPosition.latitude) *
                math.cos(lastPosition.latitude) *
                math.cos(dLon);
    double brng = (math.atan2(y, x)) * 180 / math.pi;
    brng = (360 - ((brng + 360) % 360));
    return 180 + brng;
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  Stream<EventData> _eventDataStream(deviceID) async* {
    var response;
    if (_option == "History") {
      await Api.getHistory(deviceID).then((r) {
        response = r;
      }).catchError((err) {
        ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
      });
      for (EventData ed in response.data) {
        await Future.delayed(Duration(milliseconds: 1500));
        yield ed;
      }
    } else if(_option == "Live") {
      await Api.getActualPosition(deviceID).then((r) {
        response = r;
      }).catchError((err) {
        ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
      });
      yield response.data;
      await Future.delayed(Duration(milliseconds: 1500));
    }
  }

  _loadCarPin() async {
    final byteData = await rootBundle.load("assets/icons/car.png");
    _carPin = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(_carPin, targetWidth: 50, targetHeight: 50);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    _carPin = (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(34.011405, -5.064120),
    zoom: 14.4746,
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
              onMapCreated: (GoogleMapController googleMapController) {
                _googleMapController = googleMapController;
                _loadCarPin();
                _streamSubscription =
                    _eventDataStream(_deviceID).listen((eventData) {
                  _setData(eventData);
                });
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 200,
                height: 200,
                child: Speedometer(
                  size: 250,
                  minValue: 0,
                  maxValue: 220,
                  currentValue: _speedKPH,
                  displayNumericStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _speedKPH < _warningSpeed
                          ? Colors.lightBlueAccent
                          : Colors.red),
                  warningValue: _warningSpeed,
                  displayText: 'speed',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _setData(data) {
    final bitmapCar = BitmapDescriptor.fromBytes(_carPin);
    final markerID = MarkerId("${_markers.length}");
    final position = LatLng(data.latitude, data.longitude);
    _route.add(position);
    final customPolyline = Polyline(
        polylineId: PolylineId("custom"),
        points: _route,
        color: Colors.deepOrangeAccent,
        width: 8);
    final infoWindow = InfoWindow(
        snippet: "lat: ${data.latitude}, lon: ${data.longitude}",
        title: "Speed: ${data.speedKPH}");

    if (_marker == null) {
      if (_option == "Live") {
        _marker = Marker(markerId: markerID, rotation: 0, position: position);
      } else {
        _marker = Marker(
            markerId: markerID,
            rotation: 0,
            position: position,
            visible: false);
      }
    } else {
      final _currentPosititon =
          Position(longitude: data.longitude, latitude: data.latitude);
      final rotation = _getMyBearing(_lastPosition, _currentPosititon);
      //final rotation = _geodesy.finalBearingBetweenTwoGeoPoints(gdesy.LatLng(_lastPosition.latitude, _lastPosition.longitude), gdesy.LatLng(_currentPosititon.latitude, _currentPosititon.longitude));
      _marker = _marker.copyWith(
          positionParam: LatLng(data.latitude, data.longitude),
          rotationParam: rotation,
          iconParam: bitmapCar,
          infoWindowParam: infoWindow,
          visibleParam: true);
    }

    _lastPosition =
        Position(longitude: data.longitude, latitude: data.latitude);

    setState(() {
      _markers[markerID] = _marker;
      _speedKPH = data.speedKPH;
      _polylines.add(customPolyline);
    });
    _googleMapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }
}
