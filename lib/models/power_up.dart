import 'package:flutter/cupertino.dart';

enum PowerUpType {
  shuffle,
  removeLowest,
  hint,
  rewind,
  scoreMultiplier,
}

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final IconData icon;
  final int cost; // Cost in virtual currency (for future monetization)

  PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    this.cost = 100,
  });
}

// Predefined power-ups
final Map<PowerUpType, PowerUp> powerUps = {
  PowerUpType.shuffle: PowerUp(
    type: PowerUpType.shuffle,
    name: 'Shuffle',
    description: 'Randomly rearrange all tiles on the board',
    icon: CupertinoIcons.shuffle,
    cost: 100,
  ),
  PowerUpType.removeLowest: PowerUp(
    type: PowerUpType.removeLowest,
    name: 'Remove Lowest',
    description: 'Remove the lowest value tile from the board',
    icon: CupertinoIcons.trash,
    cost: 150,
  ),
  PowerUpType.hint: PowerUp(
    type: PowerUpType.hint,
    name: 'Hint',
    description: 'Shows the best next move',
    icon: CupertinoIcons.lightbulb,
    cost: 200,
  ),
  PowerUpType.rewind: PowerUp(
    type: PowerUpType.rewind,
    name: 'Rewind',
    description: 'Go back 3-5 moves',
    icon: CupertinoIcons.arrow_uturn_left_circle,
    cost: 250,
  ),
  PowerUpType.scoreMultiplier: PowerUp(
    type: PowerUpType.scoreMultiplier,
    name: '2x Score',
    description: 'Double your score for the next 5 moves',
    icon: CupertinoIcons.multiply_circle,
    cost: 300,
  ),
};

class PowerUpInventory {
  Map<PowerUpType, int> inventory;

  PowerUpInventory({Map<PowerUpType, int>? inventory})
      : inventory = inventory ??
            {
              PowerUpType.shuffle: 3,
              PowerUpType.removeLowest: 3,
              PowerUpType.hint: 3,
              PowerUpType.rewind: 2,
              PowerUpType.scoreMultiplier: 2,
            };

  int getCount(PowerUpType type) => inventory[type] ?? 0;

  bool canUse(PowerUpType type) => getCount(type) > 0;

  void use(PowerUpType type) {
    if (canUse(type)) {
      inventory[type] = inventory[type]! - 1;
    }
  }

  void add(PowerUpType type, int count) {
    inventory[type] = (inventory[type] ?? 0) + count;
  }

  Map<String, dynamic> toJson() {
    return inventory.map((key, value) => MapEntry(key.toString(), value));
  }

  factory PowerUpInventory.fromJson(Map<String, dynamic> json) {
    final Map<PowerUpType, int> inv = {};
    json.forEach((key, value) {
      final type = PowerUpType.values.firstWhere((e) => e.toString() == key);
      inv[type] = value as int;
    });
    return PowerUpInventory(inventory: inv);
  }
}
