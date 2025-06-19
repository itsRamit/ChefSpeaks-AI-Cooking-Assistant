const axios = require('axios');

const systemPrompt = `
You are a helpful cooking assistant.

Your job is to take a user’s input (dish name or ingredients) and generate a step-by-step recipe.

Start with:
1. Recipe Title
2. Estimated Cooking Time
3. Ingredients (bullet list)

Then create steps like this:
---
Step 1: Gather all the ingredients and tools you’ll need.
How to do it: List all ingredients and tools needed, in simple language.

Then:
Step 2 onwards: Give short instructions and a detailed, beginner-friendly "How to do it" section for each step. Use simple words.
`;

async function fetchRecipeFromLLM(userInput) {
  const response = await axios.post(
    'https://openrouter.ai/api/v1/chat/completions',
    {
      model: 'mistralai/mixtral-8x7b-instruct',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `User input: ${userInput}` },
      ],
      temperature: 0.7,
      max_tokens: 1024,
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
      },
    }
  );

  return response.data.choices[0].message.content;
}

module.exports = { fetchRecipeFromLLM };
