import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerMatchResultProvider>();
    final players = provider.players;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 17, 17),
      appBar: AppBar(
        title: const Text(
          'Player Match Report',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          provider.players.isEmpty
              ? const Center(
                child: Text(
                  "Please go to 'Add result page' and come back 🙂 | Thank you for your patience",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side - Player List
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ListView(
                          children: [
                            ListTile(
                              title: const Text(
                                'All Players',
                                style: TextStyle(color: Colors.white),
                              ),
                              selected: provider.selectedPlayer == null,
                              selectedTileColor: Colors.white10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onTap: () => provider.selectPlayer(null),
                            ),
                            const Divider(color: Colors.white30),
                            ...players.map((player) {
                              final isSelected =
                                  provider.selectedPlayer == player;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      player['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedTileColor: Colors.white10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onTap: () => provider.selectPlayer(player),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        'Won: ${player['won']}, Draw: ${player['draw']}, Lost: ${player['lost']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  const Divider(color: Colors.white12),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Right Side - Pie Chart Container
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: PlayerMatchPieChart(
                          player: provider.selectedPlayer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class PlayerMatchPieChart extends StatelessWidget {
  final Map<String, dynamic>? player;
  const PlayerMatchPieChart({super.key, this.player});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlayerMatchResultProvider>();

    // If a specific player is selected
    if (player != null) {
      return PieChart(
        PieChartData(
          sectionsSpace: 6,
          borderData: FlBorderData(show: false),
          sections: [
            _buildSection(player!['won'], Colors.green, 'Won'),
            _buildSection(player!['draw'], Colors.blue, 'Draw'),
            _buildSection(player!['lost'], Colors.red, 'Lost'),
          ],
        ),
      );
    }

    // Aggregate data for all players
    int totalWon = 0, totalDraw = 0, totalLost = 0;
    for (var p in provider.players) {
      totalWon += p['won'] as int;
      totalDraw += p['draw'] as int;
      totalLost += p['lost'] as int;
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 6,
        borderData: FlBorderData(show: false),
        sections: [
          _buildSection(totalWon, Colors.green, 'Won'),
          _buildSection(totalDraw, Colors.blue, 'Draw'),
          _buildSection(totalLost, Colors.red, 'Lost'),
        ],
      ),
    );
  }

  PieChartSectionData _buildSection(int value, Color color, String label) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      title: '$value $label',
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      radius: 50,
    );
  }
}
