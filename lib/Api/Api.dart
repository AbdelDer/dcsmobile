import 'dart:convert';
import 'dart:io';

import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/models/Account.dart';
import 'package:dcsmobile/models/Device.dart';
import 'package:dcsmobile/models/DeviceList.dart';
import 'package:dcsmobile/models/EventData.dart';
import 'package:dcsmobile/models/Group.dart';
import 'package:dcsmobile/models/Report.dart';
import 'package:dcsmobile/models/User.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'HttpCustom.dart';

class Api {
  static final httpClient = HttpClient();

  // static final baseUrl = 'http://31.207.38.29:9090';
//  static final baseUrl = 'http://192.168.1.254:9090';
//  static final baseUrl = 'http://192.168.1.6:9090';
  static final baseUrl = 'http://192.168.1.4:9090';

  static Future<Response> login(params) async {
    await connected();
    var body;
    var httpCustom;
    if (params[1] == '' || params[1] == null) {
      body = jsonEncode({'accountID': params[0], 'password': params[2]});
      httpCustom =
          HttpCustom(url: '$baseUrl/account/login', body: body);
    } else {
      body = jsonEncode({
        'userID': {'userID': params[1], 'accountID': params[0]},
        'password': params[2]
      });
      httpCustom =
          HttpCustom(url: '$baseUrl/user/login', body: body);
    }
    final httpResponse = await httpCustom.post().catchError((
        err) => throw('erreur lié au serveur $err'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      String message = responseBody['message'];
      print("$message");
      return Response.error(message);
    }

    if (params[1] == '' || params[1] == null) {
      return Response.completed(
          Account.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
    } else {
      return Response.completed(
          User.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
    }
  }

  static Future<Response> userGroup(accountID, userID) async {
    await connected();
    var body = jsonEncode({
      'groupID': {'accountID': accountID, 'userID': userID}
    });
    final httpCustom =
    HttpCustom(url: '$baseUrl/user/group', body: body);

    final httpResponse = await httpCustom.post().catchError((
        err) => throw('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(
        Group.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
  }

  static Future<Response> devices(params) async {
    await connected();
    final prefs = EncryptedSharedPreferences();
    var body;
    var httpCustom;
    if (params[1] == null || params[1] == '') {
      body = jsonEncode({
        "accountID": params[0],
        "userID": params[1] ?? '',
        "search": params[3]
      });
      switch (params[2]) {
        case "Tous" :
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/account/devices', body: body);
            break;
          }
        case "En parking" :
          {
            httpCustom =
                HttpCustom(
                    url: '$baseUrl/account/parking/vehicles', body: body);
            break;
          }
        case "En marche" :
          {
            httpCustom =
                HttpCustom(
                    url: '$baseUrl/account/running/vehicles', body: body);
            break;
          }
      }
    } else {
      body = jsonEncode({
        "accountID": params[0],
        "userID": params[1] ?? '',
        "groupID": await prefs.getString("groupID"),
        "search": params[3]
      });
      switch (params[2]) {
        case "Tous" :
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/user/devices', body: body);
            break;
          }
        case "En parking" :
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/user/parking/vehicles', body: body);
            break;
          }
        case "En marche" :
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/user/running/vehicles', body: body);
            break;
          }
      }
    }

    final httpResponse = await httpCustom.post().catchError((
        err) => throw('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    /*if(params[1] == null || params[1] == '') {
      return Response.completed(responseBody.map((device) => Device.fromJson(device)).toList());
    } else {
      return Response.completed(responseBody.map((device) => DeviceList.fromJson(device)).toList());
    }*/
    return Response.completed(
        responseBody.map((eventData) => EventData.fromJson(eventData))
            .toList());
  }

  static Future<Response> dashboardFirstRow(params) async {
    // print('dash first row called');
    await connected();
    final prefs = EncryptedSharedPreferences();
    var body;
    var httpCustom;
    if (params[1] == null || params[1] == '') {
      body = jsonEncode({
        "accountID": params[0]
      });
      httpCustom =
          HttpCustom(url: '$baseUrl/account/vehicles', body: body);
    } else {
      body = jsonEncode({
        'accountID': params[0],
        'userID': params[1],
        'groupID': await prefs.getString("groupID")
      });
      httpCustom =
      HttpCustom(url: '$baseUrl/user/vehicles', body: body);
      }

      final httpResponse = await httpCustom.post().catchError((
          err) => throw('erreur lié au serveur'));
      var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

      if (httpResponse.statusCode != 200) {
        return Response.error(responseBody['message']);
      }
      /*if(params[1] == null || params[1] == '') {
      return Response.completed(responseBody);
    } else {
      return Response.completed(responseBody);
    }*/
      return Response.completed(responseBody);
    }

    static Future<Response> getHistory(deviceID) async {
      await connected();
      var body;
      var httpCustom;
      body = jsonEncode({
        "deviceID": deviceID
      });
      httpCustom =
          HttpCustom(url: '$baseUrl/solo/eventdataList', body: body);

      final httpResponse = await httpCustom.post().catchError((
          err) => throw('erreur lié au serveur'));
      var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

      if (httpResponse.statusCode != 200) {
        return Response.error(responseBody['message']);
      }
//    return Response.completed(EventData.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
      //for testing purposes
      return Response.completed(
          responseBody.map((eventdata) => EventData.fromJson(eventdata))
              .toList());
    }

    static Future<Response> getActualPosition(deviceID) async {
      await connected();
      var body;
      var httpCustom;
      body = jsonEncode({
        "deviceID": deviceID
      });
      httpCustom =
          HttpCustom(url: '$baseUrl/solo/eventdata', body: body);

      final httpResponse = await httpCustom.post().catchError((
          err) => throw('erreur lié au serveur'));
      var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

      if (httpResponse.statusCode != 200) {
        return Response.error(responseBody['message']);
      }
      return Response.completed(
          EventData.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
    }

    static Future<Response> getReport(deviceID) async {
      await connected();
      var body;
      var httpCustom;
      body = jsonEncode({
        "deviceID": deviceID
      });
      httpCustom =
          HttpCustom(url: '$baseUrl/report', body: body);

      final httpResponse = await httpCustom.post().catchError((
          err) => throw('erreur lié au serveur'));
      var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

      if (httpResponse.statusCode != 200) {
        return Response.error(responseBody['message']);
      }
      return Response.completed(
          Report.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
    }
    static connected() async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException catch (_) {
        throw('vérifier votre connexion');
      }
    }
  }
