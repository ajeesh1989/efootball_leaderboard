import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EntryProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchEntries() async {
    _isLoading = true;
    notifyListeners();

    final res = await supabase
        .from('entries')
        .select('id, result, time, player_id, players(name)')
        .order('time', ascending: false);

    _entries = List<Map<String, dynamic>>.from(res);

    _isLoading = false;
    notifyListeners();
  }
}
