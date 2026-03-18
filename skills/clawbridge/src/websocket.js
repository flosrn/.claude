/**
 * WebSocket authentication and heartbeat.
 */
const { SECRET_KEY } = require('./config');
const { hasSession } = require('./auth/sessions');

function setupWebSocket(wss) {
    // Authentication
    wss.on('connection', (ws, req) => {
        const url = new URL(req.url, `http://${req.headers.host}`);
        const key = url.searchParams.get('key') || req.headers['x-claw-key'];
        // Check header key or cookie-based session
        const cookies = {};
        (req.headers.cookie || '').split(';').forEach(c => {
            let eqIdx = c.indexOf('=');
            if (eqIdx > 0) cookies[c.slice(0, eqIdx).trim()] = c.slice(eqIdx + 1).trim();
        });
        const hasValidSession = cookies.claw_session && hasSession(cookies.claw_session);
        if (key !== SECRET_KEY && !hasValidSession) {
            ws.close(4001, 'Unauthorized');
            return;
        }
    });

    // Heartbeat
    setInterval(() => {
        wss.clients.forEach(c => {
            if (c.readyState === 1) {
                // WebSocket.OPEN
                c.send(JSON.stringify({ type: 'heartbeat', ts: Date.now() }));
            }
        });
    }, 1000);
}

module.exports = { setupWebSocket };
