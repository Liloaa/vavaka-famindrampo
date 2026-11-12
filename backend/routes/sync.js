const router = require('express').Router();
const asyncHandler = require('../middlewares/asyncHandler');
const sync = require('../controllers/syncController');

router.get('/', asyncHandler(sync.sync));

module.exports = router;