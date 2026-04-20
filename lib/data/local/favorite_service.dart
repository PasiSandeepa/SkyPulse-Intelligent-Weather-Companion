import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class FavoriteService {
  static const String _boxName = 'favorites';
  late Box _box;
  
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }
  
  List<String> getFavorites() {
    return _box.values.cast<String>().toList();
  }
  
  Future<void> addFavorite(String city) async {
    if (!_box.values.contains(city)) {
      await _box.add(city);
    }
  }
  
  Future<void> removeFavorite(String city) async {
    final key = _box.values.toList().indexOf(city);
    if (key != -1) {
      await _box.deleteAt(key);
    }
  }
  
  bool isFavorite(String city) {
    return _box.values.contains(city);
  }
  
  ValueListenable<Box> get listenable => _box.listenable();
}