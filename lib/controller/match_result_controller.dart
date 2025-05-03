import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerMatchResultProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> get players => _players;

  Map<String, dynamic>? _selectedPlayer;
  Map<String, dynamic>? get selectedPlayer => _selectedPlayer;

  String _selectedResult = 'Won';
  String get selectedResult => _selectedResult;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> fetchPlayers() async {
    _isLoading = true;
    notifyListeners();

    final res = await supabase.from('players').select();
    _players = List<Map<String, dynamic>>.from(res);

    // Sort players
    _players.sort((a, b) {
      int result = b['win_percent'].compareTo(a['win_percent']);
      if (result == 0) {
        result = b['points'].compareTo(a['points']);
      }
      return result;
    });

    // Update selectedPlayer with fresh data from the fetched list
    if (_selectedPlayer != null) {
      _selectedPlayer = _players.firstWhere(
        (player) => player['id'] == _selectedPlayer!['id'],
        orElse: () => _selectedPlayer!,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectPlayer(Map<String, dynamic>? player) {
    _selectedPlayer = player;
    notifyListeners();
  }

  void selectResult(String result) {
    _selectedResult = result;
    notifyListeners();
  }

  Future<void> submitMatchResult() async {
    if (_selectedPlayer == null) {
      throw Exception("Please select a player.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      final p = _selectedPlayer!;
      final id = p['id'];
      int played = (p['played'] ?? 0) + 1;
      int won = p['won'] ?? 0;
      int lost = p['lost'] ?? 0;
      int draw = p['draw'] ?? 0;

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

      await fetchPlayers(); // Re-fetch and update selected player
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> updateMatchResult(String matchId, String newForm) async {
    await supabase
        .from('match_results')
        .update({'form': newForm})
        .eq('id', matchId);
    await fetchPlayers(); // Refresh list after update
  }

  Future<void> deleteMatchResult(String matchId) async {
    await supabase.from('match_results').delete().eq('id', matchId);
    _players.removeWhere((player) => player['id'] == matchId);
    notifyListeners(); // Refresh UI
  }
}
