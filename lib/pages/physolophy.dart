import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerPhilosophyPage extends StatelessWidget {
  const PlayerPhilosophyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Goat's Philosophies",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlayerCard(
            name: "Joby",
            quote: "Mind game is everything.",
            description:
                "Joby embodies the cerebral side of football. His game is built on mental strength, strategy, and reading the opponent’s next move. He believes matches are won in the mind before the pitch.",
            imagePath: 'assets/images/joby.png',
            audioPath: 'audios/joby_theme.mp3', // Updated path
          ),
          SizedBox(height: 20),
          PlayerCard(
            name: "Vineeth",
            quote: "Improvise. Adapt. Overcome.",
            description:
                "Vineeth thrives in chaos. He adjusts tactics on the fly, bends to any challenge, and turns obstacles into opportunities. Her game is fluid, responsive, and fearless.",
            imagePath: 'assets/images/vineeth.png',
            audioPath: 'audios/vineeth_theme.mp3', // Updated path
          ),
          SizedBox(height: 20),
          PlayerCard(
            name: "Ajeesh",
            quote: "Play. Trust. Rise.",
            description:
                "Ajeesh is all about belief—in himself and in his team. He lifts others, trusts the process, and always bounces back stronger. His strength lies in unity, heart, and comebacks.",
            imagePath: 'assets/images/ajeesh.png',
            audioPath: 'audios/ajeesh_theme.mp3', // Updated path
          ),
        ],
      ),
    );
  }
}

class PlayerCard extends StatefulWidget {
  final String name;
  final String quote;
  final String description;
  final String imagePath;
  final String audioPath;

  const PlayerCard({
    super.key,
    required this.name,
    required this.quote,
    required this.description,
    required this.imagePath,
    required this.audioPath,
  });

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isStopped = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Ensure auto-stop
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio() async {
    await _audioPlayer.stop(); // Stop any previous
    await _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
    await _audioPlayer.play(AssetSource(widget.audioPath)); // Fixed path usage
    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _isStopped = false;
    });
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
      _isStopped = false;
    });
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _isStopped = true;
    });
  }

  void _muteAudio() async {
    if (_isMuted) {
      await _audioPlayer.setVolume(1.0);
    } else {
      await _audioPlayer.setVolume(0.0);
    }
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.imagePath,
                  width: 150,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.error,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${widget.quote}"',
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _isPlaying ? _pauseAudio : _playAudio,
                        ),
                        IconButton(
                          icon: Icon(Icons.stop, color: Colors.grey.shade700),
                          onPressed: _stopAudio,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _muteAudio,
            ),
          ),
        ],
      ),
    );
  }
}
