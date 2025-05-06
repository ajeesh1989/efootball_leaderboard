import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryListScreen extends StatefulWidget {
  const EntryListScreen({super.key});

  @override
  State<EntryListScreen> createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PlayerMatchResultProvider>().fetchPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerMatchResultProvider>();
    final players = provider.players;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (players.isEmpty) {
      return const Center(
        child: Text(
          "No match results available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Match Results"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text('#', style: TextStyle(color: Colors.amber)),
              ),
              DataColumn(
                label: Text(
                  'Player Name',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
              DataColumn(
                label: Text('Result', style: TextStyle(color: Colors.amber)),
              ),
              DataColumn(
                label: Text('Date', style: TextStyle(color: Colors.amber)),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(color: Colors.amber)),
              ),
            ],
            rows: List<DataRow>.generate(players.length, (index) {
              final player = players[index];
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      player['name'] ?? 'Unnamed Player',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      player['result'] ?? 'Not Available',
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                  DataCell(
                    Text(
                      player['last_match_date'] ?? 'Not Available',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _editPlayerResult(context, player),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => _confirmDelete(context, player['id']),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _editPlayerResult(BuildContext context, Map<String, dynamic> player) {
    final nameController = TextEditingController(text: player['name']);
    final formController = TextEditingController(text: player['result']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Match Result"),
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Player Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a player name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: formController,
                    decoration: const InputDecoration(
                      labelText: 'Form (Win/Loss/Draw)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a result';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final updatedName = nameController.text.trim();
                    final matchId = player['id'];

                    try {
                      await context
                          .read<PlayerMatchResultProvider>()
                          .updateMatchResultAndPlayerStats(
                            matchId,
                            updatedName, // Send updated player name as well
                          );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Match result updated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update match result'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, String matchId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Match Result"),
            content: const Text(
              "Are you sure you want to delete this match result?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await context
                        .read<PlayerMatchResultProvider>()
                        .deleteMatchResultAndUpdatePlayer(matchId);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Match result deleted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete match result'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
