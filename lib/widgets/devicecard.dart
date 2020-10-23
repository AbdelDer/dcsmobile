import 'package:dcsmobile/pages/HistoryScreen.dart';
import 'package:dcsmobile/pages/alarmview.dart';
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

  bool _all = false;

  var data;
  String _option;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  _DeviceCardState(this.data, this._option, this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _option == "Report"
            ? SwitchListTile(
                activeColor: Colors.orange,
                title: const Text('Tous les véhicules'),
                value: _all,
                onChanged: (bool value) {
                  setState(() {
                    //change value
                    _all = !_all;
                  });
                  if (_all) {
                    // showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return ReportScreen();
                    //     });
                  }
                },
              )
            : SizedBox(
                height: 0,
                width: 0,
              ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Card(
                color: _all ? Colors.blue.shade100 : Colors.white,
                elevation: 2,
                child: ExpansionTile(
                  initiallyExpanded: false,
                  children: _option == "Alarms"
                      ? <Widget>[AlarmView(_scaffoldKey, data[index].deviceID)]
                      : [],
                  backgroundColor: Colors.transparent,
                  onExpansionChanged: (val) async {
                    if (_option == "Report") {
                      // showDialog(
                      //     context: context,
                      //     builder: (context) {
                      //       return ReportScreen();
                      //     });
                    } else if (_option == "Commands") {
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
              );
            }),
      ],
    );
  }
}
