import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/models/EventData.dart';
import 'package:dcsmobile/models/notifications/notification.dart' as n;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geodesy/geodesy.dart';

class NotificationMap extends StatefulWidget {
  final n.Notification notificationData;

  const NotificationMap({Key key, this.notificationData}) : super(key: key);

  @override
  _NotificationMapState createState() =>
      _NotificationMapState(notificationData);
}

class _NotificationMapState extends State<NotificationMap> {
  final n.Notification notificationData;
  EventData data;
  List<Marker> _markers = [];
  MapController _mapController;
  // Used to trigger showing/hiding of popups.
  final PopupController _popupLayerController = PopupController();

  _NotificationMapState(this.notificationData);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPositionDetails(
            notificationData.deviceID, notificationData.timestamp),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            data = snapshot.data;
            if(data.latitude != null) {
              _markers.add(Marker(
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
            }
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                plugins: [PopupMarkerPlugin()],
                center: LatLng(data.latitude ?? 51.5, data.longitude ?? -0.09),
                zoom: 13.0,
                maxZoom: 18.0,
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        "https://mts1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
                    subdomains: ['a', 'b', 'c']),
                PopupMarkerLayerOptions(
                  markers: _markers,
                  popupSnap: PopupSnap.top,
                  popupController: _popupLayerController,
                  popupBuilder: (BuildContext _, Marker marker) {
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
                                              decoration: TextDecoration.none,
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
                                          decoration: TextDecoration.none,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: '${data.timestampAsString}',
                                            style: TextStyle(
                                                color: Colors.lightBlueAccent),
                                          ),
                                          TextSpan(
                                            text:
                                                ' (${data.engineTemp ?? ''}°C/${data.batteryVolts ?? ''}V)',
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
                                          decoration: TextDecoration.none,
                                          color: Colors.black,
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
                                            decoration: TextDecoration.none,
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
            );
          } else {
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  Future<EventData> _getPositionDetails(deviceID, timestamp) async {
    return Api.getPositionByTimestampAndDeviceID(
        jsonEncode({"deviceID": deviceID, "timestamp": timestamp})).then((_) {
      return _.responseBody;
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
      throw (error);
    });
  }
}
