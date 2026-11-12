const supabase = require('../config/supabase');

async function toutLire(table, colonnes, ordres) {
  const taille = 1000;
  let debut = 0;
  const lignes = [];
  while (true) {
    let q = supabase.from(table).select(colonnes).range(debut, debut + taille - 1);
    for (const o of ordres) q = q.order(o);
    const { data, error } = await q;
    if (error) throw error;
    lignes.push(...data);
    if (data.length < taille) break;
    debut += taille;
  }
  return lignes;
}

exports.sync = async (req, res) => {
  const [livres, categories, prieres] = await Promise.all([
    toutLire('livres', 'id, titre, description, couverture_url, couleur_theme, ordre', ['ordre', 'id']),
    toutLire('categories', 'id, livre_id, nom, ordre', ['livre_id', 'ordre', 'id']),
    toutLire('prieres', 'id, livre_id, categorie_id, titre, contenu, numero_page, has_image, image_url, ordre', ['livre_id', 'ordre', 'id']),
  ]);
  res.json({ livres, categories, prieres });
};