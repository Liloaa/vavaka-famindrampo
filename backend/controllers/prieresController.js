const supabase = require('../config/supabase');

exports.getPrieresByLivre = async (req, res) => {
  const { categorie_id, page, has_image } = req.query;

  let query = supabase
    .from('prieres')
    .select('id, titre, contenu, numero_page, has_image, image_url, ordre, categorie_id, categories(id, nom)')
    .eq('livre_id', req.params.livreId)
    .order('ordre');

  if (categorie_id) query = query.eq('categorie_id', categorie_id);
  if (page) {
    const n = parseInt(page, 10);
    if (Number.isNaN(n)) return res.status(400).json({ erreur: 'page invalide' });
    query = query.eq('numero_page', n);
  }
  if (has_image === 'true') query = query.eq('has_image', true);

  const { data, error } = await query;
  if (error) throw error;

  const prieres = data.map(({ categories, ...p }) => ({ ...p, categorie: categories }));
  res.json({ prieres, total: prieres.length });
};

exports.getPriere = async (req, res) => {
  const { data: priere, error } = await supabase
    .from('prieres')
    .select('*, livres(id, titre, couleur_theme), categories(id, nom)')
    .eq('id', req.params.id)
    .maybeSingle();
  if (error) throw error;
  if (!priere) return res.status(404).json({ erreur: 'Prière introuvable' });

  const champs = 'id, titre, numero_page';
  const [prec, suiv] = await Promise.all([
    supabase.from('prieres').select(champs)
      .eq('livre_id', priere.livre_id).lt('ordre', priere.ordre)
      .order('ordre', { ascending: false }).limit(1),
    supabase.from('prieres').select(champs)
      .eq('livre_id', priere.livre_id).gt('ordre', priere.ordre)
      .order('ordre', { ascending: true }).limit(1),
  ]);

  const { livres, categories, ...reste } = priere;
  res.json({
    priere: { ...reste, livre: livres, categorie: categories },
    navigation: {
      precedente: prec.data?.[0] ?? null,
      suivante: suiv.data?.[0] ?? null,
    },
  });
};