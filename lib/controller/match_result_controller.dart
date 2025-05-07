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

  String _selectedResult = 'Won';
  String get selectedResult => _selectedResult;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchPlayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await supabase.from('players').select();
      _players = List<Map<String, dynamic>>.from(res);

      _players.sort((a, b) {
        int result = b['win_percent'].compareTo(a['win_percent']);
        if (result == 0) {
          result = b['points'].compareTo(a['points']);
        }
        return result;
      });

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
    notifyListeners();
  }

  void selectResult(String result) {
    _selectedResult = result;
    notifyListeners();
  }

  Future<void> updatePlayerStats(Map<String, dynamic> player) async {
    final id = player['id'].toString(); // UUID

    int played = _parseToInt(player['played']);
    int won = _parseToInt(player['won']);
    int lost = _parseToInt(player['lost']);
    int draw = _parseToInt(player['draw']);

    played += 1;

    switch (_selectedResult) {
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

      log("Updated stats: played=$played, won=$won, lost=$lost, draw=$draw");
    } catch (e, stack) {
      log("Error updating player stats for player ID $id: $e\n$stack");
    }
  }

  Future<void> insertMatchResult(dynamic playerId) async {
    final id = playerId.toString(); // UUID
    log("Inserting match result for playerId: $id");

    try {
      // Fetch player name
      final playerResponse =
          await supabase
              .from('players')
              .select(
                'name',
              ) // Assuming the 'name' column exists in the 'players' table
              .eq('id', id)
              .single();

      final playerName =
          playerResponse['name'] ??
          'Unknown'; // Fallback to 'Unknown' if name is null

      // Insert match result with player name
      final response = await supabase.from('match_results').insert({
        'player_id': id,
        'name': playerName, // Include player name
        'result': _selectedResult,
        'created_at': DateTime.now().toIso8601String(),
      });

      log("Insert response: $response");
    } catch (e) {
      log("Error inserting match result: $e");
    }
  }

  Future<void> submitMatchResult() async {
    if (_selectedPlayer == null) {
      log("Submit failed: No player selected.");
      throw Exception("Please select a player.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      final p = _selectedPlayer!;
      final id = p['id'].toString(); // UUID

      await updatePlayerStats(p);
      await insertMatchResult(id);
      await fetchPlayers();
    } catch (e, stack) {
      log("Error submitting match result: $e\n$stack");
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
    if (winPercent < 20) return "Noob";
    if (winPercent < 30) return "Rookie";
    if (winPercent < 40) return "Moderate";
    if (winPercent < 60) return "Good";
    if (winPercent < 70) return "Excellent";
    if (winPercent < 80) return "Professional";
    if (winPercent < 90) return "Legend";
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
}
