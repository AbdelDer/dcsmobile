import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/widgets/devicecard.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleListView<T> extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Key _key;
  final _description;
  final _option;

  VehicleListView(this._scaffoldKey, this._key, this._description, this._option)
      : super(key: _key);

  @override
  VehicleListViewState createState() {
    return VehicleListViewState(
        this._scaffoldKey, this._key, this._description, this._option);
  }
}

class VehicleListViewState extends State {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Key _key;
  final _description;
  final _option;
  String search = "";
  final GlobalKey<DeviceCardState> _deviceCardKey =
      GlobalKey<DeviceCardState>();

  StreamController _streamController;
  Stream _stream;

  VehicleListViewState(
      this._scaffoldKey, this._key, this._description, this._option);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(snapshot.error),
            ),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data.message != null) {
            return Center(
              child: Text(
                snapshot.data.message,
                style: TextStyle(fontSize: 20),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => fetchDevices(),
              color: Colors.greenAccent,
              backgroundColor: Colors.green[900],
              child: DeviceCard(snapshot.data.responseBody, _option,
                  _scaffoldKey, _deviceCardKey),
            );
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> fetchDevices() async {
    final prefs = EncryptedSharedPreferences();
    //in this case if user connected using only accountID params will be [accountID, null], in the Api class
    //we will find devices of an account not use and vice versa.
    List<String> params = [
      await prefs.getString("accountID"),
      await prefs.getString("userID") ?? '',
      this._description,
      this.search
    ];

    await Api.devices(params).then((_) {
      _streamController.add(_);
      _deviceCardKey?.currentState?.setState(() {
        _deviceCardKey.currentState.data = _.responseBody;
      });
    }).catchError((err) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
