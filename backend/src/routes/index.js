const express = require('express');
const router = express.Router();

// Import route modules
// const authRoutes = require('./auth');
// const familyRoutes = require('./family');
// const rulesRoutes = require('./rules');

// Basic routes for testing
router.get('/', (req, res) => {
  res.json({
    message: 'Kids Time Control API',
    version: '1.0.0'
  });
});

// Health check
router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString()
  });
});

// Mount route modules
// router.use('/auth', authRoutes);
// router.use('/family', familyRoutes);
// router.use('/rules', rulesRoutes);

module.exports = router;