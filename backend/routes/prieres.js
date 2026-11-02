const router = require('express').Router();
const asyncHandler = require('../middlewares/asyncHandler');
const prieres = require('../controllers/prieresController');

router.get('/:id', asyncHandler(prieres.getPriere));

module.exports = router;