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

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Card(
          color: const Color(0xFF2B2B2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              player['name'] ?? 'Unnamed Player',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "Date: ${player['last_match_date'] ?? '-'}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Time: ${player['last_match_time'] ?? '-'}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "Result: ${player['result'] ?? '-'}",
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editPlayerResult(BuildContext context, Map<String, dynamic> player) {
    final formController = TextEditingController(text: player['form']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Match Result"),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: formController,
                decoration: const InputDecoration(
                  labelText: 'Form (Win/Loss/Draw)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a form value';
                  }
                  return null;
                },
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
                    final updatedForm = formController.text.trim();
                    final matchId = player['id'];

                    try {
                      await context
                          .read<PlayerMatchResultProvider>()
                          .updateMatchResult(matchId, updatedForm);

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
                        .deleteMatchResult(matchId);

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
