const express = require('express');
const router = express.Router();
const { chatWithAssistant } = require('../controllers/chat_controller');

router.post('/chat', chatWithAssistant);

module.exports = router;
