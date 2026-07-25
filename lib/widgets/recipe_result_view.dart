import 'package:chef_buddy/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Parses recipe markdown that uses `## Section Title` headers (as produced
/// by our Gemini prompts) into distinct, nicely styled cards — instead of
/// dumping one long raw markdown blob on the user.
///
/// Falls back gracefully to plain markdown rendering if no `##` headers are
/// found (e.g. an older-format response, or an error string).
class RecipeResultView extends StatelessWidget {
  final String markdown;

  const RecipeResultView({super.key, required this.markdown});

  List<_Section> _parseSections(String text) {
    final headerPattern = RegExp(r'^##\s+(.+)$', multiLine: true);
    final matches = headerPattern.allMatches(text).toList();
    if (matches.isEmpty) return [];

    final sections = <_Section>[];
    for (var i = 0; i < matches.length; i++) {
      final title = matches[i].group(1)!.trim();
      final contentStart = matches[i].end;
      final contentEnd =
          i + 1 < matches.length ? matches[i + 1].start : text.length;
      final content = text.substring(contentStart, contentEnd).trim();
      sections.add(_Section(title: title, content: content));
    }
    return sections;
  }

  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('recipe name')) return Icons.restaurant_menu;
    if (t.contains('ingredient')) return Icons.shopping_cart_outlined;
    if (t.contains('instruction') || t.contains('step')) {
      return Icons.list_alt;
    }
    if (t.contains('nutrition')) return Icons.bar_chart;
    if (t.contains('suggest')) return Icons.lightbulb_outline;
    return Icons.book_outlined;
  }

  MarkdownStyleSheet _bodyStyle() {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
      strong:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      em: const TextStyle(color: Colors.black87),
      listBullet: const TextStyle(color: kPrimaryColor),
      h1: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      h2: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      h3: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      a: const TextStyle(color: Colors.blue),
      code: const TextStyle(
        color: Colors.black87,
        backgroundColor: Color(0xFFF3F3F3),
        fontSize: 13,
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String content,
    required Color accent,
    required Color background,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(_iconFor(title), color: accent, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: MarkdownBody(
              data: content,
              styleSheet: _bodyStyle(),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _parseSections(markdown);

    // Fallback: no ## headers detected, just render plain markdown.
    if (sections.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimaryColor, width: 1.5),
        ),
        child: MarkdownBody(
          data: markdown,
          styleSheet: _bodyStyle(),
          shrinkWrap: true,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) {
        final isRecipeName = s.title.toLowerCase().contains('recipe name');
        final isSuggestion = s.title.toLowerCase().contains('suggest');

        if (isRecipeName) {
          // Hero-style header for the dish name — not a boxed card.
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryColor, Color(0xFFF4A265)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu,
                      color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.content.replaceAll(RegExp(r'[*_]'), '').trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _sectionCard(
          title: s.title,
          content: s.content,
          accent: isSuggestion ? const Color(0xFFC98A00) : kPrimaryColor,
          background: isSuggestion ? const Color(0xFFFFF8E8) : Colors.white,
        );
      }).toList(),
    );
  }
}

class _Section {
  final String title;
  final String content;
  _Section({required this.title, required this.content});
}
