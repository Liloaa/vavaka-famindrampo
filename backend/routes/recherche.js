const router = require('express').Router();
const asyncHandler = require('../middlewares/asyncHandler');
const recherche = require('../controllers/rechercheController');

router.get('/', asyncHandler(recherche.rechercher));

module.exports = router;