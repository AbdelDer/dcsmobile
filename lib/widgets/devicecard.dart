import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/pages/ActivityHistory.dart';
import 'package:dcsmobile/pages/HistoryScreen.dart';
import 'package:dcsmobile/pages/alarmscreen.dart';
import 'package:dcsmobile/pages/commandsdialog.dart';
import 'package:dcsmobile/pages/maintenance/drainingscreen.dart';
import 'package:dcsmobile/pages/maintenance/entretienscreen.dart';
import 'package:dcsmobile/pages/maintenance/insurancescreen.dart';
import 'package:dcsmobile/pages/maintenance/technicalvisitscreen.dart';
import 'package:dcsmobile/pages/openstreetmap.dart';
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
  double _modelFontSize = 16;
  double _addressFontSize = 14;
  double _detailsFontSize = 12;

  var data;
  String _option;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  var expansionChildren;

  _DeviceCardState(this.data, this._option, this._scaffoldKey);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: data.length,
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(2),
            color: Colors.white,
            elevation: 2,
            child: ExpansionTile(
              initiallyExpanded: false,
              children: _childrenWidgets(data[index]),
              backgroundColor: Colors.transparent,
              onExpansionChanged: (val) async {
                if (_option ==
                    AppLocalizations.of(context).translate("Commands")) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CommandsDialog(
                            data[index].deviceID,
                            data[index].vehicleModel,
                            data[index].simPhoneNumber,
                            false);
                      });
                } else if (_option == "Live") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenStreetMap(
                          deviceID: data[index].deviceID, option: _option),
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
                                    builder: (context) => OpenStreetMap(
                                        deviceID: data[index].deviceID, option: _option),
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
                                    builder: (context) => VehicleLivePosition(
                                        deviceID: data[index].deviceID, option: _option),
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
                } else if (_option ==
                    AppLocalizations.of(context).translate("History")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityHistory(
                          vehicleModel: data[index].vehicleModel,
                          deviceID: data[index].deviceID),
                    ),
                  );
                  // showDialog(
                  //   // isScrollControlled: true,
                  //   //   backgroundColor: Colors.transparent,
                  //     context: context,
                  //     builder: (context) {
                  //       return HistoryScreen(data[index].deviceID,
                  //           data[index].vehicleModel, _option);
                  //     });
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
              leading: Container(
                width: 85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      data[index].iconPath(),
                      width: 30,
                    ),
                    _option == "speedReport"
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : data[index].activityTime() == ''
                            ? SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Text(
                                data[index].activityTime(),
                                style: TextStyle(fontSize: 14),
                              ),
                  ],
                ),
              ),
              title: Row(children: <Widget>[
                Icon(Icons.directions_car),
                Text(
                  data[index].vehicleModel,
                  style: TextStyle(
                    fontSize: _modelFontSize,
                    color: Colors.black,
                  ),
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
                  _option == "speedReport"
                      ? RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: _detailsFontSize,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "${data[index].timestampAsString} "),
                              TextSpan(
                                  text: "| ",
                                  style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text:
                                      "${data[index].speedKPH.toStringAsFixed(2)} Km/h")
                            ],
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: _detailsFontSize,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "${data[index].timestampAsString} "),
                              TextSpan(
                                  text: "| ",
                                  style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextSpan(
                                  text:
                                      "${data[index].distanceKM?.toStringAsFixed(2) ?? ''} Km/J")
                            ],
                          ),
                        ),
                ],
              ),
              trailing: Icon(
                Icons.network_wifi,
                color: Colors.black,
              ),
            ),
          );
        });
  }

  _childrenWidgets(data) {
    if (_option == "speedReport") {
      return <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(data.latitude, data.longitude), zoom: 17),
            zoomControlsEnabled: false,
            markers: Set.of([
              Marker(
                  markerId: MarkerId('${data.timestamp}'),
                  position: LatLng(data.latitude, data.longitude),
                  infoWindow: InfoWindow(
                      snippet:
                          "lat: ${data.latitude.toStringAsFixed(2)}, lon: ${data.longitude.toStringAsFixed(2)}",
                      title: "Speed: ${data.speedKPH.toStringAsFixed(2)}"))
            ]),
            mapType: MapType.hybrid,
            onMapCreated: (GoogleMapController googleMapController) {},
          ),
        )
      ];
    } else if (_option == "Maintenance") {
      return <Widget>[
        Container(
          width: 300,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.green)),
            padding: const EdgeInsets.symmetric(horizontal: 60),
            icon: Image.asset('assets/maintenance/draining.png'),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "${AppLocalizations.of(context).translate("DRAINING")}",
                style: TextStyle(color: Colors.black),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrainingScreen(
                    vehicleModel: data.vehicleModel,
                    deviceID: data.deviceID,
                  ),
                ),
              );
            },
            color: Colors.white,
          ),
        ),
        // Container(
        //   width: 300,
        //   child: RaisedButton.icon(
        //     shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(18.0),
        //         side: BorderSide(color: Colors.green)),
        //     padding: const EdgeInsets.symmetric(horizontal: 60),
        //     icon: Image.asset('assets/maintenance/document.png'),
        //     label: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: Text(
        //         "REGISTRATION\nDOCUMENT",
        //         style: TextStyle(color: Colors.black),
        //       ),
        //     ),
        //     onPressed: () {},
        //     color: Colors.white,
        //   ),
        // ),
        Container(
          width: 300,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.green)),
            padding: const EdgeInsets.symmetric(horizontal: 60),
            icon: Image.asset('assets/maintenance/visit.png'),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "${AppLocalizations.of(context).translate("Technical Visit")}",
                style: TextStyle(color: Colors.black),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TechnicalVisitScreen(
                    vehicleModel: data.vehicleModel,
                    deviceID: data.deviceID,
                  ),
                ),
              );
            },
            color: Colors.white,
          ),
        ),
        Container(
          width: 300,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.green)),
            padding: const EdgeInsets.symmetric(horizontal: 60),
            icon: Image.asset('assets/maintenance/insurance.png'),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "${AppLocalizations.of(context).translate("Insurance")}",
                style: TextStyle(color: Colors.black),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsuranceScreen(
                    vehicleModel: data.vehicleModel,
                    deviceID: data.deviceID,
                  ),
                ),
              );
            },
            color: Colors.white,
          ),
        ),
        Container(
          width: 300,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.green)),
            padding: const EdgeInsets.symmetric(horizontal: 60),
            icon: Image.asset('assets/maintenance/entretien.png'),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "${AppLocalizations.of(context).translate("Entretiens")}",
                style: TextStyle(color: Colors.black),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntretienScreen(
                    vehicleModel: data.vehicleModel,
                    deviceID: data.deviceID,
                  ),
                ),
              );
            },
            color: Colors.white,
          ),
        ),
      ];
    } else {
      return <Widget>[];
    }
  }
}
