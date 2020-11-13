import 'dart:convert';
import 'dart:io';

import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/models/Account.dart';
import 'package:dcsmobile/models/EventData.dart';
import 'package:dcsmobile/models/Group.dart';
import 'package:dcsmobile/models/Report.dart';
import 'package:dcsmobile/models/Subscription.dart';
import 'package:dcsmobile/models/User.dart';
import 'package:dcsmobile/models/activity.dart';
import 'package:dcsmobile/models/alarm.dart';
import 'package:dcsmobile/models/draining.dart';
import 'package:dcsmobile/models/insurance.dart';
import 'package:dcsmobile/models/summaryreport.dart';
import 'package:dcsmobile/models/technicalvisit.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'HttpCustom.dart';

class Api {
  static final httpClient = HttpClient();

  // static final baseUrl = 'http://91.234.195.124:9090/api';
  // static final baseUrl = 'http://192.168.1.38:9090/api';
  static final baseUrl = 'http://192.168.100.22:9090/api';

  static Future<Response> login(params) async {
    await connected();
    var body;
    var httpCustom;
    if (params[1] == '' || params[1] == null) {
      body = jsonEncode({'accountID': params[0], 'password': params[2]});
      httpCustom = HttpCustom(url: '$baseUrl/account/login', body: body);
    } else {
      body = jsonEncode({
        'userID': {'userID': params[1], 'accountID': params[0]},
        'password': params[2]
      });
      httpCustom = HttpCustom(url: '$baseUrl/user/login', body: body);
    }
    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur $err'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      String message = responseBody['message'];
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
    final httpCustom = HttpCustom(url: '$baseUrl/user/group', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(
        Group.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
  }

  // TODO : remove params from devices parameters
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
        case "all":
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/account/devices', body: body);
            break;
          }
        case "En parking":
          {
            httpCustom = HttpCustom(
                url: '$baseUrl/account/parking/vehicles', body: body);
            break;
          }
        case "En marche":
          {
            httpCustom = HttpCustom(
                url: '$baseUrl/account/running/vehicles', body: body);
            break;
          }
      }
    } else {
      body = jsonEncode({
        "accountID": params[0],
        "userID": params[1] ?? '',
        // "groupID": await prefs.getString("groupID"),
        "search": params[3]
      });
      switch (params[2]) {
        case "all":
          {
            httpCustom = HttpCustom(url: '$baseUrl/user/devices', body: body);
            break;
          }
        case "En parking":
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/user/parking/vehicles', body: body);
            break;
          }
        case "En marche":
          {
            httpCustom =
                HttpCustom(url: '$baseUrl/user/running/vehicles', body: body);
            break;
          }
      }
    }

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    /*if(params[1] == null || params[1] == '') {
      return Response.completed(responseBody.map((device) => Device.fromJson(device)).toList());
    } else {
      return Response.completed(responseBody.map((device) => DeviceList.fromJson(device)).toList());
    }*/
    return Response.completed(responseBody
        .map((eventData) => EventData.fromJson(eventData))
        .toList());
  }

  static Future<Response> late(search) async {
    await connected();
    final prefs = EncryptedSharedPreferences();
    var body;
    var httpCustom;

    body = jsonEncode({
      "accountID": await prefs.getString("accountID"),
      "userID": await prefs.getString("userID") ?? '',
      // "groupID": await prefs.getString("groupID") ?? '',
      "search": search
    });

    httpCustom = HttpCustom(url: '$baseUrl/late', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(responseBody
        .map((eventData) => EventData.fromJson(eventData))
        .toList());
  }

  static Future<Response> dashboardFirstRow(params) async {
    await connected();
    final prefs = EncryptedSharedPreferences();
    var body;
    var httpCustom;
    if (params[1] == null || params[1] == '') {
      body = jsonEncode({"accountID": params[0]});
      httpCustom = HttpCustom(url: '$baseUrl/account/vehicles', body: body);
    } else {
      body = jsonEncode({
        'accountID': params[0],
        'userID': params[1],
        // 'groupID': await prefs.getString("groupID")
      });
      httpCustom = HttpCustom(url: '$baseUrl/user/vehicles', body: body);
    }

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
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

  static Future<Response> getHistory(deviceID, startTime, endTime) async {
    await connected();
    var body;
    var httpCustom;
    body = jsonEncode(
        {"deviceID": deviceID, "startTime": startTime, "endTime": endTime});
    httpCustom = HttpCustom(url: '$baseUrl/solo/eventdataList', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
//    return Response.completed(EventData.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
    //for testing purposes
    return Response.completed(responseBody
        .map((eventdata) => EventData.fromJson(eventdata))
        .toList());
  }

  static Future<Response> getActualPosition(deviceID) async {
    await connected();
    var body;
    var httpCustom;
    body = jsonEncode({"deviceID": deviceID});
    httpCustom = HttpCustom(url: '$baseUrl/solo/eventdata', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
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
    body = jsonEncode({"deviceID": deviceID});
    httpCustom = HttpCustom(url: '$baseUrl/report', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(
        Report.fromJson(json.decode(utf8.decode(httpResponse.bodyBytes))));
  }

  static Future<Response> getDevicesSubscription() async {
    await connected();
    var body;
    var httpCustom;
    final prefs = EncryptedSharedPreferences();
    if (await prefs.getString("userID") == null ||
        await prefs.getString("userID") == '') {
      body = jsonEncode({"accountID": await prefs.getString("accountID")});

      httpCustom = HttpCustom(url: '$baseUrl/account/subscription', body: body);
    } else {
      body = jsonEncode({
        "accountID": await prefs.getString("accountID"),
        "userID": await prefs.getString("userID")
        // "groupID": await prefs.getString("groupID"),
      });

      httpCustom = HttpCustom(url: '$baseUrl/user/subscription', body: body);
    }

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(
        responseBody.map((sub) => Subscription.fromJson(sub)).toList());
  }

  static Future<Response> getSummaryReport(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/report/summary', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(responseBody
        .map((sumreport) => SummaryReport.fromJson(sumreport))
        .toList());
  }

  static Future<Response> getSpeedReport(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/report/speed', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(responseBody
        .map((eventData) => EventData.fromJson(eventData))
        .toList());
  }

  static Future<Response> getDeviceAlarmSettings(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/find/alarm', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode == 404) {
      throw ('404');
    } else if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    // return Response.completed(
    //     responseBody.map((alarm) => Alarm.fromJson(alarm)));
    print(responseBody);
    return Response.completed(Alarm.fromJson(responseBody));
  }

  static Future<Response<List<Activity>>> getHistoryTimeLine(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/history/timeline', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<Activity>((activity) => Activity.fromJson(activity))
        .toList());
  }

  static Future<Response> saveDeviceAlarmSettings(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/add/alarm', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    if (httpResponse.statusCode != 201) {
      return Response.error('try another time');
    }

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));
    return Response.completed(
        responseBody.map((alarm) => Alarm.fromJson(alarm)));
  }

  static Future<Response> updateDeviceAlarmSettings(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/update/alarm', body: body);

    final httpResponse = await httpCustom
        .put()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      if (responseBody['message'] == null || responseBody['message'] == "") {
        return Response.error('Réssayer plus tard');
      } else {
        return Response.error(responseBody['message']);
      }
    }
    return Response.completed(Alarm.fromJson(responseBody));
  }

  static Future<Response<List<Draining>>> getDraining(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/findall/draining', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<Draining>((draining) => Draining.fromJson(draining))
        .toList());
  }

  static Future<Response<Draining>> saveDraining(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/add/draining', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    if (httpResponse.statusCode != 201) {
      return Response.error('try another time');
    }

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));
    return Response<Draining>.completed(Draining.fromJson(responseBody));
  }

  static Future<Response> deleteDraining(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/draining', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    // var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      // return Response.error(responseBody['message']);
      return Response.error('problem');
    }

    return Response.completed(null);
  }

  static Future<Response> updateDraining(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/update/draining', body: body);

    final httpResponse = await httpCustom
        .put()
        .catchError((err) => throw ('erreur lié au serveur'));

    if(httpResponse.statusCode != 200) {
        return Response.error('Réssayer plus tard');
    }
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    return Response.completed(Draining.fromJson(responseBody));
  }

  static Future<Response<List<TechnicalVisit>>> getTechnicalVisit(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/findall/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<TechnicalVisit>((technicalVisit) => TechnicalVisit.fromJson(technicalVisit))
        .toList());
  }

  static Future<Response<TechnicalVisit>> saveTechnicalVisit(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/add/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    if (httpResponse.statusCode != 201) {
      return Response.error('try another time');
    }

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));
    return Response<TechnicalVisit>.completed(TechnicalVisit.fromJson(responseBody));
  }

  static Future<Response> deleteTechnicalVisit(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    // var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      // return Response.error(responseBody['message']);
      return Response.error('problem');
    }

    return Response.completed(null);
  }

  static Future<Response> updateTechnicalVisit(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/update/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .put()
        .catchError((err) => throw ('erreur lié au serveur'));

    if(httpResponse.statusCode != 200) {
        return Response.error('Réssayer plus tard');
    }
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));
    return Response.completed(TechnicalVisit.fromJson(responseBody));
  }

  static Future<Response<List<Insurance>>> getInsurance(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/findall/insurance', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<Insurance>((insurance) => Insurance.fromJson(insurance))
        .toList());
  }

  static Future<Response<Insurance>> saveInsurance(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/add/insurance', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    if (httpResponse.statusCode != 201) {
      return Response.error('try another time');
    }

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));
    return Response<Insurance>.completed(Insurance.fromJson(responseBody));
  }

  static Future<Response> deleteInsurance(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/insurance', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    // var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      // return Response.error(responseBody['message']);
      return Response.error('problem');
    }

    return Response.completed(null);
  }

  static Future<Response> updateInsurance(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/update/insurance', body: body);

    final httpResponse = await httpCustom
        .put()
        .catchError((err) => throw ('erreur lié au serveur'));

    if(httpResponse.statusCode != 200) {
        return Response.error('Réssayer plus tard');
    }
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));
    return Response.completed(Insurance.fromJson(responseBody));
  }

  static connected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      throw ('vérifier votre connexion');
    }
  }
}
