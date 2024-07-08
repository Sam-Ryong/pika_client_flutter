import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> getData(String endpoint) async {
  final url = Uri.parse(endpoint); // 요청을 보낼 URL을 설정합니다.

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      return null;
    }
  } catch (e) {
    return e;
  }
}

Future<dynamic> postData(String endpoint, Map<String, dynamic> map) async {
  final url = Uri.parse(endpoint);
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode(map);

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return response;
    } else {
      return null;
    }
  } catch (e) {
    return e;
  }
}
