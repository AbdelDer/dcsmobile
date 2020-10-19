import 'dart:io';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/widgets/dashboard/customswipper.dart';
import 'package:dcsmobile/widgets/dashboardbtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import '../widgets/dashboard/dashboardsecondrow.dart';
import 'Position.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MediaQueryData mediaQuery;
  bool useMobileLayout;

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
    useMobileLayout = mediaQuery.size.shortestSide < 600;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false),
            ),
          )
        ],
      ),
      drawer: FEDrawer(),
      body: FutureBuilder(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              ApiShowDialog.dialog(
                  scaffoldKey: _scaffoldKey,
                  message: '${snapshot.error}',
                  type: 'error');
            } else if (snapshot.hasData) {
              return _content(snapshot.data);
            }
          } else if (snapshot.connectionState == ConnectionState.none) {
            ApiShowDialog.dialog(
                scaffoldKey: _scaffoldKey,
                message: 'Problème de connexion',
                type: 'error');
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  _fetchData() async {
    final prefs = EncryptedSharedPreferences();
    var accountID, userID;
    await prefs.getString("accountID").then((value) {
      accountID = value;
    });
    await prefs.getString("userID").then((value) {
      userID = value;
    });
    List params = [accountID, userID];
    var list;
    await Api.dashboardFirstRow(params).then((_) {
      if (_.message != null) {
        ApiShowDialog.dialog(
            scaffoldKey: _scaffoldKey, message: '${_.message}', type: 'error');
      } else {
        list = _.data;
      }
    }).catchError((err) {
      ApiShowDialog.dialog(
          scaffoldKey: _scaffoldKey, message: err, type: 'error');
    });
    return list;
  }

  _content(data) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    DashboardBtn(
                      quantity: data['all'],
                      description: 'Tous',
                      color: Colors.blue,
                    ),
                    DashboardBtn(
                      quantity: data['moving'],
                      description: 'En marche',
                      color: Colors.green,
                    ),
                    DashboardBtn(
                      quantity: data['parked'],
                      description: 'En parking',
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  children: [
                    DashboardBtn(
                      quantity: data['late'],
                      description: 'En retard',
                      color: Colors.yellow,
                    ),
                    DashboardBtn(
                      quantity: data['renewal'],
                      description: 'Renouvellement',
                      color: Colors.brown,
                    ),
                    DashboardBtn(
                      // quantity: data['Alerte'],
                      quantity: 0,
                      description: 'Alerte',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(children: <Widget>[
              Expanded(
                  child: Divider(
                thickness: 2,
                color: Colors.orangeAccent,
              )),
              GestureDetector(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                      child: Text(
                        '+ PLUS DE DETAILS',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Position("Tous", "Live"),
                  ),
                ),
              ),
              Expanded(
                  child: Divider(
                thickness: 2,
                color: Colors.orangeAccent,
              )),
            ]),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
            ),
            child: Column(
              children: <Widget>[
                DashboardSecondRow(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.orangeAccent,
                        )),
                    GestureDetector(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                            child: Text(
                              '+ PLUS DE DETAILS',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Position("Tous", "Report"),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.orangeAccent,
                        )),
                  ]),
                ),
                CustomSwipper(
                  mediaQuery: mediaQuery,
                  data: data,
                ),
              ],
            ),
          ),
          // Container(color: Colors.green, width: mediaQuery.size.width, height: mediaQuery.size.height*0.6,child: CustomSwipper(mediaQuery: mediaQuery,),)
        ],
      ),
    );
  }
}
