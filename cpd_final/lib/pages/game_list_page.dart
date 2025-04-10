import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../services/firebase_service.dart';
import 'game_form_page.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final games = await _firebaseService.fetchGames();
      print("Fetched Games: $games");
      if (mounted) {
        setState(() {
          _games = games;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to fetch games')));
      }
    }
  }

  void _deleteGame(String id) async {
    await _firebaseService.deleteGame(id);
    if (mounted) {
      await _fetchGames();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Game deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _games.isEmpty
                ? const Center(child: Text('No games available'))
                : ListView(
                  children: _games.map((game) => _buildGameCard(game)).toList(),
                ),
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return Card(
      color: const Color(0xFFC2C2E1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(game.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: ${game.platform}'),
            Text('Progress: ${game.progress}'),
            Text('Last Played: ${game.lastPlayed}'),
            if (game.location != null) Text('Location: ${game.location}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameFormPage(gameToEdit: game),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteGame(game.id),
            ),
          ],
        ),
      ),
    );
  }
}
