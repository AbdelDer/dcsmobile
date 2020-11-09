import 'dart:async';
import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/draining.dart';
import 'package:dcsmobile/widgets/customdatepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DrainingScreen extends StatefulWidget {
  final String vehicleModel;
  final String deviceID;

  const DrainingScreen({@required this.vehicleModel, @required this.deviceID});

  @override
  _DrainingScreenState createState() =>
      _DrainingScreenState(this.vehicleModel, this.deviceID);
}

class _DrainingScreenState extends State<DrainingScreen> {
  final String _vehicleModel;
  final String _deviceID;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _drainingController = TextEditingController();
  final _kmStartController = TextEditingController();
  final _kmEndController = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  //we will save the date chose by user as unix timestamp
  num _timestampChose = DateTime.now().millisecondsSinceEpoch * 1000;

  _DrainingScreenState(this._vehicleModel, this._deviceID);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _getDrainingData();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            splashColor: Colors.deepOrange,
            highlightColor: Colors.orangeAccent.shade400,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return _dialog();
                  });
            },
          ),
        ],
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Draining",
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                _vehicleModel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            )
          ],
        ),
      ),
      drawer: FEDrawer(),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.status == Status.ERROR) {
              return Center(
                child: Text(
                  snapshot.data.message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.responseBody.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(
                        snapshot.data.responseBody[index].timestamp.toString()),
                    background: _slideRightBackground(),
                    secondaryBackground: _slideLeftBackground(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        //here if the user want to delete the item first we'll
                        //show a confirmation dialog
                        return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content:
                                    Text("Are you sure you want to delete?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () async{
                                      // TODO: Delete the item from DB etc..
                                      await _deleteDraining(snapshot.data.responseBody[index].timestamp);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                      //if user would edit the item
                      return true;
                    },
                    onDismissed: (direction) async{
                      if (direction == DismissDirection.endToStart) {
                        print('to delete');
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _dialog(
                                  data: snapshot.data.responseBody[index]);
                            });
                      }
                    },
                    child: InkWell(
                      onTap: () => print('element tapped'),
                      child: ListTile(
                        leading: Icon(
                          Icons.directions_car,
                          color: Colors.black,
                        ),
                        title: Text(
                          snapshot.data.responseBody[index].drainingName,
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                snapshot.data.responseBody[index].timestamp *
                                    1000))),
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  _getDrainingData() async {
    Api.getDraining(jsonEncode({"deviceID": _deviceID})).then((value) {
      _streamController.add(value);
      print(value);
    }).catchError((error) {});
  }

  Widget _slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  Widget _dialog({data}) {
    //editing case
    if (data != null) {
      _drainingController.value = TextEditingValue(text: data.drainingName);
      _kmStartController.value = TextEditingValue(text: '${data.kmStart}');
      _kmEndController.value = TextEditingValue(text: '${data.kmEnd}');
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        // color: Colors.white,
        height: 350,
        width: 250,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _drainingController,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    labelText: "Draining",
                    hintText: "Draining",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextFieldDatePicker(
                    lastDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    initialDate: data != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            data.timestamp * 1000)
                        : DateTime.now().subtract(Duration(minutes: 1)),
                    onDateChanged: (date) {
                      _timestampChose = date.millisecondsSinceEpoch / 1000;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _kmStartController,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    labelText: "Km start",
                    hintText: "Km start",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _kmEndController,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    labelText: "Km end",
                    hintText: "Km end",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      child: Text(
                        "close",
                        style:
                            TextStyle(color: Colors.deepOrange, fontSize: 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton.icon(
                      color: Colors.white,
                      icon: Icon(
                        Icons.save_alt,
                        color: Colors.black,
                      ),
                      label: Text(
                        "Save",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () async {
                        if (data != null) {
                          await _updateDraining();
                        } else {
                          await _saveDraining();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _updateDraining() {}

  _saveDraining() async{
    Draining draining = Draining(
        _deviceID,
        _drainingController.value.text,
        _timestampChose,
        double.parse(_kmStartController.value.text),
        double.parse(_kmEndController.value.text));
    await Api.saveDraining(jsonEncode(draining.toJson())).then((value) async{
      await _getDrainingData();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("added"),
      ));
      Navigator.of(context).pop();
    }).catchError((error) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
    });
  }

  _deleteDraining(timestamp) async{
    print(jsonEncode(Draining.id(_deviceID, timestamp).idToJson()));
    await Api.deleteDraining(
            jsonEncode(Draining.id(_deviceID, timestamp).idToJson()))
        .then((value) {
          print('value is $value');
      if (value.status == Status.ERROR) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(value.responseBody.message),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("removed"),
        ));
        _getDrainingData();
      }
    }).catchError((error) {
      ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
    });
  }
}