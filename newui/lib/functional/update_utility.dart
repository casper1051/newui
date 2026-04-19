import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchUpdateData() async {
  final url = Uri.parse('https://raw.githubusercontent.com/user/project/refs/heads/main/update/stable.json');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON string into a Map
      Map<String, dynamic> data = jsonDecode(response.body);

      // Extract your variables
      String version = data['version'];
      bool isProd = data['prod'];

      print('Version: $version');
      print('Is Production: $isProd');
      
      // Use variables here...
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}