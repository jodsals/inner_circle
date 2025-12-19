import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/research_paper_model.dart';

/// Service for interacting with CORE API
class CoreApiService {
  static const String _baseUrl = 'https://api.core.ac.uk/v3';
  static const String _apiKey = '8s9HFX7BYKIfhlM3Rk5reZW6qOmx4oNC';

  // API request headers
  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'application/json',
      };

  // Rate limit tracking
  int? _rateLimitMax;
  int? _rateLimitRemaining;
  DateTime? _rateLimitRetryAfter;

  /// Get current rate limit information
  Map<String, dynamic> getRateLimitInfo() {
    return {
      'limit': _rateLimitMax,
      'remaining': _rateLimitRemaining,
      'retryAfter': _rateLimitRetryAfter,
    };
  }

  /// Check if we can make a request (rate limit check)
  bool canMakeRequest() {
    if (_rateLimitRemaining != null && _rateLimitRemaining! <= 0) {
      if (_rateLimitRetryAfter != null && DateTime.now().isBefore(_rateLimitRetryAfter!)) {
        return false;
      }
    }
    return true;
  }

  /// Update rate limit from response headers
  void _updateRateLimits(http.Response response) {
    final headers = response.headers;

    // CORE API header names according to documentation
    // Note: Rate limit headers are not available for all API tiers
    // X-RateLimit-Limit: total requests allowed
    final limitKey = headers.keys.firstWhere(
      (k) => k.toLowerCase() == 'x-ratelimit-limit',
      orElse: () => '',
    );
    if (limitKey.isNotEmpty) {
      _rateLimitMax = int.tryParse(headers[limitKey] ?? '');
    }

    // X-RateLimitRemaining: remaining requests (note: no hyphen between Limit and Remaining!)
    final remainingKey = headers.keys.firstWhere(
      (k) => k.toLowerCase() == 'x-ratelimitremaining' || k.toLowerCase() == 'x-ratelimit-remaining',
      orElse: () => '',
    );
    if (remainingKey.isNotEmpty) {
      _rateLimitRemaining = int.tryParse(headers[remainingKey] ?? '');
    }

    // X-RateLimit-Retry-After: seconds to wait before retry
    final retryAfterKey = headers.keys.firstWhere(
      (k) => k.toLowerCase() == 'x-ratelimit-retry-after',
      orElse: () => '',
    );
    if (retryAfterKey.isNotEmpty) {
      final retryAfterSeconds = int.tryParse(headers[retryAfterKey] ?? '');
      if (retryAfterSeconds != null) {
        _rateLimitRetryAfter = DateTime.now().add(Duration(seconds: retryAfterSeconds));
      }
    }
  }

  /// Search for research papers by keyword
  /// Focus on health-related papers
  Future<List<ResearchPaperModel>> searchPapers(
    String query, {
    int page = 1,
    int pageSize = 10,
    String? language,
    int? yearFrom,
    int? yearTo,
  }) async {
    if (!canMakeRequest()) {
      throw Exception('Rate limit exceeded. Please try again later.');
    }

    try {
      // Add health-related filter to query if not already present
      String searchQuery = query;
      if (!query.toLowerCase().contains('health') &&
          !query.toLowerCase().contains('medical') &&
          !query.toLowerCase().contains('medicine')) {
        searchQuery = '$query health';
      }

      // Build advanced query with filters
      final queryParts = <String>[searchQuery];

      // Add language filter if specified
      if (language != null && language.isNotEmpty) {
        queryParts.add('language:"$language"');
      }

      // Add year range filter if specified
      if (yearFrom != null) {
        queryParts.add('yearPublished>=$yearFrom');
      }
      if (yearTo != null) {
        queryParts.add('yearPublished<=$yearTo');
      }

      // Combine query parts with AND
      final finalQuery = queryParts.join(' AND ');

      // Build URL for v3 API - uses /search/works endpoint
      final uri = Uri.parse('$_baseUrl/search/works')
          .replace(queryParameters: {
        'q': finalQuery,
        'limit': pageSize.toString(),
        'offset': ((page - 1) * pageSize).toString(),
      });

      final response = await http.get(uri, headers: _headers);

      _updateRateLimits(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final papers = <ResearchPaperModel>[];

        // v3 API returns results in 'results' array
        if (data['results'] != null && data['results'] is List) {
          for (var item in data['results'] as List) {
            try {
              papers.add(ResearchPaperModel.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              // Skip invalid entries
              continue;
            }
          }
        }

        return papers;
      } else if (response.statusCode == 204) {
        // No content - return empty list
        return [];
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 500) {
        // Server error - return empty list instead of throwing
        print('CORE API server error (500). Returning empty list.');
        return [];
      } else {
        throw Exception('Failed to search papers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching papers: $e');
    }
  }

  /// Get default health-related papers
  Future<List<ResearchPaperModel>> getHealthNews({int page = 1, int pageSize = 10}) async {
    // Try with a simple query first
    try {
      return await searchPapers('health', page: page, pageSize: pageSize);
    } catch (e) {
      // If search fails, try with an even simpler query
      if (e.toString().contains('500')) {
        try {
          return await searchPapers('medicine', page: page, pageSize: pageSize);
        } catch (e2) {
          // Return empty list instead of throwing error
          return [];
        }
      }
      rethrow;
    }
  }

  /// Get paper metadata by ID
  Future<ResearchPaperModel?> getPaperById(String paperId) async {
    if (!canMakeRequest()) {
      throw Exception('Rate limit exceeded. Please try again later.');
    }

    try {
      // v3 API uses /outputs/{id} endpoint
      final uri = Uri.parse('$_baseUrl/outputs/$paperId');

      final response = await http.get(uri, headers: _headers);

      _updateRateLimits(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ResearchPaperModel.fromJson(data);
      } else {
        throw Exception('Failed to get paper: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting paper: $e');
    }
  }

  /// Download PDF for a paper and return the local file path
  /// Returns null if download fails or PDF is not available
  Future<String?> downloadPdf(String paperId, String paperTitle) async {
    if (!canMakeRequest()) {
      throw Exception('Rate limit exceeded. Please try again later.');
    }

    try {
      // Use CORE API v3 download endpoint
      final uri = Uri.parse('$_baseUrl/works/$paperId/download?format=pdf');

      final response = await http.get(uri, headers: _headers);

      _updateRateLimits(response);

      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();

        // Create a safe filename from the paper title
        final safeTitle = paperTitle
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .substring(0, paperTitle.length > 50 ? 50 : paperTitle.length);

        final filePath = '${tempDir.path}/$safeTitle.pdf';
        final file = File(filePath);

        // Write PDF data to file
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else if (response.statusCode == 404) {
        // PDF not available
        return null;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }
}
