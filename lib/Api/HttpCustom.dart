import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class HttpCustom {
  String url;
  String body;

  HttpCustom({this.url, this.body});

  Future<Response> post() async {
    return await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }

  Future<Response> put() async {
    return await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }
}