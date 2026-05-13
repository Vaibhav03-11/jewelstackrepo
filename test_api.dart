import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  try {
    final response = await http.get(
      Uri.parse('https://www.goldapi.io/api/XAU/INR'),
      headers: {
        'x-access-token': 'goldapi-3o7yqsmfwlwyiv-io',
        'Content-Type': 'application/json',
      },
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    
    final responseSilv = await http.get(
      Uri.parse('https://www.goldapi.io/api/XAG/INR'),
      headers: {
        'x-access-token': 'goldapi-3o7yqsmfwlwyiv-io',
        'Content-Type': 'application/json',
      },
    );
    print('Silv Status: ${responseSilv.statusCode}');
    print('Silv Body: ${responseSilv.body}');
  } catch (e) {
    print('Error: $e');
  }
}
