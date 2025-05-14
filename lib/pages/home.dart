import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:data_table_2/data_table_2.dart';
import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:efootballranking/controller/player_controller.dart';
import 'package:efootballranking/pages/match_result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigateToAddForm(BuildContext context) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerMatchResultPage()),
      );
      context.read<PlayerProvider>().fetchPlayers();
    } catch (e) {
      log('Error navigating to add form: $e'); // Log error
    }
  }

  void downloadTableAsPdf(
    BuildContext context,
    List<Map<String, dynamic>> players,
  ) async {
    try {
      final pdf = pw.Document();
      final tableHeaders = [
        'Rank',
        'Name',
        'MP',
        'Won',
        'Draw',
        'Lost',
        'Points',
        'Win %',
        'Form',
      ];

      final tableData =
          players.asMap().entries.map((entry) {
            int index = entry.key;
            var p = entry.value;
            return [
              '${index + 1}',
              p['name'].toString().toUpperCase(),
              '${p['played']}',
              '${p['won']}',
              '${p['draw']}',
              '${p['lost']}',
              '${p['points']}',
              '${p['win_percent'].toStringAsFixed(1)}',
              '${p['form']}',
            ];
          }).toList();

      pdf.addPage(
        pw.Page(
          build:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'E-Football Leaderboard',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table.fromTextArray(
                    headers: tableHeaders,
                    data: tableData,
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    cellAlignment: pw.Alignment.centerLeft,
                  ),
                ],
              ),
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'leaderboard.pdf',
      );
    } catch (e) {
      log('Error downloading table as PDF: $e'); // Log error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
    }
  }

  void downloadTableAsImage(BuildContext context, GlobalKey repaintKey) async {
    try {
      // Capture the image of the widget
      RenderRepaintBoundary boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Create a temporary file to store the image
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/leaderboard.png');
      await file.writeAsBytes(pngBytes);

      // Share the image using shareXFiles (share_plus v6.0.0 or higher)
      await Share.shareXFiles([
        XFile(file.path), // Pass the XFile object with the file path
      ], text: 'Check out this leaderboard image!');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Leaderboard shared!')));
    } catch (e) {
      log('Error sharing image: $e'); // Log error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final players = provider.players;
    final repaintKey = GlobalKey();
    log('🏠 HomePage rebuilt. Player count: ${players.length}');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 21, 22),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'E-Football Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.amber,
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () => downloadTableAsPdf(context, players),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.amber),
            tooltip: 'Download as PDF',
          ),
          IconButton(
            onPressed: () => downloadTableAsImage(context, repaintKey),
            icon: const Icon(Icons.image, color: Colors.amber),
            tooltip: 'Download as Image',
          ),
        ],
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : players.isEmpty
              ? const Center(
                child: Text(
                  'No player data found',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
              : RepaintBoundary(
                key: repaintKey,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DataTable2(
                    headingRowColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 43, 14, 172),
                    ),
                    dataRowColor: WidgetStateProperty.all(
                      const Color(0xFF222222),
                    ),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 800,
                    columns: [
                      _styledColumn('RANK'),
                      _styledColumn('NAME'),
                      _styledColumn('MP'),
                      _styledColumn('WON'),
                      _styledColumn('DRAW'),
                      _styledColumn('LOST'),
                      _styledColumn('POINTS'),
                      _styledColumn('WIN %'),
                      _styledColumn('FORM'),
                    ],
                    rows:
                        players.asMap().entries.map((entry) {
                          int index = entry.key;
                          var p = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p['name'].toString().toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text('${p['played']}', style: _dataStyle()),
                              ),
                              DataCell(
                                Text('${p['won']}', style: _dataStyle()),
                              ),
                              DataCell(
                                Text('${p['draw']}', style: _dataStyle()),
                              ),
                              DataCell(
                                Text('${p['lost']}', style: _dataStyle()),
                              ),
                              DataCell(
                                Text(
                                  '${p['points']}',
                                  style: _dataStyle(color: Colors.greenAccent),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${p['win_percent'].toStringAsFixed(1)}',
                                  style: _dataStyle(),
                                ),
                              ),
                              DataCell(
                                Text('${p['form']}', style: _dataStyle()),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => navigateToAddForm(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  DataColumn _styledColumn(String title) {
    return DataColumn(
      label: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  TextStyle _dataStyle({Color color = Colors.white}) {
    return TextStyle(fontSize: 14, color: color);
  }
}
