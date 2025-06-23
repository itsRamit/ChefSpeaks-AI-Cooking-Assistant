const axios = require('axios');

async function fetchChatResponseFromLLM(userInput, referenceText) {
  // const normalizedRef = referenceText.toLowerCase();
  // const normalizedInput = userInput.toLowerCase();
  // if (!normalizedRef.includes(normalizedInput.split(' ')[0])) {
  //   return "Please ask question belongs to the recipe step";
  // }

  const systemPrompt = `
    You are a helpful cooking assistant.

    You are given a step of a recipe. Answer the user's question in the simplest and shortest way possible (1-2 sentences), but ONLY if the question is about the recipe step that is given. If the question is not related to the reference text, reply exactly with: "Please ask question belongs to the recipe step".

    Recipe step:
    ${referenceText}
    `;

  const response = await axios.post(
    'https://openrouter.ai/api/v1/chat/completions',
    {
      model: 'deepseek/deepseek-chat:free',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userInput },
      ],
      temperature: 0.5,
      max_tokens: 100,
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://yourdomain.com',
        'X-Title': 'AI Cooking Chat',
      },
    }
  );

  return response.data.choices[0].message.content.trim();
}

module.exports = { fetchChatResponseFromLLM };