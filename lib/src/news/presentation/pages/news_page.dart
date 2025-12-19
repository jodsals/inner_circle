import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/research_paper.dart';
import '../providers/news_providers.dart';

/// News page displaying health-related research papers
class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _showFilters = false;
  String? _selectedLanguage;
  int? _yearFrom;
  int? _yearTo;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  Future<void> _downloadAndOpenPdf(String paperId, String paperTitle) async {
    if (!mounted) return;

    // For web browsers, open PDF in new tab (avoids CORS issues)
    if (kIsWeb) {
      final url = 'https://api.core.ac.uk/v3/works/$paperId/download?format=pdf';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF konnte nicht geöffnet werden')),
        );
      }
      return;
    }

    // For mobile/desktop: download and open PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text('PDF wird heruntergeladen...'),
          ],
        ),
        duration: Duration(hours: 1), // Will be dismissed manually
      ),
    );

    try {
      final downloadPdf = ref.read(downloadPdfProvider);
      final filePath = await downloadPdf(paperId, paperTitle);

      if (!mounted) return;

      // Dismiss loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF nicht verfügbar')),
        );
        return;
      }

      // Open the downloaded PDF
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Öffnen: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Dismiss loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rateLimitInfo = ref.watch(rateLimitInfoProvider);
    final papersAsync = _isSearching
        ? ref.watch(searchPapersProvider(SearchParams(
            query: _searchQuery,
            language: _selectedLanguage,
            yearFrom: _yearFrom,
            yearTo: _yearTo,
          )))
        : ref.watch(healthNewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesundheits-News'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showFilters ? 280 : 116),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nach Papers suchen...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),

              // Filter toggle button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(_showFilters ? Icons.expand_less : Icons.filter_list),
                  label: Text(_showFilters ? 'Filter verbergen' : 'Weitere Filter'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),

              // Filters section (collapsible)
              if (_showFilters) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language filter
                      DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: const InputDecoration(
                          labelText: 'Sprache',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Alle Sprachen')),
                          DropdownMenuItem(value: 'en', child: Text('Englisch')),
                          DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                          DropdownMenuItem(value: 'fr', child: Text('Französisch')),
                          DropdownMenuItem(value: 'es', child: Text('Spanisch')),
                        ],
                        onChanged: (value) => setState(() => _selectedLanguage = value),
                      ),
                      const SizedBox(height: 12),

                      // Year range filters
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _yearFrom,
                              decoration: const InputDecoration(
                                labelText: 'Von Jahr',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Beliebig')),
                                ...List.generate(25, (i) => 2000 + i).reversed.map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(() => _yearFrom = value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _yearTo,
                              decoration: const InputDecoration(
                                labelText: 'Bis Jahr',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Beliebig')),
                                ...List.generate(25, (i) => 2000 + i).reversed.map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(() => _yearTo = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Rate limit indicator - color bar only
              Container(
                width: double.infinity,
                height: 4,
                color: _getRateLimitColor(rateLimitInfo),
              ),
            ],
          ),
        ),
      ),
      body: papersAsync.when(
        data: (papers) {
          if (papers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSearching ? Icons.search_off : Icons.article_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching
                        ? 'Keine Ergebnisse gefunden'
                        : 'Keine Papers verfügbar',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching
                        ? 'Versuche eine andere Suchanfrage'
                        : 'Lade die Seite neu oder suche nach Papers',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_isSearching) {
                ref.invalidate(searchPapersProvider(SearchParams(
                  query: _searchQuery,
                  language: _selectedLanguage,
                  yearFrom: _yearFrom,
                  yearTo: _yearTo,
                )));
              } else {
                ref.invalidate(healthNewsProvider);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                return _PaperCard(
                  paper: papers[index],
                  onTap: () => _downloadAndOpenPdf(
                    papers[index].id,
                    papers[index].title,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Fehler beim Laden',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_isSearching) {
                      ref.invalidate(searchPapersProvider(SearchParams(
                        query: _searchQuery,
                        language: _selectedLanguage,
                        yearFrom: _yearFrom,
                        yearTo: _yearTo,
                      )));
                    } else {
                      ref.invalidate(healthNewsProvider);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
              onPressed: _performSearch,
              tooltip: 'Suchen',
              child: const Icon(Icons.search),
            ),
    );
  }

  Color _getRateLimitColor(Map<String, dynamic> info) {
    // Rate limit headers not available from API - always show green
    return Colors.green;
  }
}

/// Card widget for displaying a research paper
class _PaperCard extends StatelessWidget {
  final ResearchPaper paper;
  final VoidCallback onTap;

  const _PaperCard({
    required this.paper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      paper.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 20, color: Colors.blue),
                ],
              ),

              const SizedBox(height: 8),

              // Authors and date
              if (paper.authors.isNotEmpty || paper.publishedDate != null) ...[
                Row(
                  children: [
                    if (paper.authors.isNotEmpty) ...[
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          paper.authors.take(3).join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (paper.publishedDate != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        paper.publishedDate!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Abstract
              if (paper.abstract != null && paper.abstract!.isNotEmpty) ...[
                Text(
                  paper.abstract!,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Topics
              if (paper.topics.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: paper.topics.take(3).map((topic) {
                    return Chip(
                      label: Text(topic),
                      labelStyle: const TextStyle(fontSize: 11),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
