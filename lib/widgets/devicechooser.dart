import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class DeviceChooser extends StatefulWidget {
  
  final GlobalKey<ScaffoldState> _scaffoldKey;


  DeviceChooser(this._scaffoldKey);

  @override
  _DeviceChooserState createState() => _DeviceChooserState(this._scaffoldKey);
}

class _DeviceChooserState extends State<DeviceChooser> {
  final _searchController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey;
  StreamController _streamController;
  Stream _stream;

  double _modelFontSize = 24;
  double _addressFontSize = 18;
  double _detailsFontSize = 16;

  _DeviceChooserState(this._scaffoldKey);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _fetchDevices();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.height / 2,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
                child: Container(
                  height: 60,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.blue),
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        // labelText: "Compte",
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        // labelStyle: TextStyle(
                        //   color: Colors.black,
                        //   fontSize: 14,
                        // ),
                        hintText: "chercher un véhicule",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                    onChanged: (context) async{
                      // _formKey.currentState.validate();
                        await _fetchDevices();
                    },
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Nom du véhicule est obligatoire";
                      } else if (value
                          .contains(new RegExp(r"@|\+|-|\/|\*"))) {
                        return "Nom du véhicule doit contenir seuelement des alphabets ou des chiffres";
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context, ["Tous les Véhicules", ""]);
              },
              child: Card(
                color: Colors.white,
                child: ListTile(
                  title: Row(children: <Widget>[
                    Icon(Icons.directions_car),
                    Text(
                      "Tous les véhicules",
                      style: TextStyle(
                          fontSize: _modelFontSize, color: Colors.black),
                    )
                  ]),
                ),
              ),
            ),
            StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // ApiShowDialog.dialog(
                  //     scaffoldKey: _scaffoldKey,
                  //     message: '${snapshot.error}',
                  //     type: 'error');
                } else if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context, [snapshot.data[index].vehicleModel, snapshot.data[index].deviceID]);
                            },
                            child: Card(
                              color: Colors.white,
                              child: ListTile(
                                title: Row(children: <Widget>[
                                  Icon(Icons.directions_car),
                                  Text(
                                    snapshot.data[index].vehicleModel,
                                    style: TextStyle(
                                        fontSize: _modelFontSize, color: Colors.black),
                                  )
                                ]),
                              ),
                            ),
                          );
                        });
                } else if (snapshot.connectionState == ConnectionState.none) {
                  // ApiShowDialog.dialog(
                  //     scaffoldKey: _scaffoldKey,
                  //     message: 'Problème de connexion',
                  //     type: 'error');
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  _fetchDevices() async {
    final prefs = EncryptedSharedPreferences();
    //in this case if user connected using only accountID params will be [accountID, null], in the Api class
    //we will find devices of an account not use and vice versa.
    List<String> params = [
      await prefs.getString("accountID"),
      await prefs.getString("userID") ?? '',
      "all",
      _searchController.text ?? '',
    ];

    await Api.devices(params).then((_) {
      if (_.message != null) {
        /*ApiShowDialog.dialog(
            scaffoldKey: _scaffoldKey,
            message: search == '' ? _.message : _.message + ' de ce modèle',
            type: 'error');*/
      } else {
        _streamController.add(_.responseBody);
      }
    }).catchError((err) {
      /*ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: err, type: 'error');*/
    });
  }
}
