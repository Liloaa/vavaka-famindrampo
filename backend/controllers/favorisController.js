const supabase = require('../config/supabase');

exports.getFavoris = async (req, res) => {
  const { data, error } = await supabase
    .from('favoris')
    .select('id, created_at, prieres(id, titre, numero_page, has_image, livre_id, livres(id, titre, couleur_theme))')
    .eq('device_id', req.params.deviceId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  res.json({ favoris: data, total: data.length });
};

exports.ajouterFavori = async (req, res) => {
  const { priere_id, device_id } = req.body;
  if (!priere_id || !device_id) {
    return res.status(400).json({ erreur: 'priere_id et device_id sont requis' });
  }

  const { data, error } = await supabase
    .from('favoris')
    .insert({ priere_id, device_id })
    .select()
    .single();

  if (error) {
    if (error.code === '23505') {
      return res.status(200).json({ message: 'Déjà en favori' });
    }
    throw error;
  }
  res.status(201).json({ favori: data });
};

exports.supprimerFavori = async (req, res) => {
  const { device_id } = req.query;
  if (!device_id) {
    return res.status(400).json({ erreur: 'device_id est requis' });
  }

  const { error } = await supabase
    .from('favoris')
    .delete()
    .eq('id', req.params.id)
    .eq('device_id', device_id);
  if (error) throw error;
  res.json({ message: 'Favori supprimé' });
};