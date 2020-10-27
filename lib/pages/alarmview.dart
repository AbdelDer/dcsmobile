import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

class AlarmView extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final _vehicleModel;
  final _deviceID;

  const AlarmView(this._scaffoldKey, this._vehicleModel, this._deviceID);

  @override
  _AlarmViewState createState() =>
      _AlarmViewState(_scaffoldKey, this._vehicleModel, this._deviceID);
}

class _AlarmViewState extends State<AlarmView> {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final _vehicleModel;
  final _deviceID;

  _AlarmViewState(this._scaffoldKey, this._vehicleModel, this._deviceID);

  final _formKey = GlobalKey<FormState>();
  final _speedController = TextEditingController();
  final prefs = EncryptedSharedPreferences();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getDeviceAlarmSettings(),
        builder: (context, snapshot) {
          return null;
        });
  }

  _getDeviceAlarmSettings() async{
    var _body;
        String _userID = await _encryptedSharedPreferences.getString("userID");
        String _accountID =
            await _encryptedSharedPreferences.getString("accountID");
        if (_deviceID == "" && _userID == '') {
          _body = jsonEncode({
            'accountID': _accountID,
          });
        } else if (_deviceID == '' && _userID != '') {
          _body = jsonEncode({
            'userID': _userID,
          });
        } else {
          _body = jsonEncode({
            'deviceID': _deviceID,
          });
        }

        return Api.getSummaryReport(_body).then(
          (value) {
            return value.responseBody[0];
          },
        ).catchError(
          (error) => ApiShowDialog.dialog(
              scaffoldKey: _scaffoldKey, message: error, type: 'error'),
        );
  }
}
