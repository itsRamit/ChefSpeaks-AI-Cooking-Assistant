require('dotenv').config();
const express = require('express');
const recipeRoutes = require('./routes/recipe_routes');

const app = express();
app.use(express.json());

app.use('/api', recipeRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
