import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import 'help_data.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const int _previewCount = 5;

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expanded = {};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HelpArticle> get _results {
    final q = _query.trim().toLowerCase();
    return [
      for (final section in helpSections)
        for (final article in section.articles)
          if (article.title.toLowerCase().contains(q) ||
              article.body.toLowerCase().contains(q))
            article,
    ];
  }

  void _openArticle(HelpArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpArticlePage(article: article),
      ),
    );
  }

  Widget _buildArticleTile(
    HelpArticle article,
    Color linkColor,
    Color dividerColor,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _openArticle(article),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (article.starred) ...[
                  Icon(Icons.star, color: Colors.red.shade300, size: 16),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    article.title,
                    style: TextStyle(color: linkColor, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: dividerColor, height: 1, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSection(
    HelpSection section,
    Color textColor,
    Color linkColor,
    Color dividerColor,
  ) {
    final isExpanded = _expanded.contains(section.title);
    final hasMore = section.articles.length > _previewCount;
    final visible = isExpanded || !hasMore
        ? section.articles
        : section.articles.take(_previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
          child: Text(
            section.title,
            style: TextStyle(color: textColor, fontSize: 26),
          ),
        ),
        for (final article in visible)
          _buildArticleTile(article, linkColor, dividerColor),
        if (hasMore)
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expanded.remove(section.title);
              } else {
                _expanded.add(section.title);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                isExpanded
                    ? "Show less"
                    : "See all ${section.articles.length} articles",
                style: TextStyle(color: linkColor, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
    final dividerColor = isDark ? Colors.grey.shade900 : Colors.grey.shade300;
    final linkColor = isDark ? Colors.lightBlue.shade200 : Colors.blue.shade700;
    final isSearching = _query.trim().isNotEmpty;
    final results = isSearching ? _results : <HelpArticle>[];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Help", style: TextStyle(color: textColor, fontSize: 18)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.savings, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  "Money Manager Help Center",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 20),
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor, fontSize: 15),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.accentRed),
                ),
              ),
            ),
          ),
          if (isSearching && results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  "No results found.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ),
            )
          else if (isSearching)
            for (final article in results)
              _buildArticleTile(article, linkColor, dividerColor)
          else
            for (final section in helpSections)
              _buildSection(section, textColor, linkColor, dividerColor),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class HelpArticlePage extends StatelessWidget {
  final HelpArticle article;

  const HelpArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : Colors.white;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Help", style: TextStyle(color: textColor, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: TextStyle(color: textColor, fontSize: 26),
            ),
            const SizedBox(height: 20),
            Text(
              article.body,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
