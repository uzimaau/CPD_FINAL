import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/game.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Save a new game to Firebase
  Future<void> saveGame(Game game) async {
    try {
      await _database.child('games/${game.id}').set(game.toMap());
      print('Game saved to Firebase: ${game.toMap()}'); // Debug log
    } catch (e) {
      debugPrint("Failed to save game: $e");
    }
  }

  // Fetch all games from Firebase
  Future<List<Game>> fetchGames() async {
    try {
      final snapshot = await _database.child('games').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(
          snapshot.value as Map,
        ); // Ensure proper map conversion

        print("Fetched Firebase Data: $data"); // Debug log

        return data.entries.map((entry) {
          return Game.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
            entry.key,
          ); // Ensure correct map conversion
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Failed to fetch games: $e");
      return [];
    }
  }

  // Update an existing game in Firebase
  Future<void> updateGame(Game game) async {
    try {
      await _database.child('games/${game.id}').update(game.toMap());
      print('Game updated in Firebase: ${game.toMap()}'); // Debug log
    } catch (e) {
      debugPrint("Failed to update game: $e");
    }
  }

  // Delete a game from Firebase
  Future<void> deleteGame(String id) async {
    try {
      await _database.child('games/$id').remove();
      print('Game deleted from Firebase: $id'); // Debug log
    } catch (e) {
      debugPrint("Failed to delete game: $e");
    }
  }
}
