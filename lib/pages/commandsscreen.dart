import 'dart:async';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/pages/Utils/VehicleListView.dart';
import 'package:dcsmobile/pages/commandsdialog.dart';
import 'package:flutter/material.dart';

class CommandsScreen extends StatefulWidget {
  final initIndex;
  final title;

  CommandsScreen({this.initIndex = 0, @required this.title});

  @override
  _CommandsScreenState createState() =>
      _CommandsScreenState(initIndex, this.title);
}

class _CommandsScreenState extends State<CommandsScreen>
    with SingleTickerProviderStateMixin {
  StreamController _streamController;
  Stream _stream;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<VehicleListViewState> _deviceListViewKey =
      GlobalKey<VehicleListViewState>();
  Widget _title;
  IconData _icon = Icons.search;
  TabController _tabController;
  int _selectedIndex;
  final initIndex;
  final titleString;

  _CommandsScreenState(this.initIndex, this.titleString);

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
                      if (_selectedIndex == 0) {
                        _deviceListViewKey.currentState.setState(() {
                          _deviceListViewKey.currentState.search = newValue;
                        });
                      } else {
                        fetchData(newValue);
                      }
                      if (_selectedIndex == 0) {
                        _deviceListViewKey.currentState.setState(() async {
                          await _deviceListViewKey.currentState.fetchDevices();
                        });
                      }
                    },
                  );
                });
              } else {
                setState(() {
                  _icon = Icons.search;
                  _title =
                      Text(AppLocalizations.of(context).translate("Commands"));
                });
                setState(() {
                  if (_selectedIndex == 0) {
                    _deviceListViewKey.currentState.setState(() {
                      _deviceListViewKey.currentState.search = "";
                    });
                    _deviceListViewKey.currentState.setState(() {
                      _deviceListViewKey.currentState.fetchDevices();
                    });
                  } else {
                    fetchData("");
                  }
                  /*if (_selectedIndex == 0) {
                    _deviceListViewKey.currentState.setState(() {
                      _deviceListViewKey.currentState.fetchDevices();
                    });
                  }*/
                });
              }
            },
          ),
        ],
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: [
            Tab(
              text: AppLocalizations.of(context).translate("All"),
            ),
            Tab(
              text: AppLocalizations.of(context).translate("Late"),
            )
          ],
        ),
      ),
      drawer: FEDrawer(),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height - 100,
                        child: VehicleListView(
                            _scaffoldKey,
                            _deviceListViewKey,
                            "all",
                            AppLocalizations.of(context).translate("Commands")),
                      ),
                    ],
                  ),
                ),
                StreamBuilder(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.status == Status.ERROR) {
                        return Center(
                            child: Text(
                          snapshot.data.message,
                          style: TextStyle(fontSize: 20),
                        ));
                      }
                      return ListView.builder(
                          itemCount: snapshot.data.responseBody.length,
                          itemBuilder: (context, index) {
                            double _modelFontSize = 16;
                            double _addressFontSize = 14;
                            double _detailsFontSize = 12;
                            return Card(
                              elevation: 2,
                              child: ExpansionTile(
                                initiallyExpanded: false,
                                backgroundColor: Colors.transparent,
                                onExpansionChanged: (val) async {
                                  //here open commands dialog
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CommandsDialog(
                                            snapshot.data.responseBody[index]
                                                .deviceID,
                                            snapshot.data.responseBody[index]
                                                .vehicleModel,
                                            snapshot.data.responseBody[index]
                                                .simPhoneNumber,
                                            snapshot.data.responseBody[index]
                                                    .late ??
                                                true);
                                      });
                                },
                                leading: Image.asset(
                                  'assets/icons/r_marker_blue.png',
                                  width: 30,
                                ),
                                title: Row(children: <Widget>[
                                  Icon(Icons.directions_car),
                                  Text(
                                    snapshot
                                        .data.responseBody[index].vehicleModel,
                                    style: TextStyle(
                                        fontSize: _modelFontSize,
                                        color: Colors.black),
                                  )
                                ]),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    FutureBuilder(
                                      future: snapshot
                                          .data.responseBody[index].address,
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data}',
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontSize: _addressFontSize),
                                        );
                                      },
                                    ),
                                    Text(
                                      "${snapshot.data.responseBody[index].timestampAsString} ${snapshot.data.responseBody[index].speedKPH.toStringAsFixed(2)} Km/h",
                                      style:
                                          TextStyle(fontSize: _detailsFontSize),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.network_wifi,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      // return ApiShowDialog.dialog(
                      //     scaffoldKey: _scaffoldKey,
                      //     message: snapshot.data.responseBody.message,
                      //     type: 'error');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(snapshot.data.responseBody.message),
                      ));
                      return SizedBox(
                        height: 0,
                        width: 0,
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
              controller: _tabController,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _title = Text(titleString);
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: initIndex);
    _selectedIndex = initIndex;
    if (initIndex == 1) {
      fetchData("");
    }
    _tabController.addListener(() async {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      if (_selectedIndex == 1) {
        await fetchData("");
      }
      setState(() {
        _icon = Icons.search;
        _title = Text(titleString);
      });
    });
    _streamController = StreamController.broadcast();
    _stream = _streamController.stream;
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  fetchData(search) async {
    await Api.late(search).then((r) {
      _streamController.add(r);
    }).catchError((err) {
      //   ApiShowDialog.dialog(
      //       scaffoldKey: _scaffoldKey, message: '${err}', type: 'error');
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
        ),
      );
    });
  }
}
