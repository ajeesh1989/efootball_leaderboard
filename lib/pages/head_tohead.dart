import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efootballranking/controller/match_result_controller.dart';

class HeadToHeadPage extends StatefulWidget {
  const HeadToHeadPage({Key? key}) : super(key: key);

  @override
  _HeadToHeadPageState createState() => _HeadToHeadPageState();
}

class _HeadToHeadPageState extends State<HeadToHeadPage> {
  // A flag to indicate whether players are still being fetched.
  bool _isPlayersLoading = true;

  @override
  void initState() {
    super.initState();
    // Schedule the fetchPlayers call after the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PlayerMatchResultProvider>(
        context,
        listen: false,
      );
      provider
          .fetchPlayers()
          .then((_) {
            if (mounted) {
              setState(() {
                _isPlayersLoading = false;
              });
            }
          })
          .catchError((error) {
            debugPrint("Error loading players: $error");
            if (mounted) {
              setState(() {
                _isPlayersLoading = false;
              });
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider so we get updates.
    final provider = Provider.of<PlayerMatchResultProvider>(context);

    // While waiting for players to load, display a loading indicator.
    if (_isPlayersLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Head-to-Head Stats')),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    // Check if any players exist.
    if (provider.players.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Head-to-Head Stats')),
        body: const Center(child: Text("No players available")),
      );
    }

    // Ensure there are at least 2 players.
    if (provider.players.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Head-to-Head Stats')),
        body: const Center(child: Text("Not enough players available")),
      );
    }

    // Obtain player UUIDs dynamically from provider data.
    final String playerAId = provider.players[0]['id'];
    final String playerBId = provider.players[1]['id'];

    return Scaffold(
      appBar: AppBar(title: const Text('Head-to-Head Stats')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: provider.fetchHeadToHeadData(playerAId, playerBId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            debugPrint("FutureBuilder error: ${snapshot.error}");
            return const Center(
              child: Text("Error fetching head-to-head data"),
            );
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Matches Completed: ${data['totalMatches']}"),
                const SizedBox(height: 8),
                Text("Player A Wins: ${data['player1Wins']}"),
                const SizedBox(height: 8),
                Text("Player B Wins: ${data['player2Wins']}"),
                const SizedBox(height: 8),
                Text("Draws: ${data['draws']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
