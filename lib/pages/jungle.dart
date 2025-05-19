import 'package:flutter/material.dart';

class Player {
  final String name;
  final String animal;
  final String imagePath; // Foreground image (animal icon)
  final String backgroundPath; // Background image for card
  final String description;
  final int rating;

  Player({
    required this.name,
    required this.animal,
    required this.imagePath,
    required this.backgroundPath,
    required this.description,
    required this.rating,
  });
}

class JungleSoccerKingsPage extends StatelessWidget {
  JungleSoccerKingsPage({super.key});

  final List<Player> players = [
    Player(
      name: "Joby",
      animal: "Tiger",
      imagePath: "assets/images/tiger.png",
      backgroundPath: "assets/images/tigerreal.png",
      description:
          "Joby is a roaring storm — a ruthless predator stalking his prey. His razor-sharp precision slices through defenses like claws tearing flesh. With every deadly strike, he leaves opponents trembling. The jungle bows to the Tiger’s fierce dominance — unstoppable and legendary.",
      rating: 92,
    ),
    Player(
      name: "Vineeth",
      animal: "Lion",
      imagePath: "assets/images/lion.png",
      backgroundPath: "assets/images/lionreal.png",
      description:
          "Vineeth is the king of the concrete jungle — a force of raw power and unshakable authority. His iron defense and tactical genius crush challengers. With a roar that shakes the stadium, Vineeth commands and conquers, bending the game to his will.",
      rating: 91,
    ),
    Player(
      name: "Ajeesh",
      animal: "Wolf",
      imagePath: "assets/images/wolf.png",
      backgroundPath: "assets/images/wolfreal.png",
      description:
          "Ajeesh is a lightning-fast hunter of the shadows, striking with lethal speed and savage accuracy. Like a lone wolf, he exploits every gap, tearing through defenses with ferocious agility. Silent, swift, and deadly — the nightmare no one sees coming.",
      rating: 90,
    ),
  ];

  Widget _buildPlayerCard(Player player) {
    return Card(
      color: Colors.transparent, // make card transparent so image shows
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background image from the new backgroundPath
            Positioned.fill(
              child: Image.asset(
                player.backgroundPath,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(
                  0.6,
                ), // dark overlay for readability
                colorBlendMode: BlendMode.darken,
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(player.imagePath, width: 200, height: 200),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${player.animal} - ${player.name}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Overall Rating: ${player.rating}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    player.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontStyle: FontStyle.italic, // Italic style added here
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Jungle Speaks'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          return _buildPlayerCard(players[index]);
        },
      ),
    );
  }
}
