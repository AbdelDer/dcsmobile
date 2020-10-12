import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/pages/HistoryScreen.dart';
import 'package:dcsmobile/pages/ReportView.dart';
import 'package:dcsmobile/pages/commandsscreen~.dart';
import 'package:dcsmobile/pages/alarmview.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

import '../vehicleliveposition.dart';

class VehicleListView<T> extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Key _key;
  final _description;
  final _option;

  VehicleListView(this.scaffoldKey, this._key, this._description, this._option)
      : super(key: _key);

  @override
  VehicleListViewState createState() {
    return VehicleListViewState(this.scaffoldKey, this._key, this._description, this._option);
  }
}

class VehicleListViewState extends State {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Key _key;
  final _description;
  final _option;
  String search = "";

  VehicleListViewState(this.scaffoldKey, this._key, this._description,
      this._option);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: fetchDevices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            ApiShowDialog.dialog(
                scaffoldKey: scaffoldKey,
                message: '${snapshot.error}',
                type: 'error');
          } else if (snapshot.hasData) {
            return _devicesListView(snapshot.data);
          }
        } else if (snapshot.connectionState == ConnectionState.none) {
          ApiShowDialog.dialog(
              scaffoldKey: scaffoldKey,
              message: 'Problème de connexion',
              type: 'error');
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  fetchDevices() async* {
    final prefs = EncryptedSharedPreferences();
    //in this case if user connected using only accountID params will be [accountID, null], in the Api class
    //we will find devices of an account not use and vice versa.
    List<String> params = [
      await prefs.getString("accountID"),
      await prefs.getString("userID") ?? '',
      this._description,
      this.search
    ];

    var list = [];

    await Api.devices(params).then((_) {
      if (_.message != null) {
        ApiShowDialog.dialog(
            scaffoldKey: scaffoldKey,
            message: search == '' ? _.message : _.message + ' de ce modèle',
            type: 'error');
      } else {
        list = _.data;
      }
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: scaffoldKey, message: err, type: 'error');
    });
    yield list;
  }

  ListView _devicesListView(data) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _tile(data[index]);
        });
  }

  Card _tile(data) {
    double _modelFontSize = 24;
    double _addressFontSize = 18;
    double _detailsFontSize = 16;
    return Card(
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: false,
        children: _option == "Alarms" ? <Widget>[
          AlarmView(scaffoldKey, data.deviceID)
        ] : [],
        backgroundColor: Colors.transparent,
        onExpansionChanged: (val) async {
          if (_option == "Report") {
            showDialog(
                context: context,
                builder: (context) {
                  return ReportScreen();
                });
          }else if (_option == "Commands") {
            showDialog(
                context: context,
                builder: (context) {
                  return CommandsScreenDeprecated(data.vehicleModel);
                });
          }else if(_option == "Live") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VehicleLivePosition(deviceID: data.deviceID, option: _option),
              ),
            );
          }else if(_option == "History") {
            showDialog(
              // isScrollControlled: true,
              //   backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return HistoryScreen(data.deviceID, data.vehicleModel, _option);
                });
          }
        },
        leading: Icon(Icons.place, color: Colors.black,),
        title: Row(children: <Widget>[
          Icon(Icons.directions_car),
          Text(
            data.vehicleModel,
            style: TextStyle(fontSize: _modelFontSize, color: Colors.black),
          )
        ]),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: data.address,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: TextStyle(
                      color: Colors.lightBlue, fontSize: _addressFontSize),
                );
              },
            ),
            Text(
              "${data.timestampAsString} ${data.speedKPH} Km/h",
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
  }

  @override
  void dispose() {
    super.dispose();
  }
}
