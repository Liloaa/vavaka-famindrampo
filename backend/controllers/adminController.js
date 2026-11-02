const supabase = require('../config/supabase');

const pick = (obj, champs) =>
  Object.fromEntries(Object.entries(obj).filter(([k]) => champs.includes(k)));

const CHAMPS_LIVRE = ['titre', 'description', 'couverture_url', 'couleur_theme', 'ordre'];
const CHAMPS_CATEGORIE = ['livre_id', 'nom', 'ordre'];
const CHAMPS_PRIERE = ['livre_id', 'categorie_id', 'titre', 'contenu', 'numero_page', 'has_image', 'image_url', 'ordre'];

exports.creerLivre = async (req, res) => {
  const donnees = pick(req.body, CHAMPS_LIVRE);
  if (!donnees.titre) return res.status(400).json({ erreur: 'titre requis' });

  const { data, error } = await supabase.from('livres').insert(donnees).select().single();
  if (error) throw error;
  res.status(201).json({ livre: data });
};

exports.creerCategorie = async (req, res) => {
  const donnees = pick(req.body, CHAMPS_CATEGORIE);
  if (!donnees.livre_id || !donnees.nom) {
    return res.status(400).json({ erreur: 'livre_id et nom requis' });
  }

  const { data, error } = await supabase.from('categories').insert(donnees).select().single();
  if (error) throw error;
  res.status(201).json({ categorie: data });
};

exports.creerPriere = async (req, res) => {
  const donnees = pick(req.body, CHAMPS_PRIERE);
  if (!donnees.livre_id || !donnees.titre || !donnees.contenu) {
    return res.status(400).json({ erreur: 'livre_id, titre et contenu requis' });
  }

  const { data, error } = await supabase.from('prieres').insert(donnees).select().single();
  if (error) throw error;
  res.status(201).json({ priere: data });
};

exports.modifierPriere = async (req, res) => {
  const donnees = pick(req.body, CHAMPS_PRIERE);
  if (Object.keys(donnees).length === 0) {
    return res.status(400).json({ erreur: 'Aucun champ à modifier' });
  }

  const { data, error } = await supabase
    .from('prieres')
    .update(donnees)
    .eq('id', req.params.id)
    .select()
    .maybeSingle();
  if (error) throw error;
  if (!data) return res.status(404).json({ erreur: 'Prière introuvable' });
  res.json({ priere: data });
};

exports.supprimerPriere = async (req, res) => {
  const { error } = await supabase.from('prieres').delete().eq('id', req.params.id);
  if (error) throw error;
  res.json({ message: 'Prière supprimée' });
};