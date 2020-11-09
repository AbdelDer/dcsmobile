import 'dart:async';

import 'package:dcsmobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Draining extends StatefulWidget {
  final String vehicleModel;
  final String deviceID;

  const Draining({@required this.vehicleModel, @required this.deviceID});

  @override
  _DrainingState createState() =>
      _DrainingState(this.vehicleModel, this.deviceID);
}

class _DrainingState extends State<Draining> {
  final String _vehicleModel;
  final String _deviceID;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _drainingController = TextEditingController();
  final _dateController = TextEditingController();
  final _kmStartController = TextEditingController();
  final _kmEndController = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  _DrainingState(this._vehicleModel, this._deviceID);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
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
            if (snapshot.data.message != null) {
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
                    key: Key(snapshot.data.responseBody[index]),
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
                                    onPressed: () {
                                      // TODO: Delete the item from DB etc..
                                      setState(() {
                                        // itemsList.removeAt(index);
                                      });
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
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        //delete
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _dialog(data: snapshot.data.respnseBody[index]);
                            });
                      }
                    },
                    child: InkWell(
                      onTap: () => print('element tapped'),
                      child: ListTile(
                        leading: Icon(Icons.directions_car),
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

  _getDrainingData() async {}

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
    if(data != null) {
      _drainingController.value = TextEditingValue(text: data.drainingName);
      _dateController.value = TextEditingValue(text: data.timestamp);
      _kmStartController.value = TextEditingValue(text: data.kmStart);
      _kmEndController.value = TextEditingValue(text: data.kmEnd);
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
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    labelText: "Date",
                    hintText: "Date",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                  ],
                ),
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
                      onPressed: () {},
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
}
