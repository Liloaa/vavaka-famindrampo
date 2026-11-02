const supabase = require('../config/supabase');

function extrait(texte, q) {
  const propre = texte.replace(/[*_#>]/g, '').replace(/\s+/g, ' ');
  if (!q) return propre.slice(0, 100);
  const i = propre.toLowerCase().indexOf(q.toLowerCase());
  if (i === -1) return propre.slice(0, 100);
  const debut = Math.max(0, i - 40);
  const fin = Math.min(propre.length, i + q.length + 60);
  return (debut > 0 ? '...' : '') + propre.slice(debut, fin) + (fin < propre.length ? '...' : '');
}

exports.rechercher = async (req, res) => {
  const q = (req.query.q || '').replace(/[,()%\\]/g, ' ').trim();
  const { livre_id, page } = req.query;

  if (!q && !page) {
    return res.status(400).json({ erreur: 'Indiquez q (texte) ou page (numéro)' });
  }

  let query = supabase
    .from('prieres')
    .select('id, titre, contenu, numero_page, has_image, livres(id, titre, couleur_theme)')
    .order('livre_id')
    .order('ordre')
    .limit(50);

  if (livre_id) query = query.eq('livre_id', livre_id);
  if (page) {
    const n = parseInt(page, 10);
    if (Number.isNaN(n)) return res.status(400).json({ erreur: 'page invalide' });
    query = query.eq('numero_page', n);
  }
  if (q) query = query.or(`titre.ilike.%${q}%,contenu.ilike.%${q}%`);

  const { data, error } = await query;
  if (error) throw error;

  const resultats = data.map(({ contenu, livres, ...p }) => ({
    ...p,
    extrait: extrait(contenu, q),
    livre: livres,
  }));
  res.json({ resultats, total: resultats.length });
};