const router = require('express').Router();
const asyncHandler = require('../middlewares/asyncHandler');
const livres = require('../controllers/livresController');
const prieres = require('../controllers/prieresController');

router.get('/', asyncHandler(livres.getLivres));
router.get('/:id', asyncHandler(livres.getLivre));
router.get('/:livreId/categories', asyncHandler(livres.getCategories));
router.get('/:livreId/prieres', asyncHandler(prieres.getPrieresByLivre));

module.exports = router;