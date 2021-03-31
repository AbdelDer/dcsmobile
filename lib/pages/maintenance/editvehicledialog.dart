import 'dart:convert';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/models/Device.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditVehicleDialog extends StatefulWidget {
  final deviceID;

  const EditVehicleDialog({Key key, this.deviceID}) : super(key: key);

  @override
  _EditVehicleDialogState createState() => _EditVehicleDialogState(deviceID);
}

class _EditVehicleDialogState extends State<EditVehicleDialog> {
  final deviceID;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey _dialogKey = GlobalKey();
  final _vehicleIDController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _odometerController = TextEditingController();

  Device _device;

  _EditVehicleDialogState(this.deviceID);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          controller: _vehicleModelController,
                          decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            labelText: "Nom",
                            hintText: "Nom",
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return "Nom est nécessaire";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _formKey.currentState.validate();
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z0-9 ]")),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _odometerController,
                          decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            labelText: "Kilométrage initial",
                            hintText: "Kilométrage initial",
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return "Kilométrage initial est nécessaire";
                            } else if (double.parse(value) < 0) {
                              return "Kilométrage initial doit être supérieur à 0";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _formKey.currentState.validate();
                          },
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
                            TextButton(
                              child: Text(
                                "close",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 18),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                              ),
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
                                if (_formKey.currentState.validate()) {
                                  _updateDevice();
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

  void _getDevice() async {
    EncryptedSharedPreferences preferences = EncryptedSharedPreferences();
    String accountID = await preferences.getString("accountID");
    Api.getDevice(jsonEncode({"accountID": accountID, "deviceID": deviceID})).then((_) {
      _device = _.responseBody;
      _vehicleModelController.text = _.responseBody.vehicleModel.toString();
      _odometerController.text = _.responseBody.lastOdometerKM.toString();
    }).catchError((err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$err')));
    });
  }

  void _updateDevice() {
    Api.updateDevice(jsonEncode({
      "accountID": _device.accountID,
      "deviceID": deviceID,
      "vehicleModel": _vehicleModelController.value.text,
      "lastOdometerKM": _odometerController.value.text
    })).then((value) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).translate("Updated")}')));
    }).catchError((err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$err')));
    });
  }
}
