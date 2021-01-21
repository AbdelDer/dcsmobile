import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  final _title;

  ReportScreen(this._title) : super();

  @override
  _ReportScreenState createState() => _ReportScreenState(this._title);
}

class _ReportScreenState extends State<ReportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<VehicleListViewState> _deviceListViewKey =
  GlobalKey<VehicleListViewState>();
  final _title;
  final _description = "all";
  final _option = "";
  var _selectedType;
  var _selectedModel;
  DateTime _pickedDateTimeStart = DateTime.now();
  DateTime _pickedDateTimeEnd = DateTime.now();
  var _textStyle = TextStyle(
    color: Colors.black,
  );

  _ReportScreenState(this._title);

  fetchDevices() async* {
    final prefs = EncryptedSharedPreferences();
    //in this case if user connected using only accountID params will be [accountID, null], in the Api class
    //we will find devices of an account not use and vice versa.
    /*List<String> params = [
      await prefs.getString("accountID"),
      await prefs.getString("userID") ?? '',
      "demo",
      "",
      this._description,
      // this.search
    ];*/
    List<String> params = ['demo', '', this._description, ''];

    var list = [];

    await Api.devices(params).then((_) {
      if (_.message != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Something wrong !'),
          ),
        );
        // ApiShowDialog.dialog(
        //     scaffoldKey: _scaffoldKey,
        //     // message: search == '' ? _.message : _.message + ' de ce modèle',
        //     message: 'this is test msg',
        //     type: 'error');
      } else {
        list = _.responseBody;
      }
    }).catchError((err) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(err.toString()),
        ),
      );
      // ApiShowDialog.dialog(
      //     scaffoldKey: _scaffoldKey, message: err, type: 'error');
    });
    yield list;
  }

  _dropDownMenuButton(List data) {
    return DropdownButton(
      hint: Text("choisir un véhicule ou tous"),
      value: _selectedModel,
      onChanged: (value) {
        setState(() {
          _selectedModel = value;
        });
      },
      items: data.map((ed) {
        return DropdownMenuItem<dynamic>(
          value: ed._vehicleModel,
          child: Text("${ed._vehicleModel}"),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('$_title'),
      ),
      backgroundColor: Colors.white,
      drawer: FEDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 8,
              ),
              Center(
                child: Text(
                  "Rapport",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: DropdownButton(
                    onChanged: (Value) {
                      setState(() {
                        _selectedType = Value;
                      });
                    },
                    hint: Text(
                      "Choisissez le type du rapport",
                      style: _textStyle,
                    ),
                    value: _selectedType,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          "Rapport de consommation",
                          style: _textStyle,
                        ),
                        value: "Rapport de consommation",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Maintenance",
                          style: _textStyle,
                        ),
                        value: "Maintenance",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Rapport sommaire",
                          style: _textStyle,
                        ),
                        value: "Rapport sommaire",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Rapport de vitesse",
                          style: _textStyle,
                        ),
                        value: "Rapport de vitesse",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Température",
                          style: _textStyle,
                        ),
                        value: "Température",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Probe",
                          style: _textStyle,
                        ),
                        value: "Probe",
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Comportement du conducteur",
                          style: _textStyle,
                        ),
                        value: "Comportement du conducteur",
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "Liste des véhicules: ",
                style: TextStyle(fontSize: 16),
              ),
              StreamBuilder(
                stream: fetchDevices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(snapshot.error),
                        ),
                      );
                      // ApiShowDialog.dialog(
                      //     scaffoldKey: _scaffoldKey,
                      //     message: '${snapshot.error}',
                      //     type: 'error');
                    } else if (snapshot.hasData) {
                      return _dropDownMenuButton(snapshot.data);
                    }
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Problème de connexion'),
                      ),
                    );
                    // ApiShowDialog.dialog(
                    //     scaffoldKey: _scaffoldKey,
                    //     message: 'Problème de connexion',
                    //     type: 'error');
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("Date début:"),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: GestureDetector(
                    onTap: () async{
                      _pickDateTime("start");
                    },
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${_pickedDateTimeStart.year}-${_pickedDateTimeStart.month}-${_pickedDateTimeStart.day} ${_pickedDateTimeStart.hour}:${_pickedDateTimeStart.minute}"),
                          Icon(Icons.keyboard_arrow_down),
                        ]),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("Date fin:"),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: GestureDetector(
                      onTap: () async{
                        await _pickDateTime("end");
                      },
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "${_pickedDateTimeEnd.year}-${_pickedDateTimeEnd.month}-${_pickedDateTimeEnd.day} ${_pickedDateTimeEnd.hour}:${_pickedDateTimeEnd.minute}"),
                            Icon(Icons.keyboard_arrow_down),
                          ]),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.green, Colors.green]),
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: Center(
                      child: Text(
                        "Valider",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onTap: () => null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pickDateTime(startOrEnd) async {
    DateTime pickedDate;
    TimeOfDay time;
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      pickedDate = date;
    }
    TimeOfDay t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      time = t;
    }
    setState(() {
      if(startOrEnd == "start") {
        _pickedDateTimeStart = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, time.hour, time.minute);
      } else {
        _pickedDateTimeEnd = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, time.hour, time.minute);
      }

    });
  }
}
