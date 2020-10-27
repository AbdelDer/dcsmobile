import 'package:dcsmobile/pages/HistoryScreen.dart';
import 'package:dcsmobile/pages/alarmscreen.dart';
import 'package:dcsmobile/pages/commandsdialog.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:dcsmobile/pages/vehicleliveposition.dart';
import 'package:flutter/material.dart';

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
  double _addressFontSize = 18;
  double _detailsFontSize = 16;

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
              return GestureDetector(
                onTap: () {
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
                        builder: (context) => AlarmScreen(data[index].vehicleModel, data[index].deviceID),
                      ),
                    );
                  }
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: ListTile(
                    // initiallyExpanded: false,
                    // children: _option == "Alarms"
                    //     ? <Widget>[AlarmView(_scaffoldKey, data[index].deviceID)]
                    //     : [],
                    // backgroundColor: Colors.transparent,
                    // onExpansionChanged: (val) async {
                    //
                    // },
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          data[index].iconPath(),
                          width: 30,
                        ),
                        Text(data[index].activityTime(), style: TextStyle(fontSize: 15),),
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
                ),
              );
            }),
      ],
    );
  }
}
