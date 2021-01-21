import 'dart:async';
import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/lang/app_localizations.dart';
import 'package:dcsmobile/main.dart';
import 'package:dcsmobile/pages/reportscreen.dart';
import 'package:dcsmobile/pages/subscriptionscreen.dart';
import 'package:dcsmobile/widgets/dashboard/customswipper.dart';
import 'package:dcsmobile/widgets/dashboard/dashboardsecondrow.dart';
import 'package:dcsmobile/widgets/dashboardbtn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'Position.dart';
import 'commandsscreen.dart';
import 'notificationsview.dart';

class Dashboard extends StatefulWidget {
  final RouteObserver<PageRoute> _routeObserver;

  const Dashboard(this._routeObserver);

  @override
  _DashboardState createState() => _DashboardState(_routeObserver);
}

class _DashboardState extends State<Dashboard>
    with RouteAware, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MediaQueryData mediaQuery;
  bool useMobileLayout;
  StreamController _streamController;
  Stream _stream;
  Timer _timer;
  final RouteObserver<PageRoute> _routeObserver;

  _DashboardState(this._routeObserver);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    _setTimerAndStream();
    // Covering route was popped off the navigator.
    // print('Popped A route ${_timer.isActive}');
  }

  @override
  void didPushNext() {
    // Route was pushed onto navigator and is now topmost route.
    _killApiCall();
    // print('Pushed A Route ${_timer.isActive}');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        //here if dashboard is displayed then we'll initialise the timer and streamController
        if (ModalRoute.of(context).isCurrent) _setTimerAndStream();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        //here if the app is in background then We'll stop the api call
        _killApiCall();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setTimerAndStream();
  }

  _setTimerAndStream() {
    setState(() {
      _streamController = new StreamController();
      _stream = _streamController.stream;
      _fetchData();
      _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
        await _fetchData();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _streamController.close();
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  _killApiCall() {
    setState(() {
      _timer.cancel();
      _streamController.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
    useMobileLayout = mediaQuery.size.shortestSide < 600;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('Dashboard'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                EncryptedSharedPreferences prefs = new EncryptedSharedPreferences();
                String userID = await prefs.getString("userID");
                String accountID = await prefs.getString("accountID");
                await FirebaseMessaging().deleteInstanceID();
                await Api.saveToken(accountID, userID, "").then((value) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
                });
              },
            ),
          )
        ],
      ),
      drawer: FEDrawer(),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(snapshot.error.toString()),
              ),
            );
            // ApiShowDialog.dialog(
            //     scaffoldKey: _scaffoldKey,
            //     message: '${snapshot.error}',
            //     type: 'error');
          } else if (snapshot.hasData) {
            return _content(snapshot.data);
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
    );
  }

  _fetchData() async {
    final prefs = EncryptedSharedPreferences();
    var accountID, userID;
    var list;
    await prefs.getString("accountID").then((value) {
      accountID = value;
    });
    await prefs.getString("userID").then((value) {
      userID = value;
    });
    List params = [accountID, userID];
    await Api.dashboardFirstRow(params).then((_) {
      if (_.message != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(_.message),
          ),
        );
        // ApiShowDialog.dialog(
        //     scaffoldKey: _scaffoldKey, message: '${_.message}', type: 'error');
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
    if (!_streamController.isClosed) {
      _streamController.add(list);
    }
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
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleOnTap('all'),
                        child: DashboardBtn(
                          quantity: data['firstRow']['all'],
                          description:
                              AppLocalizations.of(context).translate("All"),
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleOnTap('En marche'),
                        child: DashboardBtn(
                          quantity: data['firstRow']['moving'],
                          description:
                              AppLocalizations.of(context).translate("Moving"),
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleOnTap('En parking'),
                        child: DashboardBtn(
                          quantity: data['firstRow']['parked'],
                          description:
                              AppLocalizations.of(context).translate("Parked"),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleOnTap('late'),
                        child: DashboardBtn(
                          quantity: data['firstRow']['late'],
                          description:
                              AppLocalizations.of(context).translate("Late"),
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleOnTap('renewal'),
                        child: DashboardBtn(
                          quantity: data['firstRow']['renewal'],
                          description:
                              AppLocalizations.of(context).translate("Renewal"),
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleOnTap('alert'),
                        child: DashboardBtn(
                          // quantity: data['Alerte'],
                          quantity: 0,
                          description:
                              AppLocalizations.of(context).translate("Alerts"),
                          color: Colors.red,
                        ),
                      ),
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
                color: Colors.greenAccent,
              )),
              GestureDetector(
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                        child: Text(
                          AppLocalizations.of(context).translate("More"),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Position("all", "Live"),
                      ),
                    );
                  }),
              Expanded(
                  child: Divider(
                thickness: 2,
                color: Colors.greenAccent,
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
                DashboardSecondRow(
                    maxSpeed: data['maxSpeed'],
                    maxDistance: data['maxDistance'],
                    maxRunningTime: data['maxRunningTime']),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: Divider(
                      thickness: 2,
                      color: Colors.greenAccent,
                    )),
                    GestureDetector(
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: Text(
                                AppLocalizations.of(context).translate("More"),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportScreen(),
                            ),
                          );
                        }),
                    Expanded(
                        child: Divider(
                      thickness: 2,
                      color: Colors.greenAccent,
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

  _handleOnTap(description) {
    if (description == 'late') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommandsScreen(
            initIndex: 1,
            title: AppLocalizations.of(context).translate("Commands"),
          ),
        ),
      );
    } else if (description == 'renewal') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionScreen(),
        ),
      );
    } else if (description == "alert") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationsView(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Position(description, "Live"),
        ),
      );
    }
  }
}
