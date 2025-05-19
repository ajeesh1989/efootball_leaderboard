import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerMatchResultProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> get players => _players;

  final List<Map<String, dynamic>> __aalkkar = [];
  List<Map<String, dynamic>> get items => __aalkkar; // Getter for items

  Map<String, dynamic>? _selectedPlayer;
  Map<String, dynamic>? get selectedPlayer => _selectedPlayer;

  Map<String, dynamic>? _selectedPlayer2;
  Map<String, dynamic>? get selectedPlayer2 => _selectedPlayer2;
  String _selectedResult = 'Won';
  String get selectedResult => _selectedResult;

  String _selectedResult2 =
      'Lost'; // Auto-calculated based on Player 1's choice
  String get selectedResult2 => _selectedResult2;

  void selectPlayer2(Map<String, dynamic>? player) {
    _selectedPlayer2 = player;
    notifyListeners();
  }

  void selectResult2(String result) {
    _selectedResult2 = result;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchPlayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Optionally ensure you explicitly fetch all columns.
      final res = await supabase.from('players').select('*');
      log("Fetched response: $res");

      // Make sure the response is of the expected type (List of maps)
      _players = List<Map<String, dynamic>>.from(res);

      _players.sort((a, b) {
        int result = b['win_percent'].compareTo(a['win_percent']);
        if (result == 0) {
          result = b['points'].compareTo(a['points']);
        }
        return result;
      });

      // Update selectedPlayer with fresh data if it exists in the new list.
      if (_selectedPlayer != null) {
        _selectedPlayer = _players.firstWhere(
          (player) => player['id'] == _selectedPlayer!['id'],
          orElse: () => _selectedPlayer!,
        );
      }
    } catch (e, stack) {
      log("Error fetching players: $e\n$stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPlayer(Map<String, dynamic>? player) {
    _selectedPlayer = player;
    // Reset Player 2 if it conflicts with the new Player 1
    if (_selectedPlayer2 != null &&
        _selectedPlayer2!['id'] == _selectedPlayer?['id']) {
      _selectedPlayer2 = null;
    }
    notifyListeners();
  }

  void selectResult(String result) {
    _selectedResult = result;
    notifyListeners();
  }

  Future<void> updatePlayerStats(
    Map<String, dynamic> player,
    String result,
  ) async {
    final id = player['id'].toString();

    int played = _parseToInt(player['played']);
    int won = _parseToInt(player['won']);
    int lost = _parseToInt(player['lost']);
    int draw = _parseToInt(player['draw']);

    played += 1;

    switch (result) {
      // Use the passed-in result!
      case 'Won':
        won += 1;
        break;
      case 'Lost':
        lost += 1;
        break;
      case 'Draw':
        draw += 1;
        break;
      default:
        // Optionally handle an unexpected result here.
        break;
    }

    final points = (won * 3) + draw;
    final winPercent = played > 0 ? (won / played) * 100 : 0.0;
    final form = getForm(winPercent);

    try {
      await supabase
          .from('players')
          .update({
            'played': played,
            'won': won,
            'lost': lost,
            'draw': draw,
            'points': points,
            'win_percent': winPercent,
            'form': form,
          })
          .eq('id', id);

      log(
        "Updated stats for player $id: played=$played, won=$won, lost=$lost, draw=$draw",
      );
    } catch (e, stack) {
      log("Error updating player stats for player ID $id: $e\n$stack");
    }
  }

  Future<void> updateMatchWithPlayer2(
    String matchId,
    String player2Id,
    String player2Name,
    String player2Result,
  ) async {
    try {
      await supabase
          .from('matches')
          .update({
            'player2_id': player2Id,
            'player2_name': player2Name,
            'player2_result': player2Result,
          })
          .eq('id', matchId);

      log("Updated match $matchId with player2 data ✅");
    } catch (e) {
      log("Error updating match with player2 data: $e");
    }
  }

  Future<void> insertFullMatchResult({
    required String player1Id,
    required String player2Id,
    required String player1Result,
    required String player2Result,
  }) async {
    try {
      // Fetch player names in parallel
      final responses = await Future.wait([
        supabase.from('players').select('name').eq('id', player1Id).single(),
        supabase.from('players').select('name').eq('id', player2Id).single(),
      ]);

      final player1Name = responses[0]['name'] ?? 'Unknown';
      final player2Name = responses[1]['name'] ?? 'Unknown';

      // Insert into match_results for both players (optional)
      await Future.wait([
        supabase.from('match_results').insert({
          'player_id': player1Id,
          'name': player1Name,
          'result': player1Result,
          'created_at': DateTime.now().toIso8601String(),
        }),
        supabase.from('match_results').insert({
          'player_id': player2Id,
          'name': player2Name,
          'result': player2Result,
          'created_at': DateTime.now().toIso8601String(),
        }),
      ]);

      // Insert full match with both players
      await supabase.from('matches').insert({
        'player1_id': player1Id,
        'player1_name': player1Name,
        'player1_result': player1Result,
        'player2_id': player2Id,
        'player2_name': player2Name,
        'player2_result': player2Result,
        'match_date': DateTime.now().toIso8601String(),
      });

      log("Successfully inserted full match result");
    } catch (e) {
      log("Error inserting full match result: $e");
    }
  }

  Future<void> submitMatchResult() async {
    if (_selectedPlayer == null || _selectedPlayer2 == null) {
      log("Submit failed: One or both players not selected.");
      throw Exception("Please select both players.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      final player1 = _selectedPlayer!;
      final player2 = _selectedPlayer2!;
      final id1 = player1['id'].toString();
      final id2 = player2['id'].toString();

      // Automatically assign Player 2's result based on Player 1's selection.
      switch (_selectedResult) {
        case 'Won':
          _selectedResult2 = 'Lost';
          break;
        case 'Lost':
          _selectedResult2 = 'Won';
          break;
        case 'Draw':
          _selectedResult2 = 'Draw';
          break;
        default:
          throw Exception("Invalid match result.");
      }

      // Update stats for both players
      await updatePlayerStats(player1, _selectedResult);
      await updatePlayerStats(player2, _selectedResult2);

      // Insert a full match row with both players' data
      await insertFullMatchResult(
        player1Id: id1,
        player2Id: id2,
        player1Result: _selectedResult,
        player2Result: _selectedResult2,
      );

      // Refresh player list from the database
      await fetchPlayers();

      log("Match result successfully submitted for both players.");

      // Reset selections for UI
      _selectedPlayer = null;
      _selectedPlayer2 = null;
      _selectedResult = 'Won';
      _selectedResult2 = 'Lost';
    } catch (e, stack) {
      log("Error submitting match results: $e\n$stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    try {
      return int.parse(value.toString());
    } catch (e) {
      log("Error parsing value '$value' to int: $e");
      return 0;
    }
  }

  String getForm(double winPercent) {
    if (winPercent <= 9.99) return "Poor";
    if (winPercent <= 19.99) return "Beginner";
    if (winPercent <= 29.99) return "Moderate";
    if (winPercent <= 39.99) return "Decent";
    if (winPercent <= 49.99) return "Good";
    if (winPercent <= 59.99) return "Skilled";
    if (winPercent <= 69.99) return "Excellent";
    if (winPercent <= 79.99) return "Professional";
    if (winPercent <= 89.99) return "Legend";
    return "God Mode";
  }

  Future<Map<String, dynamic>?> fetchHeadToHeadData(
    String player1Id,
    String player2Id,
  ) async {
    try {
      final p1Id = int.tryParse(player1Id) ?? player1Id;
      final p2Id = int.tryParse(player2Id) ?? player2Id;

      final data = await supabase
          .from('matches')
          .select('player1_id, player2_id, player1_result, player2_result')
          .or(
            'and(player1_id.eq.$player1Id,player2_id.eq.$player2Id),and(player1_id.eq.$player2Id,player1_id.eq.$player1Id)',
          );

      if (data.isEmpty) return null;

      final List<dynamic> matches = data as List<dynamic>;
      int player1Wins = 0;
      int player2Wins = 0;
      int draws = 0;

      DateTime? lastMatchDate;

      for (final match in matches) {
        final p1Result =
            (match['player1_result'] as String?)?.toLowerCase() ?? '';
        final p2Result =
            (match['player2_result'] as String?)?.toLowerCase() ?? '';
        final matchP1Id = match['player1_id'];
        final matchP2Id = match['player2_id'];

        // Update last match date if available
        if (match['match_date'] != null) {
          final dateStr = match['match_date'];
          DateTime? matchDate;
          if (dateStr is String) {
            matchDate = DateTime.tryParse(dateStr);
          } else if (dateStr is DateTime) {
            matchDate = dateStr;
          }
          if (matchDate != null) {
            if (lastMatchDate == null || matchDate.isAfter(lastMatchDate)) {
              lastMatchDate = matchDate;
            }
          }
        }

        if (p1Result == 'draw' && p2Result == 'draw') {
          draws++;
        } else if (matchP1Id == p1Id && p1Result == 'won') {
          player1Wins++;
        } else if (matchP2Id == p1Id && p2Result == 'won') {
          player1Wins++;
        } else if (matchP1Id == p2Id && p1Result == 'won') {
          player2Wins++;
        } else if (matchP2Id == p2Id && p2Result == 'won') {
          player2Wins++;
        }
      }

      return {
        'totalMatches': matches.length,
        'player1Wins': player1Wins,
        'player2Wins': player2Wins,
        'draws': draws,
        'lastMatchDate': lastMatchDate, // Add last match date here
      };
    } catch (e, stack) {
      log("Error fetching head-to-head data: $e\n$stack");
      return null;
    }
  }

  // ******************************************** imp
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
      'included_segments': ['All'],
      'headings': {'en': 'E-football Score Update'},
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
}
