const router = require('express').Router();
const asyncHandler = require('../middlewares/asyncHandler');
const favoris = require('../controllers/favorisController');

router.get('/:deviceId', asyncHandler(favoris.getFavoris));
router.post('/', asyncHandler(favoris.ajouterFavori));
router.delete('/:id', asyncHandler(favoris.supprimerFavori));

module.exports = router;