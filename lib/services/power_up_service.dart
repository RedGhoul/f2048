import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/power_up.dart';

class PowerUpService {
  static PowerUpService? _instance;
  static const String _inventoryKey = 'power_up_inventory';

  PowerUpInventory? _inventory;

  PowerUpService._();

  static PowerUpService get instance {
    _instance ??= PowerUpService._();
    return _instance!;
  }

  // Initialize and load inventory
  Future<PowerUpInventory> loadInventory() async {
    if (_inventory != null) return _inventory!;

    final prefs = await SharedPreferences.getInstance();
    final String? inventoryJson = prefs.getString(_inventoryKey);

    if (inventoryJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(inventoryJson);
        _inventory = PowerUpInventory.fromJson(json);
      } catch (e) {
        _inventory = PowerUpInventory();
      }
    } else {
      _inventory = PowerUpInventory();
    }

    return _inventory!;
  }

  // Save inventory
  Future<void> saveInventory() async {
    if (_inventory == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String inventoryJson = jsonEncode(_inventory!.toJson());
    await prefs.setString(_inventoryKey, inventoryJson);
  }

  // Get current inventory
  PowerUpInventory get inventory {
    if (_inventory == null) {
      throw StateError('Inventory not loaded. Call loadInventory() first.');
    }
    return _inventory!;
  }

  // Use a power-up
  Future<bool> usePowerUp(PowerUpType type) async {
    await loadInventory();
    if (!_inventory!.canUse(type)) {
      return false;
    }
    _inventory!.use(type);
    await saveInventory();
    return true;
  }

  // Add power-ups
  Future<void> addPowerUps(PowerUpType type, int count) async {
    await loadInventory();
    _inventory!.add(type, count);
    await saveInventory();
  }

  // Get count of a specific power-up
  int getCount(PowerUpType type) {
    if (_inventory == null) return 0;
    return _inventory!.getCount(type);
  }

  // Check if can use a power-up
  bool canUse(PowerUpType type) {
    if (_inventory == null) return false;
    return _inventory!.canUse(type);
  }
}
