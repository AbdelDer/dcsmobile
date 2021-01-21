import 'dart:async';
import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/models/insurance.dart';
import 'package:dcsmobile/widgets/customdatepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InsuranceScreen extends StatefulWidget {
  final String vehicleModel;
  final String deviceID;

  const InsuranceScreen({@required this.vehicleModel, @required this.deviceID});

  @override
  _InsuranceScreenState createState() =>
      _InsuranceScreenState(this.vehicleModel, this.deviceID);
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final String _vehicleModel;
  final String _deviceID;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  var _dialogKey = GlobalKey();

  final _nameController = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  //we will save the date chose by user as unix timestamp
  num _timestampStartChose =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch ~/
          1000;
  num _timestampEndChose =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch ~/
          1000;

  bool errorTimestampEndVisibility = false;
  bool errorTimestampStartVisibility = false;
  String errorTimestampStartMsg = "try to verify that you give a unique date";
  String errorTimestampEndMsg = "try to verify that you give a unique date";

  _InsuranceScreenState(this._vehicleModel, this._deviceID);

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _getInsuranceData();
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
            splashColor: Colors.green,
            highlightColor: Colors.greenAccent.shade400,
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
                AppLocalizations.of(context).translate("Insurance"),
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
                    key: Key(snapshot.data.responseBody[index].timestampStart
                        .toString()),
                    background: _slideRightBackground(),
                    secondaryBackground: _slideLeftBackground(),
                    confirmDismiss: (direction) async {
                      //in all cases we'll return false because we don't want to dismiss the item.
                      if (direction == DismissDirection.endToStart) {
                        //here if the user want to delete the item first we'll
                        //show a confirmation dialog
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content:
                                    Text("Are you sure you want to delete?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate("Cancel"),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate("Delete"),
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _deleteInsurance(
                                          snapshot.data.responseBody[index].id);
                                    },
                                  ),
                                ],
                              );
                            });
                        return false;
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _dialog(
                                  data: snapshot.data.responseBody[index]);
                            });
                        return false;
                      }
                    },
                    onDismissed: (direction) {},
                    child: InkWell(
                      child: ListTile(
                        leading: Icon(
                          Icons.directions_car,
                          color: Colors.black,
                        ),
                        title: Text(
                          snapshot.data.responseBody[index].name,
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                            '${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.responseBody[index].timestampStart * 1000))} | ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.responseBody[index].timestampEnd * 1000))}'),
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

  _getInsuranceData() async {
    Api.getInsurance(jsonEncode({"deviceID": _deviceID})).then((value) {
      _streamController.add(value);
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
              AppLocalizations.of(context).translate("Edit"),
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
              AppLocalizations.of(context).translate("Delete"),
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
      _nameController.value = TextEditingValue(text: data.name);
      _timestampStartChose = data.timestampStart;
      _timestampEndChose = data.timestampEnd;
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: StatefulBuilder(
          key: _dialogKey,
          builder: (context, snapshot) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              // color: Colors.white,
              // height: 350,
              // width: 250,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            labelText: "Insurance name",
                            hintText: "Insurance name",
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return "a name is necessary";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _formKey.currentState.validate();
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z0-9]")),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextFieldDatePicker(
                            labelText: 'start Date',
                            lastDate: DateTime.now(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 365)),
                            initialDate: data != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    data.timestampStart * 1000)
                                : DateTime.now().subtract(Duration(minutes: 1)),
                            onDateChanged: (date) {
                              _timestampStartChose =
                                  date.millisecondsSinceEpoch / 1000;
                            }),
                      ),
                      Visibility(
                          visible: errorTimestampStartVisibility,
                          child: Text(
                            errorTimestampStartMsg,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextFieldDatePicker(
                            labelText: 'end date',
                            lastDate: DateTime.now().add(Duration(days: 740)),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 365)),
                            initialDate: data != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    data.timestampEnd * 1000)
                                : DateTime.now().subtract(Duration(minutes: 1)),
                            onDateChanged: (date) {
                              _timestampEndChose =
                                  date.millisecondsSinceEpoch / 1000;
                              if (errorTimestampEndVisibility) {
                                _dialogKey.currentState.setState(() {
                                  errorTimestampEndVisibility =
                                      !errorTimestampEndVisibility;
                                });
                              }
                            }),
                      ),
                      Visibility(
                          visible: errorTimestampEndVisibility,
                          child: Text(
                            errorTimestampEndMsg,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          )),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlatButton(
                              child: Text(
                                AppLocalizations.of(context).translate("Close"),
                                style: TextStyle(
                                    color: Colors.green, fontSize: 18),
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
                                AppLocalizations.of(context)
                                    .translate("Validate"),
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState.validate() &&
                                    _timestampEndChose > _timestampStartChose) {
                                  if (errorTimestampEndVisibility) {
                                    _dialogKey.currentState.setState(() {
                                      errorTimestampEndVisibility =
                                          !errorTimestampEndVisibility;
                                    });
                                  }
                                  if (data != null) {
                                    await _updateInsurance(data?.id);
                                  } else {
                                    await _saveInsurance();
                                  }
                                } else if (_timestampEndChose <=
                                    _timestampStartChose) {
                                  _dialogKey.currentState.setState(() {
                                    errorTimestampEndMsg =
                                        "date end should be greater then start date";
                                    errorTimestampEndVisibility = true;
                                  });
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
          }),
    );
  }

  _updateInsurance(id) async {
    Insurance insurance = Insurance(id, _deviceID, _nameController.value.text,
        _timestampStartChose, _timestampEndChose);
    await Api.updateInsurance(jsonEncode(insurance.toJson()))
        .then((value) async {
      if (value.status == Status.ERROR) {
        _dialogKey.currentState.setState(() {
          if (value.message.contains('date start')) {
            errorTimestampStartVisibility = true;
            errorTimestampEndVisibility = false;
            errorTimestampStartMsg = "start date already exists";
          } else if (value.message.contains('date end')) {
            errorTimestampStartVisibility = false;
            errorTimestampEndVisibility = true;
            errorTimestampEndMsg = "end date already exists";
          }
        });
      } else {
        if (errorTimestampEndVisibility || errorTimestampStartVisibility) {
          _dialogKey.currentState.setState(() {
            errorTimestampEndVisibility = false;
            errorTimestampStartVisibility = false;
          });
        }
        _nameController.value = TextEditingValue(text: '');
        await _getInsuranceData();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).translate("Updated")),
        ));
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
      // ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
    });
  }

  _saveInsurance() async {
    Insurance insurance = Insurance.withoutID(_deviceID,
        _nameController.value.text, _timestampStartChose, _timestampEndChose);
    await Api.saveInsurance(jsonEncode(insurance.toJson())).then((value) async {
      if (value.status == Status.ERROR) {
        _dialogKey.currentState.setState(() {
          if (value.message.contains('date start')) {
            errorTimestampStartVisibility = true;
            errorTimestampEndVisibility = false;
            errorTimestampStartMsg = "start date already exists";
          } else if (value.message.contains('date end')) {
            errorTimestampStartVisibility = false;
            errorTimestampEndVisibility = true;
            errorTimestampEndMsg = "end date already exists";
          }
        });
      } else {
        if (errorTimestampEndVisibility || errorTimestampStartVisibility) {
          _dialogKey.currentState.setState(() {
            errorTimestampEndVisibility = false;
            errorTimestampStartVisibility = false;
          });
        }
        _nameController.value = TextEditingValue(text: '');
        await _getInsuranceData();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).translate("Updated")),
        ));
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
      // ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
    });
  }

  _deleteInsurance(id) async {
    await Api.deleteInsurance(jsonEncode(id)).then((value) {
      if (value.status == Status.ERROR) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(value.responseBody.message),
        ));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).translate("Removed")),
        ));
        _getInsuranceData();
      }
    }).catchError((error) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
      // ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: error.toString(), type: 'error');
    });
  }
}
