import 'package:data_table_2/data_table_2.dart';
import 'package:efootballranking/controller/player_controller.dart';
import 'package:efootballranking/pages/match_result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigateToAddForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlayerMatchResultPage()),
    );
    context.read<PlayerProvider>().fetchPlayers();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final players = provider.players;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 21, 22),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'E-Football Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.amber,
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () => provider.exportToPdf(),
            icon: const Icon(Icons.download, color: Colors.amber),
            tooltip: 'Download leaderboard',
          ),
        ],
      ),

      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : players.isEmpty
              ? const Center(
                child: Text(
                  'No player data found',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12),
                child: DataTable2(
                  headingRowColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 43, 14, 172),
                  ),
                  dataRowColor: WidgetStateProperty.all(
                    const Color(0xFF222222),
                  ),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 800,
                  columns: [
                    _styledColumn('RANK'),
                    _styledColumn('NAME'),
                    _styledColumn('MP'),
                    _styledColumn('WON'),
                    _styledColumn('DRAW'),
                    _styledColumn('LOST'),
                    _styledColumn('POINTS'),
                    _styledColumn('WIN %'),
                    _styledColumn('FORM'),
                  ],
                  rows:
                      players.asMap().entries.map((entry) {
                        int index = entry.key;
                        var p = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                p['name'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataCell(
                              Text('${p['played']}', style: _dataStyle()),
                            ),
                            DataCell(Text('${p['won']}', style: _dataStyle())),
                            DataCell(Text('${p['draw']}', style: _dataStyle())),
                            DataCell(Text('${p['lost']}', style: _dataStyle())),
                            DataCell(
                              Text(
                                '${p['points']}',
                                style: _dataStyle(color: Colors.greenAccent),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${p['win_percent'].toStringAsFixed(1)}',
                                style: _dataStyle(),
                              ),
                            ),
                            DataCell(Text('${p['form']}', style: _dataStyle())),
                          ],
                        );
                      }).toList(),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => navigateToAddForm(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  DataColumn _styledColumn(String title) {
    return DataColumn(
      label: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  TextStyle _dataStyle({Color color = Colors.white}) {
    return TextStyle(fontSize: 14, color: color);
  }
}
