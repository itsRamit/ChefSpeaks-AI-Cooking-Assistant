const { fetchChatResponseFromLLM } = require('../models/chat_model');

async function chatWithAssistant(req, res) {
  try {
    const { userInput, referenceText } = req.body;
    console.log('BODY:', req.body);
    if (!userInput || !referenceText) {
      return res.status(400).json({ status: "error", response: "userInput and referenceText are required." });
    }

    const answer = await fetchChatResponseFromLLM(userInput, referenceText);
    res.json({ status: "success", response: answer });
  } catch (error) {
    console.error('Controller Error:', error.message);
    res.status(500).json({ status: "error", response: "Failed to get response from assistant." });
  }
}

module.exports = { chatWithAssistant };