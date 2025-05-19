import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        title: const Text(
          'About This App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚽ eFootRank',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app was born during one of those epic late-night matches when Vineeth scored a hat-trick '
              'and then sighed... not from exhaustion, but from having to update the Excel sheet again.\n\n'
              'So he said, "No more!" and boom 💥 — the idea was born!\n\n'
              'From rage-quit moments in spreadsheets to rage-quits on the pitch, this app is dedicated to all the '
              'ballers who just want to see their wins, losses, and draws — without formulas crashing.\n\n'
              'Massive thanks to 🧠 Vineeth, the mastermind behind this madness.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '📬 Connect with aj_labs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mail, color: Colors.white),
                  onPressed: () => _launchUrl('mailto:ajeeshrko@gmail.com'),
                  tooltip: 'Email',
                ),
                IconButton(
                  icon: const Icon(Icons.link, color: Colors.white),
                  onPressed:
                      () => _launchUrl(
                        'https://www.linkedin.com/in/ajeesh-das-h-601938128/',
                      ),
                  tooltip: 'LinkedIn',
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed:
                      () => _launchUrl(
                        'https://www.instagram.com/ajeesh_aj_abi?igsh=MTBqeTI4eW1rcjc2bg==',
                      ),
                  tooltip: 'Instagram',
                ),
              ],
            ),
            const SizedBox(height: 50),
            const Divider(color: Colors.white30),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Built with ⚡ Passion & ❤️ by Team eFootball_Updates\nDeveloped by AJ_Labs\n© 2025 All rights reserved',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
