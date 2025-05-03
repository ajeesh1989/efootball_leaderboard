import 'package:carousel_slider/carousel_slider.dart';
import 'package:efootballranking/controller/player_controller.dart';
import 'package:efootballranking/pages/entry_list_screen.dart';
import 'package:efootballranking/pages/home.dart';
import 'package:efootballranking/pages/player_list_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _updateTime();
    Timer.periodic(Duration(seconds: 60), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a', 'en_US').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.amber, size: 20),
            SizedBox(width: 4),
            Text('69', style: TextStyle(color: Colors.white, fontSize: 15)),
            Spacer(),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.people, color: Colors.blue, size: 28),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.mail, color: Colors.blue, size: 26),
            ),
            Icon(Icons.access_time, color: Colors.white, size: 15),
            SizedBox(width: 4),
            Text(
              _currentTime,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30), // Ensures proper size for TabBar
          child: Container(
            color: const Color.fromARGB(
              255,
              28,
              28,
              28,
            ), // Black background for TabBar
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.grey.shade700, // Grey color for the indicator
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              indicatorPadding: EdgeInsets.symmetric(
                horizontal: -40,
                vertical: 8,
              ),
              tabs: [
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Home',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Players',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Data',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGridButtons(),
          PlayerListPage(),
          Center(
            child: Text('Profile Page', style: TextStyle(color: Colors.white)),
          ),
          EntryListScreen(), // Directly load the screen here
        ],
      ),
    );
  }

  Widget _buildGridButtons() {
    final List<Map<String, dynamic>> gridItems = [
      {
        'icon': Icons.table_chart,
        'label': 'Table',
        'color': Colors.cyan,
        'route': '/table',
      },
      {
        'icon': Icons.sports_soccer,
        'label': 'Add Result',
        'color': Colors.lightGreen.shade600,
        'route': '/add_result',
      },
      {
        'icon': Icons.person_add,
        'label': 'Add Player',
        'color': const Color.fromARGB(255, 228, 7, 88),
        'route': '/add_player',
      },
      {
        'icon': Icons.settings,
        'label': 'Settings',
        'color': const Color.fromARGB(255, 195, 4, 169),
        'route': '/settings',
      },
      {
        'icon': Icons.bar_chart,
        'label': 'Report',
        'color': Colors.amber.shade700,
        'route': '/report',
      },
    ];

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 178.0,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                aspectRatio: 16 / 9,
              ),
              items:
                  [
                    buildTopRankingCard(context),
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIc6W_L209uBv2oeNJR16Pc5HSM_vEC34MtQ&s',
                    'https://i0.wp.com/uploads.saigacdn.com/2024/10/efootball-championship-25-00.jpg',
                  ].map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          url is Widget
                              ? url
                              : Image.network(
                                url.toString(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                    );
                  }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 3, left: 80, right: 80),
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 40,
              crossAxisSpacing: 20,
              childAspectRatio: 0.9,
              children:
                  gridItems.map((item) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap:
                              () => Navigator.pushNamed(context, item['route']),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: item['color'],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                item['icon'],
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          item['label'],
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopRankingCard(BuildContext context) {
    final players = context.watch<PlayerProvider>().players;

    // Take top 3 or less if not available
    final topPlayers = players.take(3).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🏆 Top Rankings",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (topPlayers.isEmpty)
              const Center(
                child: Text(
                  "No data to show",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            else
              ...topPlayers.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final colors = [Colors.amber, Colors.grey, Colors.brown];

                final playerName = p['name'] as String;
                final playerPoints = p['points'] as int;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: colors[i], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          playerName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "$playerPoints points",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
