const router = require('express').Router();
const asyncHandler = require('../middlewares/asyncHandler');
const adminAuth = require('../middlewares/adminAuth');
const admin = require('../controllers/adminController');

router.use(adminAuth);

router.post('/livres', asyncHandler(admin.creerLivre));
router.post('/categories', asyncHandler(admin.creerCategorie));
router.post('/prieres', asyncHandler(admin.creerPriere));
router.put('/prieres/:id', asyncHandler(admin.modifierPriere));
router.delete('/prieres/:id', asyncHandler(admin.supprimerPriere));

module.exports = router;