import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

class HeadToHeadPage extends StatelessWidget {
  const HeadToHeadPage({super.key});

  Future<List<Map<String, dynamic>>> _loadHeadToHeadStats(
    BuildContext context,
  ) async {
    final provider = Provider.of<PlayerMatchResultProvider>(
      context,
      listen: false,
    );

    await provider.fetchPlayers();
    final players = provider.players;

    if (players.isEmpty) {
      debugPrint('No players found.');
      return [];
    }

    debugPrint('Players fetched: ${players.length}');
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        final player1 = players[i];
        final player2 = players[j];

        final player1Id = player1['id']?.toString() ?? '';
        final player2Id = player2['id']?.toString() ?? '';

        if (player1Id.isEmpty || player2Id.isEmpty) continue;

        final stats = await provider.fetchHeadToHeadData(player1Id, player2Id);

        if (stats == null) {
          debugPrint('Stats null for ${player1['name']} vs ${player2['name']}');
          continue;
        }

        debugPrint(
          'Stats for ${player1['name']} vs ${player2['name']}: $stats',
        );

        if ((stats['totalMatches'] ?? 0) > 0) {
          results.add({
            'player1Name': player1['name'],
            'player2Name': player2['name'],
            'stats': stats,
          });
        }
      }
    }

    return results;
  }

  Widget _statTile(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Head-to-Head Stats'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadHeadToHeadStats(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (snapshot.hasData) {
            final headToHeadResults = snapshot.data ?? [];

            if (headToHeadResults.isEmpty) {
              return const Center(
                child: Text(
                  'No head-to-head data available.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: headToHeadResults.length,
              itemBuilder: (context, index) {
                final item = headToHeadResults[index];
                final stats = item['stats'] ?? {};

                // Format the date if available
                String formattedDate = 'Date not available';
                if (stats.containsKey('lastMatchDate') &&
                    stats['lastMatchDate'] != null) {
                  DateTime? date;
                  // Try parsing date if it's a string
                  if (stats['lastMatchDate'] is String) {
                    date = DateTime.tryParse(stats['lastMatchDate']);
                  } else if (stats['lastMatchDate'] is DateTime) {
                    date = stats['lastMatchDate'];
                  }
                  if (date != null) {
                    formattedDate = DateFormat.yMMMMd().format(date);
                  }
                }

                return Card(
                  color: Colors.grey.shade900,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item['player1Name']} vs ${item['player2Name']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statTile("Matches", stats['totalMatches'] ?? 0),
                            _statTile(
                              item['player1Name'],
                              stats['player1Wins'] ?? 0,
                            ),
                            _statTile(
                              item['player2Name'],
                              stats['player2Wins'] ?? 0,
                            ),
                            _statTile("Draws", stats['draws'] ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No head-to-head data available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}
