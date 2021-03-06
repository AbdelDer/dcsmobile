import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:flutter/material.dart';

class Position extends StatefulWidget {
  final _description;
  final _option;

  Position(this._description, this._option) : super();

  @override
  _PositionState createState() =>
      _PositionState(this._description, this._option);
}

class _PositionState extends State<Position> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<VehicleListViewState> _deviceListViewKey =
      GlobalKey<VehicleListViewState>();
  final _description;
  final _option;

  VehicleListView _deviceListView;
  Widget _title;
  IconData _icon = Icons.search;

  _PositionState(this._description, this._option) {
    if (_option == "Live") {
      _title = Text("Position");
    } else {
      _title = Text(_option);
    }
  }

/*
 void initTitle(BuildContext context) {
    if (_option == 'Report') {
      _title = Text(AppLocalizations.of(context).translate('Report'));
    } else if (_option == 'History') {
      _title = Text(AppLocalizations.of(context).translate('History'));
    } else if (_option == 'Alarms') {
      _title = Text(AppLocalizations.of(context).translate("Alarms"));
    } else if (_option == "Live") {
      _title = Text(AppLocalizations.of(context).translate("Position"));
    } else if (_option == "Commands") {
      _title = Text(AppLocalizations.of(context).translate("Commands"));
    } else if (_option == "Maintenance") {
      _title = Text(AppLocalizations.of(context).translate(key));
    }
  }
 */
  @override
  void initState() {
    super.initState();
    setState(() {
      _deviceListView = VehicleListView(
          _scaffoldKey, _deviceListViewKey, _description, _option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: _title,
        actions: <Widget>[
          InkResponse(
            containedInkWell: true,
            splashColor: Colors.green.shade900,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            radius: 10,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(_icon),
            ),
            onTap: () {
              if (_icon == Icons.search) {
                _icon = Icons.close;
                setState(() {
                  _title = TextField(
                    autofocus: true,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                        hintText: "Cherche ...",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none),
                    onChanged: (newValue) {
                      _deviceListViewKey.currentState.setState(() {
                        _deviceListViewKey.currentState.search = newValue;
                      });
                      _deviceListViewKey.currentState.setState(() async {
                        await _deviceListViewKey.currentState.fetchDevices();
                      });
                    },
                  );
                });
              } else {
                setState(() {
                  _icon = Icons.search;
                  // if (_option == 'Report') {
                  //   _title = Text("Rapport");
                  // } else if (_option == 'History') {
                  //   _title = Text("Historique");
                  // } else if (_option == 'Alarms') {
                  //   _title = Text("Alarms");
                  // } else if (_option == "Live") {
                  //   _title = Text("Position");
                  // } else if (_option == "Commands") {
                  //   _title = Text("Commandes");
                  // }
                  if (_option == "Live") {
                    _title = Text("Position");
                  } else {
                    _title = Text(_option);
                  }
                });
                setState(() {
                  _deviceListViewKey.currentState.setState(() {
                    _deviceListViewKey.currentState.search = "";
                  });
                  _deviceListViewKey.currentState.setState(() async {
                    await _deviceListViewKey.currentState.fetchDevices();
                  });
                });
              }
            },
          ),
        ],
      ),
      drawer: FEDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height - 100,
              child: _deviceListView,
            ),
          ],
        ),
      ),
    );
  }
}
