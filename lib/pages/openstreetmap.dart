import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/animations/speedometer.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/EventData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart' as lt;
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map/coords.dart';

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

class _OpenStreetMapState extends State<OpenStreetMap>
    with TickerProviderStateMixin {
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
  Timer _timerForLoadingBar;
  double _dialogTextSize = 16;
  List<Marker> _markers;
  List<EventData> _data;
  List<lt.LatLng> _points = [];
  bool readyToPlay = false;
  String layers = "h";
  String urlTemplate = "https://mts1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
  List<String> _choices = [
    'Roads only',
    'Standard roadmap',
    'Terrain',
    'Satellite only',
    'Terrain only',
    'Hybrid',
    'OpenStreetMap'
  ];

  // Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();

  double _progressValue;

  int _playbackSpeed;

  CoordsBetweenTwoGeoPoints _coordsBetweenTwoGeoPoints =
      CoordsBetweenTwoGeoPoints();

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
    _progressValue = 0.0;
    _playbackSpeed = 10;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerForLoadingBar?.cancel();
    super.dispose();
  }

  _positionDetails() async {
    if (_option == "History" && mounted) {
      Timer.run(() async {
        await Api.getHistory(this._deviceID, this._startTime, this._endTime)
            .then((r) async {
          for (EventData ed in r.responseBody) {
            if (mounted) {
              // await Future.delayed(Duration(milliseconds: 100));
              _setHistory(ed);
            } else {
              break;
            }
          }
          readyToPlay = true;
        }).catchError((err) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(err.toString()),
            ),
          );
          // ApiShowDialog.dialog(
          //     scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
        });
      });
    } else if (_option == "Live") {
      _getActualPosition();
      _timerForLoadingBar = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _progressValue += 0.2;
        });
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          setState(() {
            _progressValue = 0.0;
          });
        }
      });
      _timer = Timer.periodic(Duration(seconds: 20), (timer) async {
        await _getActualPosition();
      });
    } else if (_option == "Group") {
      _getGroupActualPosition();
      _timer = Timer.periodic(Duration(seconds: 60), (timer) async {
        await _getGroupActualPosition();
      });
    }
  }

  void _animatedMapMove(LatLng destLocation) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: _mapController.zoom, end: 18);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  _getActualPosition() async {
    await Api.getActualPosition(this._deviceID).then((r) async {
      var data = r.responseBody;
      if (_markers?.length != 0) {
        String icon;
        if (_data[0].speedKPH == 0) {
          icon = data.iconPath();
        } else {
          icon = _data[0].iconPath();
        }
        for (var coord in _coordsBetweenTwoGeoPoints.getCoords(
            _markers[0].point.latitude,
            _markers[0].point.longitude,
            data.latitude,
            data.longitude)) {
          // print(coord);
          _markers?.clear();
          _data?.clear();
          data.latitude = coord[0];
          data.longitude = coord[1];
          _data?.add(data);
          setState(() {
            _markers?.add(Marker(
                point: LatLng(
                  coord[0],
                  coord[1],
                ),
                width: 30,
                height: 30,
                anchorPos: AnchorPos.align(AnchorAlign.top),
                builder: (context) {
                  return Image.asset(icon);
                }));
            _mapController.move(_markers?.last?.point, 18);
            _popupLayerController.togglePopup(_markers?.last);
            // _animatedMapMove(_markers.last.point);
          });
          await Future.delayed(Duration(milliseconds: 2));
        }
      }
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
        _mapController.move(_markers?.last?.point, 18);
        _popupLayerController.togglePopup(_markers?.last);
        // _animatedMapMove(_markers.last.point);
      });
    }).catchError((err) {
      _scaffoldKey?.currentState?.showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
      // ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
    });
  }

  _getGroupActualPosition() async {
    await Api.getGroupActualPosition().then((r) {
      List<EventData> data = r.responseBody;
      List<Marker> markers = [];
      for (EventData ed in data) {
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
        // _mapController.move(_markers?.last?.point, 18);
        // _popupLayerController.togglePopup(_markers?.last);
      });
    }).catchError((err) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
      // ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
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

                // maxZoom: 18
              ),
              layers: [
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: _points,
                        strokeWidth: 4.0,
                        color: Colors.greenAccent),
                  ],
                ),
                PopupMarkerLayerOptions(
                  markers: _markers,
                  popupSnap: PopupSnap.top,
                  popupController: _popupLayerController,
                  popupBuilder: (BuildContext _, Marker marker) {
                    EventData data;
                    if (_option != "Live") {
                      data = _data.firstWhere((element) =>
                          element.latitude == marker.point.latitude &&
                          element.longitude == marker.point.longitude);
                    } else {
                      data = _data[0];
                    }
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
                                              fontSize: 10,
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
                                          fontSize: 10,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: '${data.timestampAsString}',
                                            style: TextStyle(
                                                color: Colors.lightBlueAccent),
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
                                          fontSize: 10,
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
                                            fontSize: 10,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'Fuel level: ',
                                            ),
                                            TextSpan(
                                              text: '${data.oilLevel ?? ''} L',
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
                                      fontSize: 10,
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
                  },
                ),
              ],
              children: <Widget>[
                TileLayerWidget(
                  options: TileLayerOptions(
                      urlTemplate: urlTemplate, subdomains: ['a', 'b', 'c']),
                ),
              ],
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
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            _option == 'Live'
                ? Padding(
                    padding: EdgeInsets.only(
                      top: 1,
                    ),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.greenAccent.shade100,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.green.shade900),
                      value: _progressValue,
                    ),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
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
                              // 'Roads only', 'Standard roadmap', 'Terrain', 'Satellite only', 'Terrain only', 'Hybrid'
                              case "Roads only":
                                setState(() {
                                  layers = "h";
                                  urlTemplate =
                                      "https://mts1.google.com/vt/lyrs=${layers}&x={x}&y={y}&z={z}";
                                });
                                break;
                              case "Standard roadmap":
                                setState(() {
                                  layers = "m";
                                  urlTemplate =
                                      "https://mts1.google.com/vt/lyrs=${layers}&x={x}&y={y}&z={z}";
                                });
                                break;
                              case "Terrain":
                                setState(() {
                                  layers = "p";
                                  urlTemplate =
                                      "https://mts1.google.com/vt/lyrs=${layers}&x={x}&y={y}&z={z}";
                                });
                                break;
                              case "Satellite only":
                                setState(() {
                                  layers = "s";
                                  urlTemplate =
                                      "https://mts1.google.com/vt/lyrs=${layers}&x={x}&y={y}&z={z}";
                                });
                                break;
                              case "Terrain only":
                                setState(() {
                                  layers = "t";
                                  urlTemplate =
                                      "https://mts1.google.com/vt/lyrs=${layers}&x={x}&y={y}&z={z}";
                                });
                                break;
                              case "Hybrid":
                                setState(() {
                                  layers = "y";
                                  urlTemplate =
                                      "https://mts1.google.com/vt/lyrs=${layers}&x={x}&y={y}&z={z}";
                                });
                                break;
                              case "OpenStreetMap":
                                setState(() {
                                  urlTemplate =
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
                                });
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
                            "http://maps.google.com/?q=${_markers.last.point.latitude},${_markers.last.point.longitude}";
                        await Share.share(body);
                      },
                    ),
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
                            Icons.map,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (urlTemplate.contains("open")) {
                          setState(() {
                            urlTemplate =
                                "https://mts1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}";
                          });
                        } else {
                          setState(() {
                            urlTemplate =
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
                          });
                        }
                        /*if (_option != "History") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleLivePosition(
                                  deviceID: _deviceID, option: _option),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return VehicleLivePosition.History(
                                  deviceID: _deviceID,
                                  option: "History",
                                  startTime: _startTime,
                                  endTime: _endTime,
                                );
                              },
                            ),
                          );
                        }*/
                      },
                    ),
                    _option == 'History' && readyToPlay
                        ? IconButton(
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
                                  Icons.play_arrow,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (_playbackSpeed == 1) {
                                setState(() {
                                  _playbackSpeed = 10;
                                });
                              } else {
                                List<Marker> oldMarkers = List<Marker>();
                                oldMarkers = []..addAll(_markers);
                                if (mounted) {
                                  setState(() {
                                    _markers.clear();
                                  });
                                }
                                for (Marker m in oldMarkers) {
                                  await Future.delayed(
                                      Duration(milliseconds: _playbackSpeed));
                                  if (mounted) {
                                    setState(() {
                                      _markers.add(m);
                                    });
                                    _mapController.move(
                                        _markers.last.point, 18);
                                  }
                                }
                              }
                            },
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                    // _option == 'History' && readyToPlay
                    //     ? IconButton(
                    //         icon: Container(
                    //           width: 45,
                    //           height: 40,
                    //           decoration: new BoxDecoration(
                    //             color: Colors.greenAccent,
                    //             borderRadius: new BorderRadius.only(
                    //               topLeft: const Radius.circular(25.0),
                    //               topRight: const Radius.circular(25.0),
                    //               bottomLeft: const Radius.circular(25.0),
                    //               bottomRight: const Radius.circular(25.0),
                    //             ),
                    //           ),
                    //           child: Padding(
                    //             padding: const EdgeInsets.only(right: 4.0),
                    //             child: Icon(
                    //               Icons.pause,
                    //               color: Colors.green.shade700,
                    //               size: 20,
                    //             ),
                    //           ),
                    //         ),
                    //         onPressed: () async {
                    //           if(_playbackSpeed != 1){
                    //             setState(() {
                    //               _playbackSpeed = 1;
                    //             });
                    //           }
                    //         },
                    //       )
                    //     : SizedBox(
                    //         height: 0,
                    //         width: 0,
                    //       ),
                    _option == 'History'
                        ? IconButton(
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
                                  Icons.fast_forward,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_playbackSpeed == 200)
                                  setState(() {
                                    _playbackSpeed = 10;
                                  });
                              });
                            },
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                    _option == 'History'
                        ? IconButton(
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
                                  Icons.fast_rewind,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_playbackSpeed == 50)
                                  setState(() {
                                    _playbackSpeed = 200;
                                  });
                              });
                            },
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                    _option == 'Live'
                        ? GestureDetector(
                            onTap: () {
                              launchURL(
                                  _data.last.latitude, _data.last.longitude);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: new BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(50.0),
                                  topRight: const Radius.circular(50.0),
                                  bottomLeft: const Radius.circular(50.0),
                                  bottomRight: const Radius.circular(50.0),
                                ),
                              ),
                              child: SvgPicture.asset(
                                'assets/historytimeline/distance.svg',
                                color: Colors.green.shade700,
                              ),
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
            return Image.asset(ed.iconPath(purpose: "History"));
          }));
      _points?.add(lt.LatLng(ed.latitude, ed.longitude));
      _data?.add(ed);
      _mapController.move(_markers?.last.point, 18);
    });
  }

  launchURL(lat, lng) async {
    final String googleMapslocationUrl =
        "https://www.google.com/maps/search/?api=1&query=${lat},${lng}";

    final String encodedURl = Uri.encodeFull(googleMapslocationUrl);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Ne peut pas ouvrir Google Maps"),
      ));
    }
  }
}
