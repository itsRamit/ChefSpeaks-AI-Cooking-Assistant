require('dotenv').config();
const express = require('express');
const recipeRoutes = require('./routes/recipe_routes');
const chatRoutes = require('./routes/chat_routes');

const app = express();
app.use(express.json());

app.use('/api', recipeRoutes);
app.use('/api', chatRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
