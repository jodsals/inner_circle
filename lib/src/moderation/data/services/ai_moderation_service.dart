import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/moderation_result_model.dart';

/// Service for AI-based content moderation using Ollama
class AIModerationService {
  final String baseUrl;
  final String model;
  final http.Client httpClient;
  final SecureStorageService _secureStorage;

  AIModerationService({
    this.baseUrl = 'http://3.74.164.83:3000', // Deine Server-URL
    this.model = 'llama3.2',
    required SecureStorageService secureStorage,
    http.Client? httpClient,
  })  : httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage;

  /// Analyze content for harmful speech
  /// Returns a ModerationResult with flags and confidence score
  Future<ModerationResultModel> analyzeContent(String content) async {
    try {
      if (content.trim().isEmpty) {
        return const ModerationResultModel(
          isFlagged: false,
          reasons: [],
          analysis: 'Leerer Inhalt',
          confidenceScore: 0.0,
        );
      }

      // Create moderation prompt for AI
      final prompt = _createModerationPrompt(content);

      // Call Ollama API
      final response = await _callOllama(prompt).timeout(
        const Duration(seconds: 30),
      );

      // Parse response
      return _parseModerationResponse(response);
    } catch (e) {
      // Log error (implement proper logging)
      print('AI Moderation Service Error: $e');

      // Return a default safe result on error
      return ModerationResultModel(
        isFlagged: false,
        reasons: [],
        analysis: 'Moderation konnte nicht durchgeführt werden: ${e.toString()}',
        confidenceScore: 0.0,
      );
    }
  }

  /// Create a moderation prompt for the AI model
  String _createModerationPrompt(String content) {
    return '''
Analysiere den folgenden nutzergenerierten Inhalt auf schädliche, problematische oder regelwidrige Inhalte.

Antworte AUSSCHLIESSLICH mit einem gültigen JSON-Objekt mit genau diesen Feldern:
- isFlagged: boolean (true, wenn der Inhalt problematisch ist)
- reasons: Array von Strings (konkrete Gründe, z. B. "hateSpeech", "harassment", "violence", "profanity", "sexualContent", "dangerousActivities")
- confidenceScore: Zahl zwischen 0 und 1 (wie sicher die Bewertung ist)
- summary: kurzer deutscher Erklärungstext, warum der Inhalt markiert oder nicht markiert wurde

Zu prüfende Kategorien:
- Hate Speech: diskriminierende oder herabwürdigende Sprache gegenüber Personen oder Gruppen (z. B. aufgrund von Herkunft, Religion, Geschlecht, sexueller Orientierung, Nationalität oder Behinderung)
- Belästigung: Beleidigungen, Mobbing, Drohungen, Einschüchterung oder persönliche Angriffe
- Gewalt: Androhung, Verherrlichung oder detaillierte Beschreibung von Gewalt
- Vulgäre Sprache: übermäßige oder aggressive Verwendung von Schimpfwörtern
- Sexuelle Inhalte: explizite sexuelle Sprache oder Aufforderungen
- Gefährliche Handlungen: Förderung von Selbstverletzung, gefährlichen Mutproben oder illegalen Aktivitäten

Zu analysierender Inhalt:
"""
$content
"""

WICHTIG:
- Gib **NUR** das JSON-Objekt zurück
- KEINE Erklärungen, KEIN Markdown, KEIN zusätzlicher Text
''';
  }


  /// Call Ollama API with the prompt
  Future<String> _callOllama(String prompt) async {
    try {
      final url = Uri.parse('$baseUrl/api/generate');

      // ============================================================
      // HIER WIRD DER JWT_TOKEN ABGERUFEN UND VERWENDET
      // ============================================================
      final token = await _secureStorage.read(key: 'ollama_bearer_token');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // ← BEARER TOKEN
      };

      final response = await httpClient.post(
        url,
        headers: headers,
        body: jsonEncode({
          'model': model,
          'prompt': prompt, // Angepasst für /api/generate endpoint
          'stream': false,
        }),
      );

      print(response.body);

      if (response.statusCode != 200) {
        throw ServerException(
          'Ollama API error: ${response.statusCode} - ${response.body}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // Für /api/generate endpoint ist die Antwort in 'response' field
      final content = jsonResponse['response'] as String?;

      if (content == null || content.isEmpty) {
        throw ServerException('Empty response from Ollama');
      }

      return content;
    } catch (e) {
      throw ServerException('Failed to call Ollama API: $e');
    }
  }

  /// Parse the moderation response from Ollama
  ModerationResultModel _parseModerationResponse(String response) {
    try {
      return ModerationResultModel.fromOllamaResponse(response);
    } catch (e) {
      // If parsing fails, return safe result
      return ModerationResultModel(
        isFlagged: false,
        reasons: [],
        analysis: 'Fehler beim Parsen der Moderation: $e',
        confidenceScore: 0.0,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    httpClient.close();
  }
}