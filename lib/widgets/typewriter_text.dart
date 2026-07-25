import 'dart:async';

import 'package:flutter/material.dart';

/// Reveals [text] progressively, word by word, like ChatGPT/Claude's
/// streaming responses — even though the underlying API call already
/// returned the full text. Calls [onComplete] once fully revealed, and
/// [onProgress] on every reveal tick (handy for auto-scrolling).
///
/// Splits on whitespace while preserving the whitespace itself, so
/// newlines/spacing in the original markdown are kept intact.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration wordDelay;
  final VoidCallback? onComplete;
  final ValueChanged<String>? onProgress;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.wordDelay = const Duration(milliseconds: 10),
    this.onComplete,
    this.onProgress,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  late List<String> _tokens;
  int _visibleTokens = 0;
  Timer? _timer;

  // Reveal a few words per tick — feels just as "live" as one-at-a-time but
  // finishes in a fraction of the time for longer recipes.
  static const int _tokensPerTick = 5;

  @override
  void initState() {
    super.initState();
    _tokenize();
    _start();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _tokenize();
      _visibleTokens = 0;
      _start();
    }
  }

  void _tokenize() {
    // Each token is a word plus any whitespace that immediately follows it,
    // so spacing/newlines are preserved without doubling the token count
    // (which was making the reveal take twice as long as it needed to).
    _tokens = widget.text
        .split(RegExp(r'(?<=\S)(?=\s)'))
        .where((chunk) => chunk.isNotEmpty)
        .toList();
  }

  void _start() {
    if (_tokens.isEmpty) {
      widget.onComplete?.call();
      return;
    }
    _timer = Timer.periodic(widget.wordDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _visibleTokens =
            (_visibleTokens + _tokensPerTick).clamp(0, _tokens.length).toInt();
      });
      widget.onProgress?.call(_currentText());
      if (_visibleTokens >= _tokens.length) {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  String _currentText() => _tokens.take(_visibleTokens).join();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentText(), style: widget.style);
  }
}
