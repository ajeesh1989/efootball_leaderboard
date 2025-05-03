import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveScoreService {
  final String apiUrl =
      'https://api.football-data.org/v2/matches'; // Replace with your API endpoint
  final String apiKey = 'YOUR_API_KEY'; // Replace with your API key

  Future<Map<String, dynamic>> getLiveScores() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-Auth-Token': apiKey, // Some APIs use a token like this
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Parsing the response as JSON
      } else {
        throw Exception('Failed to load live scores');
      }
    } catch (error) {
      throw Exception('Error fetching live scores: $error');
    }
  }
}
