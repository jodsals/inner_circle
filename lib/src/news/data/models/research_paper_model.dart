import '../../domain/entities/research_paper.dart';

/// Data model for Research Paper
class ResearchPaperModel extends ResearchPaper {
  const ResearchPaperModel({
    required super.id,
    required super.title,
    super.abstract,
    super.authors,
    super.publishedDate,
    super.downloadUrl,
    super.pdfUrl,
    super.topics,
  });

  /// Create from JSON
  factory ResearchPaperModel.fromJson(Map<String, dynamic> json) {
    // Extract authors
    final authors = <String>[];
    if (json['authors'] != null) {
      if (json['authors'] is List) {
        for (var author in json['authors'] as List) {
          if (author is String) {
            authors.add(author);
          } else if (author is Map && author['name'] != null) {
            authors.add(author['name'] as String);
          }
        }
      }
    }

    // Extract topics/subjects
    final topics = <String>[];
    if (json['topics'] != null && json['topics'] is List) {
      topics.addAll((json['topics'] as List).map((e) => e.toString()));
    } else if (json['subjects'] != null && json['subjects'] is List) {
      topics.addAll((json['subjects'] as List).map((e) => e.toString()));
    }

    // Extract ID for CORE API download URL
    final workId = json['id']?.toString() ?? '';

    return ResearchPaperModel(
      id: workId,
      title: json['title'] as String? ?? 'Untitled',
      abstract: json['abstract'] as String? ?? json['description'] as String?,
      authors: authors,
      publishedDate: json['publishedDate'] as String? ??
          json['datePublished'] as String? ??
          json['year']?.toString(),
      // Use CORE API download endpoint instead of direct URL
      downloadUrl: workId.isNotEmpty
          ? 'https://api.core.ac.uk/v3/works/$workId/download?format=pdf'
          : (json['downloadUrl'] as String? ?? json['fullTextUrl'] as String?),
      pdfUrl: json['pdfUrl'] as String?,
      topics: topics,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'abstract': abstract,
      'authors': authors,
      'publishedDate': publishedDate,
      'downloadUrl': downloadUrl,
      'pdfUrl': pdfUrl,
      'topics': topics,
    };
  }
}
