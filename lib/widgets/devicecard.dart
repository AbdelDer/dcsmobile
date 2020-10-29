import 'package:dcsmobile/pages/HistoryScreen.dart';
import 'package:dcsmobile/pages/alarmscreen.dart';
import 'package:dcsmobile/pages/commandsdialog.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:dcsmobile/pages/vehicleliveposition.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeviceCard extends StatefulWidget {
  var data;
  String _option;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  DeviceCard(this.data, this._option, this._scaffoldKey);

  @override
  _DeviceCardState createState() =>
      _DeviceCardState(this.data, this._option, this._scaffoldKey);
}

class _DeviceCardState extends State<DeviceCard> {
  double _modelFontSize = 24;
  double _addressFontSize = 17;
  double _detailsFontSize = 15;

  var data;
  String _option;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  _DeviceCardState(this.data, this._option, this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Card(
                  color: Colors.white,
                  elevation: 2,
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    children: _option == "speedReport"
                        ? <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(data[index].latitude,
                                        data[index].longitude), zoom: 17),
                                zoomControlsEnabled: false,
                                markers: Set.of([
                                  Marker(
                                      markerId: MarkerId('${data[index].timestamp}'),
                                      position: LatLng(data[index].latitude,
                                          data[index].longitude), infoWindow: InfoWindow(
                                      snippet: "lat: ${data[index].latitude}, lon: ${data[index].longitude}",
                                      title: "Speed: ${data[index].speedKPH}"))
                                ]),
                                mapType: MapType.hybrid,
                                onMapCreated:
                                    (GoogleMapController googleMapController) {},
                              ),
                            )
                          ]
                        : [],
                    backgroundColor: Colors.transparent,
                    onExpansionChanged: (val) async {
                      if (_option == "Commands") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CommandsDialog(data[index].vehicleModel,
                                  data[index].simPhoneNumber, false);
                            });
                      } else if (_option == "Live") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleLivePosition(
                                deviceID: data[index].deviceID, option: _option),
                          ),
                        );
                      } else if (_option == "History") {
                        showDialog(
                          // isScrollControlled: true,
                          //   backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return HistoryScreen(data[index].deviceID,
                                  data[index].vehicleModel, _option);
                            });
                      } else if (_option == "Alarms") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlarmScreen(
                                data[index].vehicleModel, data[index].deviceID),
                          ),
                        );
                      }
                    },
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          data[index].iconPath(),
                          width: 30,
                        ),
                        Text(
                          data[index].activityTime(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    title: Row(children: <Widget>[
                      Icon(Icons.directions_car),
                      Text(
                        data[index].vehicleModel,
                        style: TextStyle(
                            fontSize: _modelFontSize, color: Colors.black),
                      )
                    ]),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder(
                          future: data[index].address,
                          builder: (context, snapshot) {
                            return Text(
                              '${snapshot.data}',
                              style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontSize: _addressFontSize),
                            );
                          },
                        ),
                        Text(
                          "${data[index].timestampAsString} ${data[index].distanceKM} Km/J",
                          style: TextStyle(fontSize: _detailsFontSize),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.network_wifi,
                      color: Colors.black,
                    ),
                  ),
                );
            }),
      ],
    );
  }
}
