import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApiShowDialog{
  static dialog({scaffoldKey, message, type}) {
    if(Platform.isIOS) {
     return showDialog(
          context: scaffoldKey.currentContext,
          builder: (__) => CupertinoAlertDialog(
            title: Text('erreur', style: TextStyle(color: type =='error' ? Colors.red : Colors.blue),),
            content: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(child: Text('ok'),onPressed: () => Navigator.of(__).pop(),)
            ],
          ));
    }else {
      return showDialog(
          context: scaffoldKey.currentContext,
          builder: (__) => AlertDialog(
            title: Text('erreur', style: TextStyle(color: type =='error' ? Colors.red : Colors.blue),),
            content: Text(message),
            actions: <Widget>[
              FlatButton(child: Text('ok'),onPressed: () => Navigator.of(__).pop(),)
            ],
          ));
    }
  }
}
