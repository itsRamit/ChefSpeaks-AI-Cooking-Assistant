const { fetchRecipeFromLLM } = require('../models/recipe_model');

// Helper function to extract text between tags
const extractBetween = (text, startTag, endTag) => {
  const regex = new RegExp(`${startTag}([\\s\\S]*?)${endTag}`, 'i');
  const match = text.match(regex);
  return match ? match[1].trim() : '';
};

const generateRecipe = async (req, res) => {
  const { user_input } = req.body;

  if (!user_input) {
    return res.status(400).json({ error: 'User input is required' });
  }

  try {
    const raw = await fetchRecipeFromLLM(user_input);

    const dish_name = extractBetween(raw, '<DISH_NAME>', '</DISH_NAME>');
    const estimated_time = extractBetween(raw, '<ESTIMATED_TIME>', '</ESTIMATED_TIME>');

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

module.exports = { generateRecipe };
