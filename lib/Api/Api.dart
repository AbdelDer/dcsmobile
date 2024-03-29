import 'dart:convert';
import 'dart:io';

import 'package:dcsmobile/Api/Response.dart';
import 'package:dcsmobile/models/Account.dart';
import 'package:dcsmobile/models/Device.dart' as d;
import 'package:dcsmobile/models/EventData.dart';
import 'package:dcsmobile/models/Group.dart';
import 'package:dcsmobile/models/Report.dart';
import 'package:dcsmobile/models/Subscription.dart';
import 'package:dcsmobile/models/User.dart';
import 'package:dcsmobile/models/activity.dart';
import 'package:dcsmobile/models/alarm.dart';
import 'package:dcsmobile/models/draining.dart';
import 'package:dcsmobile/models/entretien.dart';
import 'package:dcsmobile/models/insurance.dart';
import 'package:dcsmobile/models/notifications/device.dart';
import 'package:dcsmobile/models/notifications/notification.dart';
import 'package:dcsmobile/models/summaryreport.dart';
import 'package:dcsmobile/models/technicalvisit.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'HttpCustom.dart';

class Api {
  static final httpClient = HttpClient();

  // static final baseUrl = 'https://geotech-gps.com:9090/api';

  static final baseUrl = 'https://smartrack-geotech.com:9090/api';

  // static final baseUrl = 'http://10.0.0.2:9090/api';

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

  static Future<Response> saveToken(accountID, userID, token) async {
    await connected();
    var body;
    var httpCustom;
    body = jsonEncode({
      "accountID" : accountID,
      "userID" : userID,
      "FCMToken": token
    });
    httpCustom = HttpCustom(url: '$baseUrl/add/token', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    if (httpResponse.statusCode != 200) {
      return Response.error("something wrong happened");
    }
    return Response.completed("token saved successfully");
  }

  static Future<Response> deleteToken(token) async {
    await connected();
    var body;
    var httpCustom;
    body = jsonEncode({
      "FCMToken": token
    });
    httpCustom = HttpCustom(url: '$baseUrl/delete/token', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    if (httpResponse.statusCode != 200) {
      return Response.error("something wrong happened");
    }
    return Response.completed("token deleted successfully");
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
        // "userID": params[1] ?? '',
        "groupID": await prefs.getString("groupID"),
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
      // "userID": await prefs.getString("userID") ?? '',
      "groupID": await prefs.getString("groupID") ?? '',
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
        // 'userID': params[1],
        'groupID': await prefs.getString("groupID")
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

  static Future<Response<List<EventData>>> getGroupActualPosition() async {
    await connected();
    var body;
    var httpCustom;
    final prefs = EncryptedSharedPreferences();
    body = jsonEncode({"accountID": await prefs.getString("accountID"), "groupID": await prefs.getString("groupID")});
    httpCustom = HttpCustom(url: '$baseUrl/group/eventdata', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(
        responseBody.map<EventData>((ed) => EventData.fromJson(ed)).toList());
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
        // "userID": await prefs.getString("userID")
        "groupID": await prefs.getString("groupID")
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
    if (httpResponse.bodyBytes.isEmpty) throw ('404');
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode == 404) {
      throw ('404');
    } else if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    // return Response.completed(
    //     responseBody.map((alarm) => Alarm.fromJson(alarm)));$
    return Response.completed(Alarm.fromJson(responseBody));
  }

  static Future<Response<d.Device>> getDevice(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/find/device', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    if (httpResponse.bodyBytes.isEmpty) throw ('404');
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode == 404) {
      throw ('404');
    } else if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    // return Response.completed(
    //     responseBody.map((alarm) => Alarm.fromJson(alarm)));$
    return Response.completed(d.Device.fromJson(responseBody));
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

  static Future<Response<List<Device>>> getVehicles(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/vehicles', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<Device>((vehicle) => Device.fromJson(vehicle))
        .toList());
  }

  static Future<Response<List<Notification>>> getNotifications(body) async {
    await connected();
    var httpCustom =
        HttpCustom(url: '$baseUrl/findall/notification', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody['content']
        .map<Notification>(
            (notification) => Notification.fromJson(notification))
        .toList());
  }

  //used in notification view
  static Future<Response<EventData>> getPositionByTimestampAndDeviceID(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/position', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));
    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }

    return Response.completed(EventData.fromJson(responseBody));
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
    return Response.completed('added');
  }

  static Future<Response> updateDevice(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/short/update/device', body: body);

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
    return Response.completed(Device.fromJson(responseBody));
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

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 201) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response<Draining>.completed(Draining.fromJson(responseBody));
  }

  static Future<Response> deleteDraining(id) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/draining/$id');

    final httpResponse = await httpCustom
        .delete()
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

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response.completed(Draining.fromJson(responseBody));
  }

  static Future<Response<List<TechnicalVisit>>> getTechnicalVisit(body) async {
    await connected();
    var httpCustom =
        HttpCustom(url: '$baseUrl/findall/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<TechnicalVisit>(
            (technicalVisit) => TechnicalVisit.fromJson(technicalVisit))
        .toList());
  }

  static Future<Response<TechnicalVisit>> saveTechnicalVisit(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/add/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 201) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response<TechnicalVisit>.completed(
        TechnicalVisit.fromJson(responseBody));
  }

  static Future<Response> deleteTechnicalVisit(id) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/technicalVisit/$id');

    final httpResponse = await httpCustom
        .delete()
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
    var httpCustom =
        HttpCustom(url: '$baseUrl/update/technicalVisit', body: body);

    final httpResponse = await httpCustom
        .put()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

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

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 201) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response<Insurance>.completed(Insurance.fromJson(responseBody));
  }

  static Future<Response> deleteInsurance(id) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/insurance/$id');

    final httpResponse = await httpCustom
        .delete()
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

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response.completed(Insurance.fromJson(responseBody));
  }

  static Future<Response<List<Entretien>>> getEntretien(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/findall/entretien', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      return Response.error(responseBody['message']);
    }
    return Response.completed(responseBody
        .map<Entretien>((insurance) => Entretien.fromJson(insurance))
        .toList());
  }

  static Future<Response<Entretien>> saveEntretien(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/add/entretien', body: body);

    final httpResponse = await httpCustom
        .post()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 201) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response<Entretien>.completed(Entretien.fromJson(responseBody));
  }

  static Future<Response> deleteEntretien(id) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/delete/entretien/$id');

    final httpResponse = await httpCustom
        .delete()
        .catchError((err) => throw ('erreur lié au serveur'));

    // var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      // return Response.error(responseBody['message']);
      return Response.error('problem');
    }

    return Response.completed(null);
  }

  static Future<Response> updateEntretien(body) async {
    await connected();
    var httpCustom = HttpCustom(url: '$baseUrl/update/entretien', body: body);

    final httpResponse = await httpCustom
        .put()
        .catchError((err) => throw ('erreur lié au serveur'));

    var responseBody = json.decode(utf8.decode(httpResponse.bodyBytes));

    if (httpResponse.statusCode != 200) {
      if (responseBody['message'] != null) {
        return Response.error(responseBody['message']);
      }
      return Response.error('try another time');
    }

    return Response.completed(Entretien.fromJson(responseBody));
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
