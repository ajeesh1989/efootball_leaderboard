import 'package:efootballranking/controller/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerListPage extends StatefulWidget {
  const PlayerListPage({super.key});

  @override
  State<PlayerListPage> createState() => _PlayerListPageState();
}

class _PlayerListPageState extends State<PlayerListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PlayerProvider>().fetchPlayers());
  }

  Future<void> editPlayer(
    BuildContext context,
    Map<String, dynamic> player,
  ) async {
    final nameCtrl = TextEditingController(text: player['name']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Player Name"),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Player Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a player name';
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
                    final newName = nameCtrl.text.trim();
                    final playerId = player['id'];

                    try {
                      await context.read<PlayerProvider>().updatePlayerName(
                        playerId,
                        newName,
                      );

                      // UI update already handled in provider via notifyListeners()

                      Navigator.pop(context); // Close the dialog first
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Player name updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context); // Close dialog even if error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update player name: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  Future<void> confirmDeletePlayer(
    BuildContext context,
    Map<String, dynamic> player,
  ) async {
    final playerId = player['id'];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Player"),
            content: Text("Are you sure you want to delete ${player['name']}?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await context.read<PlayerProvider>().deletePlayer(playerId);

                    Navigator.pop(context); // Close dialog on success
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Player deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close dialog even on error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete player: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text("Player List", style: TextStyle(fontSize: 15)),
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await playerProvider.fetchPlayers(),
        child:
            playerProvider.isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.cyan),
                )
                : playerProvider.players.isEmpty
                ? const Center(
                  child: Text(
                    "No players found.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: playerProvider.players.length,
                  separatorBuilder:
                      (_, __) => const Divider(color: Colors.cyan),
                  itemBuilder: (context, index) {
                    final player = playerProvider.players[index];
                    final playerName = player['name'].toString().toUpperCase();

                    return ListTile(
                      title: Text(
                        playerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.cyan,
                        radius: 18.00,
                        child: Text(
                          playerName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit Player',
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => editPlayer(context, player),
                          ),
                          IconButton(
                            tooltip: 'Delete Player',
                            icon: Icon(
                              Icons.delete,
                              color: Colors.grey.shade600,
                            ),
                            onPressed:
                                () => confirmDeletePlayer(context, player),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
