const express = require('express');
const router = express.Router();
const { generateRecipe, addFavorite, getFavorites } = require('../controllers/recipe_controller');

router.post('/generate-recipe', generateRecipe);
router.post('/favorites', addFavorite);
router.get('/favorites', getFavorites);

module.exports = router;
