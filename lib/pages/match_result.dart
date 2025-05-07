import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:efootballranking/pages/playerpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerMatchResultPage extends StatelessWidget {
  const PlayerMatchResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      context.read<PlayerMatchResultProvider>().fetchPlayers();
    });

    return Consumer<PlayerMatchResultProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            title: const Text("Match Result"),
            backgroundColor: const Color(0xFF191919),
            foregroundColor: Colors.amber,
          ),
          body:
              provider.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
                  : SingleChildScrollView(
                    // padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        // Dropdown for players
                        Card(
                          color: Colors.grey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
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
                              value: provider.selectedPlayer?['id'],
                              items:
                                  provider.players.map((player) {
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
                                if (val != null) {
                                  provider.selectPlayer(
                                    provider.players.firstWhere(
                                      (player) => player['id'] == val,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Radio buttons
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
                                    groupValue: provider.selectedResult,
                                    activeColor: Colors.amber,
                                    onChanged:
                                        (val) => provider.selectResult(val!),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PlayerNameFormPage(),
                                  ),
                                );
                                provider.fetchPlayers();
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
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await provider.submitMatchResult();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Match result submitted successfully!",
                                        style: TextStyle(color: Colors.amber),
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
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
