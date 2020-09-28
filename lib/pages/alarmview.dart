import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

class AlarmView extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final _model;

  const AlarmView(this._scaffoldKey, this._model);

  @override
  _AlarmViewState createState() =>
      _AlarmViewState(_scaffoldKey, _model);
}

class _AlarmViewState extends State<AlarmView> {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final _model;

  _AlarmViewState(this._scaffoldKey, this._model);

  bool _isRunning = false;
  bool _isSpeedLimited = false;
  int _currentSpeedValue = 0;

  final _formKey = GlobalKey<FormState>();
  final _speedController = TextEditingController();
  final prefs = EncryptedSharedPreferences();

  _status() async {
    await prefs.getString("${this._model}, speed").then((speed) {
      if (speed == "-1" || speed == "") {
        setState(() {
          _isSpeedLimited = false;
        });
      } else {
        setState(() {
          _isSpeedLimited = true;
          _speedController.text = speed;
        });
      }
    }).catchError((onError) => null);
    await prefs.getString("${this._model}, running").then((running) {
      if (running == "0" || running == "") {
        setState(() {
          _isRunning = false;
        });
      } else {
        setState(() {
          _isRunning = true;
        });
      }
    }).catchError((onError) => null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _status(),
        builder: (context, snapshot) {
          return Card(
            elevation: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SwitchListTile(
                  activeColor: Colors.deepOrangeAccent,
                  value: _isSpeedLimited,
                  onChanged: (bool newValue) async {
                    if (_speedController.text.contains(RegExp(r","))) {
                      _speedController.text = _speedController.text
                          .replaceAll(new RegExp(r','), '.');
                    }
                    if (_speedController.text.length != 0 &&
                        !_speedController.text
                            .contains(RegExp(r"[A-Za-z ]|@|\+|-|\/|\*")) &&
                        _speedController.text.contains(RegExp(r"[0-9]")) &&
                        (double.parse(_speedController.text) >= 0 &&
                            double.parse(_speedController.text) <= 180)) {
                      setState(() {
                        _isSpeedLimited = newValue;
                      });
                    } else {
                      showBottomSheet(
                          context: context,
                          builder: (context) => Container(
                                color: Colors.deepOrange,
                                child: Center(
                                    child: Text(
                                  'entrez une valeur entre 0 et 180',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                                height: 50,
                                width: double.infinity,
                              ));
                      await Future.delayed(Duration(milliseconds: 1000));
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    }
                    if (_isSpeedLimited) {
                      await prefs.setString(
                          "${this._model}, speed", "${_speedController.text}");
                    } else {
                      await prefs.setString("${this._model}, speed", "-1");
                    }
                  },
                  title: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 8,
                        child: Text(
                            'Me notifier si la véhicule a dépassé la vitesse',
                            style: GoogleFonts.roboto(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Flexible(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: _speedController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  activeColor: Colors.deepOrangeAccent,
                  value: _isRunning,
                  onChanged: (bool newValue) async {
                    setState(() {
                      _isRunning = newValue;
                    });
                    if (newValue) {
                      await prefs.setString("${this._model}, running", "true");
                    } else {
                      await prefs.setString("${this._model}, running", "0");
                    }
                  },
                  title: Text(
                    'Me notifier si la véhicule a demarré',
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
