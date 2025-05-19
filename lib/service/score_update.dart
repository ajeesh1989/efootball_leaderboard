import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScoreUpdateScreen extends StatelessWidget {
  const ScoreUpdateScreen({super.key});

  Future<void> sendScoreUpdateNotification(BuildContext context) async {
    const String restApiKey =
        'os_v2_app_z6g6jhppebeyhk6yvwmueahlezda4tspt4eumkmuwnfa6exx2zqkfzcu632y4c6cisrc7skc3al3bajv4cjuvtt7swm422ccxgukvqq';
    const String appId = 'cf8de49d-ef20-4983-abd8-ad994200eb26';

    var url = Uri.parse('https://onesignal.com/api/v1/notifications');

    var headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic $restApiKey',
    };

    var body = jsonEncode({
      'app_id': appId,
      'included_segments': ['All'], // Send to all users
      'headings': {'en': 'Score Update'},
      'contents': {'en': 'The score table has been updated!'},
    });

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Notification sent')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Exception: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score Update')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => sendScoreUpdateNotification(context),
          child: const Text('Submit Score & Notify'),
        ),
      ),
    );
  }
}
