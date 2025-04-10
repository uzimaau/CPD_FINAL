import 'package:cpd_final/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/game.dart';
import '../../services/firebase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class GameFormPage extends StatefulWidget {
  final Game? gameToEdit;

  const GameFormPage({Key? key, this.gameToEdit}) : super(key: key);

  @override
  _GameFormPageState createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  String _name = '';
  String _platform = '';
  String _progress = '';
  DateTime _lastPlayed = DateTime.now();
  String _location = '';

  @override
  void initState() {
    super.initState();
    if (widget.gameToEdit != null) {
      _name = widget.gameToEdit!.name;
      _platform = widget.gameToEdit!.platform;
      _progress = widget.gameToEdit!.progress;
      _lastPlayed = DateFormat(
        'yyyy-MM-dd',
      ).parse(widget.gameToEdit!.lastPlayed);
      _location = widget.gameToEdit!.location ?? '';
    }
  }

  bool get _isFormValid {
    return _name.isNotEmpty && _platform.isNotEmpty && _progress.isNotEmpty;
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _location = '${position.latitude}, ${position.longitude}';
    });
  }

  Future<void> _showNotification(String message) async {
    var androidDetails = AndroidNotificationDetails(
      'game_tracker_channel',
      'Game Tracker Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Game Tracker',
      message,
      platformDetails,
      payload: 'game_added',
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _getLocation();
      final gameId =
          widget.gameToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final game = Game(
        id: gameId,
        name: _name,
        platform: _platform,
        progress: _progress,
        lastPlayed: DateFormat('yyyy-MM-dd').format(_lastPlayed),
        location: _location,
      );

      if (widget.gameToEdit != null) {
        await _firebaseService.updateGame(game);
      } else {
        await _firebaseService.saveGame(game);
      }

      _showNotification('Game "${game.name}" added successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game saved successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameToEdit == null ? 'Add Game' : 'Edit Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Game Name'),
                onChanged: (val) {
                  setState(() {
                    _name = val.trim();
                  });
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _platform,
                decoration: const InputDecoration(labelText: 'Platform'),
                onChanged: (val) {
                  setState(() {
                    _platform = val.trim();
                  });
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'Platform is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _progress.isEmpty ? null : _progress,
                decoration: const InputDecoration(labelText: 'Progress'),
                items: const [
                  DropdownMenuItem(value: 'Unplayed', child: Text('Unplayed')),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(value: 'Complete', child: Text('Complete')),
                ],
                onChanged: (val) {
                  setState(() {
                    _progress = val ?? '';
                  });
                },
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Progress is required'
                            : null,
              ),
              const SizedBox(height: 16),
              InputDatePickerFormField(
                initialDate: _lastPlayed,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                onDateSubmitted: (val) {
                  setState(() {
                    _lastPlayed = val;
                  });
                },
                onDateSaved: (val) {
                  setState(() {
                    _lastPlayed = val;
                  });
                },
                errorFormatText: 'Invalid format',
                errorInvalidText: 'Invalid date',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isFormValid ? _submitForm : null,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
