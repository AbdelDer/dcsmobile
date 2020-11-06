import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/pages/HistoryScreen.dart';
import 'package:dcsmobile/pages/ReportView(deprecated).dart';
import 'package:dcsmobile/pages/commandsdialog.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:dcsmobile/widgets/devicecard.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

import '../vehicleliveposition.dart';

class VehicleListView<T> extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Key _key;
  final _description;
  final _option;

  VehicleListView(this._scaffoldKey, this._key, this._description, this._option)
      : super(key: _key);

  @override
  VehicleListViewState createState() {
    return VehicleListViewState(this._scaffoldKey, this._key, this._description, this._option);
  }
}

class VehicleListViewState extends State {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Key _key;
  final _description;
  final _option;
  String search = "";

  VehicleListViewState(this._scaffoldKey, this._key, this._description,
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
                scaffoldKey: _scaffoldKey,
                message: '${snapshot.error}',
                type: 'error');
          } else if (snapshot.hasData) {
              if(snapshot.data.message != null) {
                return Center(
                  child: Text(
                    snapshot.data.message,
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                );
              }else {
                return SingleChildScrollView(child: DeviceCard(snapshot.data.responseBody, _option, _scaffoldKey));
              }
          }
        } else if (snapshot.connectionState == ConnectionState.none) {
          ApiShowDialog.dialog(
              scaffoldKey: _scaffoldKey,
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

    Response response;

    await Api.devices(params).then((_) {
      response = _;
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: err, type: 'error');
    });
    yield response;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
