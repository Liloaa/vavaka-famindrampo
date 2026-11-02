const crypto = require('crypto');

module.exports = (req, res, next) => {
  const fournie = Buffer.from(req.header('x-admin-key') || '');
  const attendue = Buffer.from(process.env.ADMIN_KEY || '');

  const ok =
    attendue.length > 0 &&
    fournie.length === attendue.length &&
    crypto.timingSafeEqual(fournie, attendue);

  if (!ok) return res.status(401).json({ erreur: 'Clé admin invalide' });
  next();
};