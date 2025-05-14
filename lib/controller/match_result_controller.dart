import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerMatchResultProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> get players => _players;

  List<Map<String, dynamic>> __aalkkar = [];
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

  Future<void> insertMatchResult(String playerId, String result) async {
    final id = playerId.toString();
    log("Inserting match result for playerId: $id with result: $result");

    try {
      final playerResponse =
          await supabase.from('players').select('name').eq('id', id).single();
      final playerName = playerResponse['name'] ?? 'Unknown';

      await supabase.from('match_results').insert({
        'player_id': id,
        'name': playerName,
        'result': result, // ✅ Fix: Pass correct result dynamically
        'created_at': DateTime.now().toIso8601String(),
      });

      log("Inserted match result for playerId: $id with result: $result");
    } catch (e) {
      log("Error inserting match result: $e");
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

      // Update stats and insert match results with the correct result values.
      await updatePlayerStats(player1, _selectedResult);
      await insertMatchResult(id1, _selectedResult);

      await updatePlayerStats(player2, _selectedResult2);
      await insertMatchResult(id2, _selectedResult2);

      // Refresh player list from the database.
      await fetchPlayers();

      log("Match result successfully submitted for both players.");

      // Reset the selections – this is key for refreshing the UI.
      _selectedPlayer = null;
      _selectedPlayer2 = null;
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

  Future<void> updateMatchResultAndPlayerStats(
    String matchId,
    String newResult,
  ) async {
    final match =
        await supabase
            .from('match_results')
            .select()
            .eq('id', matchId)
            .single();

    final playerId = match['player_id'];
    final oldResult = match['result'];

    final player =
        await supabase.from('players').select().eq('id', playerId).single();

    int played = _parseToInt(player['played']);
    int won = _parseToInt(player['won']);
    int lost = _parseToInt(player['lost']);
    int draw = _parseToInt(player['draw']);

    // 1. Remove the effect of old result
    switch (oldResult) {
      case 'Won':
        won -= 1;
        break;
      case 'Lost':
        lost -= 1;
        break;
      case 'Draw':
        draw -= 1;
        break;
    }

    // 2. Apply the effect of new result
    switch (newResult) {
      case 'Won':
        won += 1;
        break;
      case 'Lost':
        lost += 1;
        break;
      case 'Draw':
        draw += 1;
        break;
    }

    // Points and win percentage
    final points = (won * 3) + draw;
    final winPercent = played > 0 ? (won / played) * 100 : 0.0;
    final form = getForm(winPercent);

    // 3. Update player stats
    await supabase
        .from('players')
        .update({
          'won': won,
          'lost': lost,
          'draw': draw,
          'points': points,
          'win_percent': winPercent,
          'form': form,
        })
        .eq('id', playerId);

    // 4. Update match result record
    await supabase
        .from('match_results')
        .update({'result': newResult})
        .eq('id', matchId);

    await fetchPlayers(); // Refresh local player list
  }

  Future<void> deleteMatchResultAndUpdatePlayer(String matchId) async {
    final match =
        await supabase
            .from('match_results')
            .select()
            .eq('id', matchId)
            .single();

    final playerId = match['player_id'];
    final result = match['result'];

    final player =
        await supabase.from('players').select().eq('id', playerId).single();

    int played = _parseToInt(player['played']) - 1;
    int won = _parseToInt(player['won']);
    int lost = _parseToInt(player['lost']);
    int draw = _parseToInt(player['draw']);

    switch (result) {
      case 'Won':
        won -= 1;
        break;
      case 'Lost':
        lost -= 1;
        break;
      case 'Draw':
        draw -= 1;
        break;
    }

    final points = (won * 3) + draw;
    final winPercent = played > 0 ? (won / played) * 100 : 0.0;
    final form = getForm(winPercent);

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
        .eq('id', playerId);

    await supabase.from('match_results').delete().eq('id', matchId);
  }

  Future<void> deleteItem(String itemId) async {
    try {
      final response = await supabase
          .from('match_results')
          .delete()
          .eq('id', itemId);
      if (response.error != null) {
        throw Exception('Failed to delete item');
      }
    } catch (e, stack) {
      log("Error deleting item: $e\n$stack");
      rethrow;
    }
  }

  Future<void> updateItem(String itemId, String name, String detail) async {
    try {
      final response = await supabase
          .from('match_results')
          .update({'name': name, 'detail': detail})
          .eq('id', itemId);

      if (response.error != null) {
        throw Exception('Failed to update item');
      }
    } catch (e, stack) {
      log("Error updating item: $e\n$stack");
      rethrow;
    }
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await supabase.from('match_results').select();

      // Format the date
      final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
      __aalkkar =
          List<Map<String, dynamic>>.from(res).map((item) {
            final createdAt = item['created_at'];
            if (createdAt != null) {
              final parsedDate = DateTime.parse(createdAt);
              item['formatted_date'] = dateFormat.format(parsedDate);
            } else {
              item['formatted_date'] = 'N/A';
            }
            return item;
          }).toList();
    } catch (e, stack) {
      log("Error fetching data: $e\n$stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitHeadToHeadMatch({
    required Map<String, dynamic> player1,
    required Map<String, dynamic> player2,
    required String player1Result, // Expected values: 'Won', 'Lost', or 'Draw'
    required String player2Result, // Expected values: 'Won', 'Lost', or 'Draw'
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase.from('matches').insert({
        'player1_id': player1['id'],
        'player2_id': player2['id'],
        'player1_result': player1Result,
        'player2_result': player2Result,
        // Optional: specify match_date if needed (or let it default to now)
      });

      // Optionally check response errors:
      if (response.error != null) {
        throw Exception('Failed to submit head-to-head match');
      }

      // After a successful insert, you might want to update player statistics
      // or refresh any cached match data.

      log("Successfully submitted head-to-head match: $response");

      // Optionally, if you have separate heads-up data in the provider,
      // fetch/update head-to-head stats here
      await fetchHeadToHeadData(player1['id'], player2['id']);
    } catch (e, stack) {
      log("Error in submitHeadToHeadMatch: $e\n$stack");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchHeadToHeadData(
    String player1Id,
    String player2Id,
  ) async {
    try {
      // Build the query to fetch matches that involve both players, regardless of order.
      final data = await supabase
          .from('matches')
          .select()
          .or(
            'and(player1_id.eq.$player1Id,player2_id.eq.$player2Id),and(player1_id.eq.$player2Id,player2_id.eq.$player1Id)',
          );

      // Log the raw data output for debugging.
      debugPrint("Raw matches data: $data");

      // Ensure the returned data is a List.
      final List<dynamic> matches = data as List<dynamic>;
      final totalMatches = matches.length;
      int player1Wins = 0;
      int player2Wins = 0;
      int draws = 0;

      for (final match in matches) {
        // We assume here that a match is a draw if player1_result is 'Draw'.
        if (match['player1_result'] == 'Draw') {
          draws++;
        } else {
          // Count wins for player1Id.
          if ((match['player1_id'] == player1Id &&
                  match['player1_result'] == 'Won') ||
              (match['player2_id'] == player1Id &&
                  match['player2_result'] == 'Won')) {
            player1Wins++;
          }
          // Count wins for player2Id.
          if ((match['player1_id'] == player2Id &&
                  match['player1_result'] == 'Won') ||
              (match['player2_id'] == player2Id &&
                  match['player2_result'] == 'Won')) {
            player2Wins++;
          }
        }
      }

      debugPrint(
        "Processed head-to-head counts: Total Matches: $totalMatches, "
        "Player1 Wins: $player1Wins, Player2 Wins: $player2Wins, Draws: $draws",
      );

      return {
        'totalMatches': totalMatches,
        'player1Wins': player1Wins,
        'player2Wins': player2Wins,
        'draws': draws,
      };
    } catch (e, stack) {
      debugPrint("Error in fetchHeadToHeadData: $e\n$stack");
      return null;
    }
  }
}
