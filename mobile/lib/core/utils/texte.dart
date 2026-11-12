const _accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœ’‘`';
const _simples = "aaaaaaceeeeiiiinooooouuuuyyo'''";

/// Minuscules, sans accents, apostrophes unifiées.
/// La longueur reste identique : les positions trouvées restent valables.
String normaliser(String s) {
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    final i = _accents.indexOf(c);
    b.write(i >= 0 ? _simples[i] : c);
  }
  return b.toString();
}