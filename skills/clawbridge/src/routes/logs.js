/**
 * GET /api/logs
 */
const router = require('express').Router();
const path = require('path');
const fs = require('fs');
const { LOG_DIR } = require('../config');

router.get('/api/logs', (req, res) => {
    const limit = parseInt(req.query.limit) || 100;
    const dateStr = req.query.date || new Date().toISOString().slice(0, 10);
    const month = dateStr.slice(0, 7);
    const day = dateStr.slice(8, 10);
    const logFile = path.join(LOG_DIR, month, `${day}.jsonl`);

    if (!fs.existsSync(logFile)) return res.json([]);

    try {
        const content = fs.readFileSync(logFile, 'utf8');
        const lines = content.trim().split('\n');
        const logs = [];
        for (let i = lines.length - 1; i >= 0; i--) {
            if (!lines[i]) continue;
            try {
                logs.push(JSON.parse(lines[i]));
            } catch (e) {
                /* expected: malformed log line */
            }
            if (logs.length >= limit) break;
        }
        res.json(logs);
    } catch (e) {
        res.status(500).json({ error: 'Log read failed' });
    }
});

module.exports = router;
