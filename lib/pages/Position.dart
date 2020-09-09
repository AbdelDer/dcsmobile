import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/models/Account.dart';
import 'package:dcsmobile/models/User.dart';
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
  double _modelFontSize = 24;
  double _adresseFontSize = 18;
  double _detailsFontSize = 16;
  Widget _title;
  IconData _icon = Icons.search;

  _PositionState(this._description, this._option) {
    if (_option == 'Report') {
      _title = Text("Rapport");
    } else if (_option == 'History') {
      _title = Text("Historique");
    } else if (_option == 'Notifications') {
      _title = Text("Notifications");
    } else if(_option == "Live"){
      _title = Text("Position");
    }
  }

  @override
  void initState() {
    setState(() {
      _deviceListView = VehicleListView(
          _scaffoldKey, _deviceListViewKey, _description, _option, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        title: _title,
        actions: <Widget>[
          InkResponse(
            containedInkWell: true,
            splashColor: Colors.orange.shade900,
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
                });
                if (_option == 'Report') {
                  _title = Text("Rapport");
                } else if (_option == 'History') {
                  _title = Text("Historique");
                } else if (_option == 'Notifications') {
                  _title = Text("Notifications");
                } else if(_option == "Live") {
                  _title = Text("Position");
                }
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
