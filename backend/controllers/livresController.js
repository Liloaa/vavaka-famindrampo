const supabase = require('../config/supabase');

exports.getLivres = async (req, res) => {
  const { data, error } = await supabase
    .from('livres')
    .select('*, prieres(count)')
    .order('ordre');
  if (error) throw error;

  const livres = data.map(({ prieres, ...livre }) => ({
    ...livre,
    nombre_prieres: prieres?.[0]?.count ?? 0,
  }));
  res.json({ livres });
};

exports.getLivre = async (req, res) => {
  const { data, error } = await supabase
    .from('livres')
    .select('*, categories(id, nom, ordre)')
    .eq('id', req.params.id)
    .maybeSingle();
  if (error) throw error;
  if (!data) return res.status(404).json({ erreur: 'Livre introuvable' });

  data.categories.sort((a, b) => a.ordre - b.ordre);
  res.json({ livre: data });
};

exports.getCategories = async (req, res) => {
  const { data, error } = await supabase
    .from('categories')
    .select('id, nom, ordre')
    .eq('livre_id', req.params.livreId)
    .order('ordre');
  if (error) throw error;
  res.json({ categories: data });
};