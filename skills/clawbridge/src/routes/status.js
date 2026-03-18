/**
 * GET /api/status
 */
const router = require('express').Router();
const { checkSystemStatus } = require('../services/monitor');

router.get('/api/status', (req, res) => {
    checkSystemStatus(data => res.json(data));
});

module.exports = router;
