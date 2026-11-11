import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../data/models/priere.dart';
import '../widgets/favori_button.dart';

class PriereScreen extends StatefulWidget {
  final List<Priere> prieres;
  final int index;
  final Color couleur;

  const PriereScreen({
    super.key,
    required this.prieres,
    required this.index,
    required this.couleur,
  });

  @override
  State<PriereScreen> createState() => _PriereScreenState();
}

class _PriereScreenState extends State<PriereScreen> {
  late final PageController _ctrl = PageController(initialPage: widget.index);
  late int _courant = widget.index;
  double _taille = 17;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _changerTaille(double delta) =>
      setState(() => _taille = (_taille + delta).clamp(13, 30));

  @override
  Widget build(BuildContext context) {
    final p = widget.prieres[_courant];
    return Scaffold(
      appBar: AppBar(
        title: Text(p.numeroPage != null ? 'Page ${p.numeroPage}' : 'Vavaka'),
        backgroundColor: widget.couleur,
        foregroundColor: Colors.white,
        actions: [
          FavoriButton(priereId: p.id, couleurInactive: Colors.white),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => _changerTaille(-2),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => _changerTaille(2),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.prieres.length,
        onPageChanged: (i) => setState(() => _courant = i),
        itemBuilder: (_, i) => _page(widget.prieres[i]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _courant > 0
                    ? () => _ctrl.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut)
                    : null,
              ),
              Text('${_courant + 1} / ${widget.prieres.length}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _courant < widget.prieres.length - 1
                    ? () => _ctrl.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(Priere p) {
    final theme = Theme.of(context);
    final style = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: TextStyle(fontSize: _taille, height: 1.6),
      h3: TextStyle(
        fontSize: _taille + 1,
        fontWeight: FontWeight.bold,
        color: widget.couleur,
      ),
      blockquote: TextStyle(
        fontSize: _taille,
        fontStyle: FontStyle.italic,
        color: widget.couleur,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: widget.couleur, width: 3)),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: p.imageUrl!,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            p.titre.toUpperCase(),
            style: TextStyle(
              fontSize: _taille + 3,
              fontWeight: FontWeight.bold,
              color: widget.couleur,
            ),
          ),
          const SizedBox(height: 12),
          MarkdownBody(data: p.contenu, softLineBreak: true, styleSheet: style),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}