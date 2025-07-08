const { fetchRecipeFromLLM } = require('../models/recipe_model');
const supabase = require('../config/db');


const extractBetween = (text, startTag, endTag) => {
  const regex = new RegExp(`${startTag}([\\s\\S]*?)${endTag}`, 'i');
  const match = text.match(regex);
  return match ? match[1].trim() : '';
};

const generateRecipe = async (req, res) => {
  const { userInput } = req.body;
  console.log('BODY:', req.body);


  if (!userInput) {
    return res.status(400).json({ error: 'User input is required' });
  }

  try {
    const raw = await fetchRecipeFromLLM(userInput);

    const dish_name = extractBetween(raw, '<DISH_NAME>', '</DISH_NAME>');
    const estimated_time_str = extractBetween(raw, '<ESTIMATED_TIME>', '</ESTIMATED_TIME>');
    const estimated_time = parseInt(estimated_time_str, 10) || 0;

    const ingredientsRaw = extractBetween(raw, '<INGREDIENTS>', '</INGREDIENTS>');
    const ingredients = ingredientsRaw
      .split('\n')
      .map(line => line.replace(/^[-*•]\s*/, '').trim())
      .filter(Boolean);

    // Extract steps with time
    const stepsRaw = extractBetween(raw, '<STEPS>', '</STEPS>');
    const stepBlocks = [...stepsRaw.matchAll(/<STEP>([\s\S]*?)<\/STEP>/gi)];

    const steps = stepBlocks.map((match, index) => {
      const block = match[1];
      const stepText = extractBetween(block, 'Step:', 'How to do it:') || '';
      const description = extractBetween(block, 'How to do it:', '<TIME>') || '';
      const timeStr = extractBetween(block, '<TIME>', '</TIME>');
      const time = parseInt(timeStr) || 0;

      return {
        step: stepText.trim(),
        description: description.trim(),
        time
      };
    });

    res.json({
      status: 'success',
      dish_name,
      estimated_time,
      ingredients,
      steps
    });
  } catch (error) {
    console.error('Controller Error:', error.message);
    res.status(500).json({ error: 'Failed to generate recipe' });
  }
};

const addFavorite = async (req, res) => {
  const { user_id, dish_name, estimated_time, ingredients, steps } = req.body;

  try {
    const { error } = await supabase
      .from('Favorites')
      .insert([{ user_id, dish_name, estimated_time, ingredients, steps }]);

    if (error) throw error;

    res.status(201).json({ message: 'Favorite added successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getFavorites = async (req, res) => {
  const { user_id } = req.query;

  try {
    const { data, error } = await supabase
      .from('Favorites')
      .select('*')
      .eq('user_id', user_id);

    if (error) throw error;

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const removeFavorite = async (req, res) => {
  const { user_id, id} = req.body;

  if (!user_id || !id) {
    return res.status(400).json({ error: 'user_id, id, and created_at are required' });
  }

  try {
    const { error } = await supabase
      .from('Favorites')
      .delete()
      .match({ user_id, id: Number(id)});

    if (error) throw error;

    res.status(200).json({ message: 'Favorite removed successfully' });
  } catch (err) {
    console.error('Remove Favorite Error:', err.message);
    res.status(500).json({ error: 'Failed to remove favorite' });
  }
};


module.exports = { generateRecipe, addFavorite, getFavorites, removeFavorite };
