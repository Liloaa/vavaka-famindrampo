import 'package:flutter/material.dart';

class TexteSurligne extends StatelessWidget {
  final String texte;
  final String terme;
  final Color couleur;
  final int maxLines;
  final TextStyle? style;

  const TexteSurligne({
    super.key,
    required this.texte,
    required this.terme,
    required this.couleur,
    this.maxLines = 2,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (terme.isEmpty) {
      return Text(texte, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
    }
    final spans = <TextSpan>[];
    final lt = texte.toLowerCase();
    final lq = terme.toLowerCase();
    var debut = 0;
    while (true) {
      final i = lt.indexOf(lq, debut);
      if (i < 0) {
        spans.add(TextSpan(text: texte.substring(debut)));
        break;
      }
      if (i > debut) spans.add(TextSpan(text: texte.substring(debut, i)));
      spans.add(TextSpan(
        text: texte.substring(i, i + lq.length),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: couleur,
          backgroundColor: couleur.withValues(alpha: 0.12),
        ),
      ));
      debut = i + lq.length;
    }
    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}