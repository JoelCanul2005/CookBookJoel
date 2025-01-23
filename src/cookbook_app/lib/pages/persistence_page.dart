import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class PersistencePage extends StatefulWidget {
  const PersistencePage({super.key});

  @override
  State<PersistencePage> createState() => _PersistencePageState();
}

class _PersistencePageState extends State<PersistencePage> {
  final TextEditingController _textController = TextEditingController();
  String _sqliteData = '';
  String _fileData = '';
  String _prefsData = '';
  late Database _database;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _initPrefs();
  }

  // Inicializar SQLite
  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'persistence_demo.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY, content TEXT)',
        );
      },
      version: 1,
    );
    _loadSqliteData();
  }

  // Inicializar SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPrefsData();
  }

  // Métodos SQLite
  Future<void> _saveSqliteData(String content) async {
    await _database.insert(
      'notes',
      {'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _loadSqliteData();
  }

  Future<void> _loadSqliteData() async {
    final List<Map<String, dynamic>> notes = await _database.query('notes');
    setState(() {
      _sqliteData = notes.map((note) => note['content'].toString()).join('\n');
    });
  }

  // Métodos File
  Future<void> _saveToFile(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/demo_file.txt');
    await file.writeAsString(content);
    _loadFileData();
  }

  Future<void> _loadFileData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/demo_file.txt');
      final content = await file.readAsString();
      setState(() {
        _fileData = content;
      });
    } catch (e) {
      setState(() {
        _fileData = 'No hay datos guardados';
      });
    }
  }

  // Métodos SharedPreferences
  Future<void> _savePrefsData(String content) async {
    await _prefs.setString('demo_key', content);
    _loadPrefsData();
  }

  void _loadPrefsData() {
    setState(() {
      _prefsData = _prefs.getString('demo_key') ?? 'No hay datos guardados';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Persistencia de Datos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Ingresa texto para guardar',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => _saveSqliteData(_textController.text),
                  child: const Text('Guardar en SQLite'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => _saveToFile(_textController.text),
                  child: const Text('Guardar en Archivo'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => _savePrefsData(_textController.text),
                  child: const Text('Guardar en Prefs'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDataSection('SQLite Data:', _sqliteData),
                  const Divider(color: Colors.white30),
                  _buildDataSection('File Data:', _fileData),
                  const Divider(color: Colors.white30),
                  _buildDataSection('SharedPreferences Data:', _prefsData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(String title, String content) {
    return Card(
      color: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content.isEmpty ? 'No hay datos' : content,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _database.close();
    super.dispose();
  }
}