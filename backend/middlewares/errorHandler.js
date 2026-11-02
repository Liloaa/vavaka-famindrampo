module.exports = (err, req, res, next) => {
  console.error(err);
  if (err.code === '22P02') {
    return res.status(400).json({ erreur: 'Identifiant invalide' });
  }
  res.status(500).json({ erreur: 'Erreur serveur' });
};