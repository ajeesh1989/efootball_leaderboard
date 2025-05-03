import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PlayerProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> get players => _players;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch players from the Supabase database
  Future<void> fetchPlayers() async {
    _isLoading = true;
    notifyListeners();

    final res = await supabase.from('players').select(); // Remove .order()

    _players = List<Map<String, dynamic>>.from(res);

    // Now sort locally: first by win_percent (desc), then by points (desc)
    _players.sort((a, b) {
      final winPercentCompare = (b['win_percent'] ?? 0).compareTo(
        a['win_percent'] ?? 0,
      );
      if (winPercentCompare != 0) return winPercentCompare;

      return (b['points'] ?? 0).compareTo(a['points'] ?? 0);
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePlayerName(String playerId, String newName) async {
    try {
      final updatedData =
          await supabase
              .from('players')
              .update({'name': newName})
              .eq('id', playerId)
              .select();

      // Update local list (if necessary)
      _players =
          _players.map((player) {
            if (player['id'] == playerId) {
              return {...player, 'name': newName};
            }
            return player;
          }).toList();

      notifyListeners(); // Update the UI
      debugPrint('Update Successful: $updatedData');
    } catch (e) {
      debugPrint('Exception: $e');
      throw Exception('Error while updating player name: $e');
    }
  }

  Future<void> deletePlayer(String playerId) async {
    try {
      final response = await supabase
          .from('players')
          .delete()
          .eq('id', playerId);

      // response is a PostgrestList, not an object with an .error
      debugPrint('Delete response: $response');

      // Update the local list
      _players.removeWhere((player) => player['id'] == playerId);
      notifyListeners(); // This updates the UI immediately
    } catch (e) {
      debugPrint('Delete exception: $e');
      throw Exception('Error while deleting player: $e');
    }
  }

  // Add a new player to the database
  Future<bool> addPlayer(String name) async {
    try {
      await supabase.from('players').insert({
        'name': name,
        'played': 0,
        'won': 0,
        'lost': 0,
        'draw': 0,
        'points': 0,
        'win_percent': 0.0,
        'form': "Noob",
      });
      return true;
    } catch (e) {
      debugPrint("Error adding player: $e");
      return false;
    }
  }

  // Export players list to PDF
  Future<void> exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'E-Football Leaderboard',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Rank',
                  'Name',
                  'MP',
                  'W',
                  'D',
                  'L',
                  'Pts',
                  'Win %',
                  'Form',
                ],
                data:
                    _players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final p = entry.value;
                      return [
                        '${index + 1}',
                        p['name'],
                        '${p['played']}',
                        '${p['won']}',
                        '${p['draw']}',
                        '${p['lost']}',
                        '${p['points']}',
                        '${p['win_percent'].toStringAsFixed(1)}',
                        p['form'],
                      ];
                    }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // ---------
}
