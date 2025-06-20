const axios = require('axios');

const systemPrompt = `
You are a helpful cooking assistant.

Your task is to take any kind of user input related to food — such as a dish name, available ingredients, or a vague idea — and generate a full, beginner-friendly recipe.

The recipe must be structured using **clearly defined tokens** so that a program can parse and extract the data easily.

Use this exact format:

<DISH_NAME>
{Name of the dish}
</DISH_NAME>

<ESTIMATED_TIME>
{Total time in minutes or a readable format like "45 minutes"}
</ESTIMATED_TIME>

<INGREDIENTS>
- ingredient 1
- ingredient 2
...
</INGREDIENTS>

<STEPS>
<STEP>
Step: {Short title of the step}
How to do it: {Simple explanation of how to perform this step}
<TIME>{Time in minutes for this step, use 0 if no specific time is required}</TIME>
</STEP>

...
</STEPS>

✅ Rules to follow:
- Use easy, beginner-friendly language.
- Always include Step 1 as "Gather all ingredients with listing each ingredients in comma seperated in *How to do it:*".
- Use <TIME>0</TIME> for steps that don’t require timing.
- DO NOT include anything outside of the tokens.
- Format must be strictly followed to ensure parsing.
`;

async function fetchRecipeFromLLM(userInput) {
  const response = await axios.post(
    'https://openrouter.ai/api/v1/chat/completions',
    {
      model: 'deepseek/deepseek-chat:free', // or use deepseek/deepseek-chat:free if you prefer
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `User input: ${userInput}` },
      ],
      temperature: 0.7,
      max_tokens: 1024,
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.API_KEY}`, // Use sk-or-... key
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://yourdomain.com',  // Optional: helps OpenRouter rank your app
        'X-Title': 'AI Recipe Generator',          // Optional: display title in OpenRouter usage dashboard
      },
    }
  );

  return response.data.choices[0].message.content;
}

module.exports = { fetchRecipeFromLLM };
