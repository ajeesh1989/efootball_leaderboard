import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efootballranking/pages/playerpage.dart';

class PlayerMatchResultPage extends StatelessWidget {
  const PlayerMatchResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Triggering the fetchPlayers() when the widget is built for the first time
    Future.delayed(Duration.zero, () {
      context.read<PlayerMatchResultProvider>().fetchPlayers();
    });

    return Consumer<PlayerMatchResultProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            title: const Text("Match Result"),
            backgroundColor: const Color.fromARGB(255, 25, 25, 25),
            foregroundColor: Colors.amber,
          ),
          body:
              provider.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Player Dropdown
                        Card(
                          color: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade900,
                                labelText: "Select Player",
                                labelStyle: const TextStyle(
                                  color: Colors.amber,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              dropdownColor: Colors.grey.shade900,
                              value:
                                  provider.selectedPlayer != null
                                      ? provider.selectedPlayer!['id']
                                      : null,
                              items:
                                  provider.players.isEmpty
                                      ? [
                                        DropdownMenuItem<String>(
                                          value: null,
                                          child: Text(
                                            "No players available",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ]
                                      : provider.players.map((player) {
                                        return DropdownMenuItem<String>(
                                          value: player['id'],
                                          child: Text(
                                            player['name'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                              onChanged: (val) {
                                provider.selectPlayer(
                                  provider.players.firstWhere(
                                    (player) => player['id'] == val,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Result Selection (Won, Lost, Draw)
                        Card(
                          color: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children:
                                ['Won', 'Lost', 'Draw'].map((result) {
                                  return RadioListTile<String>(
                                    title: Text(
                                      result,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    value: result,
                                    activeColor: Colors.amber,
                                    groupValue: provider.selectedResult,
                                    onChanged: (val) {
                                      provider.selectResult(val!);
                                    },
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Add Player Button
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const PlayerNameFormPage(),
                                  ),
                                );
                                provider
                                    .fetchPlayers(); // Re-fetch players after adding a new one
                              },
                              icon: const Icon(
                                Icons.person_add,
                                color: Colors.amber,
                              ),
                              label: const Text(
                                "Add Player",
                                style: TextStyle(color: Colors.amber),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.amber),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                            ),

                            // Submit Match Result Button
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await provider.submitMatchResult();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Match result submitted successfully!",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        16,
                                        46,
                                        128,
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString(),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        16,
                                        46,
                                        128,
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.black,
                              ),
                              label: const Text("Submit Result"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
