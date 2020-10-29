import 'package:dcsmobile/Api/Api.dart';
import 'package:dcsmobile/Api/ApiShowDialog.dart';
import 'package:dcsmobile/animations/fadeanimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _usernameController = TextEditingController();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
  var showIntroduction = false;

  @override
  void initState() {
    super.initState();
    _verifySavedInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [Colors.deepOrange, Colors.orange])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeAnimation(
                      1,
                      Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          FadeAnimation(
                              1.4,
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black45,
                                          blurRadius: 20,
                                          offset: Offset(0, 5))
                                    ]),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        controller: _accountController,
                                        decoration: InputDecoration(
                                            labelText: "Compte",
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                            hintText: "Compte",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                        onChanged: (context) {
                                          _formKey.currentState.validate();
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Nom du Compte est obligatoire";
                                          } else if (value.contains(new RegExp(
                                              r"[0-9]|@|\+|-|\/|\*"))) {
                                            return "Nom du compte doit contenir seuelement des alphabets";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                            labelText: "Utilisateur",
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                            hintText: "Utilisateur",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                        onChanged: (context) {
                                          _formKey.currentState.validate();
                                        },
                                        validator: (String value) {
                                          /*if (value.isEmpty) {
                                            return "nom d'utilisateur est obligatoire";
                                          }*/
                                          /*else if (value.contains(new RegExp(
                                              r"[0-9]|@|\+|-|\/|\*"))) {
                                            return "Nom d'utlisateur doit contenir seuelement des alphabets";
                                          }*/
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey[200]))),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            labelText: "Mot de passe",
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                            hintText: "Mot de passe",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none),
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Mot de passe est obligatoire";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          FadeAnimation(
                            1.6,
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.deepOrange,
                                          Colors.orange
                                        ]),
                                    color: Colors.cyanAccent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 20,
                                          offset: Offset(0, 5))
                                    ]),
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (_formKey.currentState.validate())
                                  _login(null);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _login(params) async {
    //first we verify if we will use user inputs or saved information
    if (params != null) {
      _accountController.text = params[0];
      _usernameController.text = params[1];
      _passwordController.text = params[2];
    }
    if (params == null) {
      params = [
        _accountController.text,
        _usernameController.text,
        _passwordController.text
      ];
      await Api.login(params).then((_) async {
        if (_.message != null && _.message.length != 0) {
          ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: _.message, type: 'error');
        } else {
          await saveLoginInfo();
          //here if it's the first time the user uses the app we'll show a guide, else we will navigate to dashboard
          if(showIntroduction) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/introduction', (Route<dynamic> route) => false);
          }
          else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/dashboard', (Route<dynamic> route) => false);
          }
        }
      }).catchError((err) {
        ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: err, type: 'error');
      });
    }
  }

  //here we verify if we have already login data (username, password, account) stored in device.
  void _verifySavedInfo() async {
    var userID, accountID, pass;
    bool error = false;
    await encryptedSharedPreferences
        .getString("userID")
        .then((value) => userID = value)
        .catchError((onError) => error = true);
    await encryptedSharedPreferences
        .getString("accountID")
        .then((value) => accountID = value)
        .catchError((onError) => error = true);
    await encryptedSharedPreferences
        .getString("password")
        .then((value) => pass = value)
        .catchError((onError) => error = true);
    if (pass == "") {
      showIntroduction = true;
    }
    if(!error) {
      _login([accountID, userID, pass]);
    }
  }

  //here we store login data (username, password, account)
  saveLoginInfo() async{
//    await encryptedSharedPreferences.clear();
    if (_usernameController.text != '') {
      //here we do Api query to get groupid of user because we need it in all other pages
      // await Api.userGroup(
      //     _accountController.text, _usernameController.text)
      //     .then((response) async{
      //   await encryptedSharedPreferences.setString(
      //       "groupID", response.responseBody.groupID);
      // }).catchError((err) => ApiShowDialog.dialog(scaffoldKey: _scaffoldKey, message: err, type: 'error'));

      await encryptedSharedPreferences.setString(
          "userID", _usernameController.text);
    } else {
      await encryptedSharedPreferences.setString(
          "userID", '');
    }
    await encryptedSharedPreferences.setString(
        "accountID", _accountController.text);
    await encryptedSharedPreferences.setString(
        "password", _passwordController.text);
  }
}
