import 'dart:io';

import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/animations/fadeanimation.dart';
import 'package:dcsmobile/commons/FEDrawer.dart';
import 'package:dcsmobile/commons/fancyappbar.dart';
import 'package:dcsmobile/widgets/dashboard/customswipper.dart';
import 'package:dcsmobile/widgets/dashboard/dashboardfirstrow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import '../widgets/dashboard/dashboardsecondrow.dart';

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
      // appBar: FancyAppBar(scaffoldKey: _scaffoldKey),
      drawer: FEDrawer(),
      body: FutureBuilder(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: '${snapshot.error}', type: 'error');
            } else if (snapshot.hasData) {
              return _content(snapshot.data);
            }
          } else if (snapshot.connectionState == ConnectionState.none) {
            ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: 'Problème de connexion', type: 'error');
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
    List params = [
      accountID,
      userID
    ];
    var list;
    await Api.dashboardFirstRow(params).then((_) {
      if (_.message != null) {
        ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: '${_.message}', type: 'error');
      } else {
        list = _.data;
      }
    }).catchError((err) {
      ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: err, type: 'error');
    });
    return list;
  }

  _content(data) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          FadeAnimation(
            1.6,
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                FancyAppBar(scaffoldKey: _scaffoldKey),
                // Padding(
                //   padding: EdgeInsets.only(top: 120),
                // ),
                DashboardFirstRow(_scaffoldKey, data),
              ],
            ),
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
                Divider(
                  height: 20,
                  color: Colors.black,
                ),
                FadeAnimation(
                  2.5,
                  CustomSwipper(mediaQuery: mediaQuery, data: data,),
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
