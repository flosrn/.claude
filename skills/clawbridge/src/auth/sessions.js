/**
 * Session management — token generation, storage, and brute-force protection.
 */
const crypto = require('crypto');
const { SECRET_KEY } = require('../config');

// In-memory session store
const activeSessions = new Set();

function generateSessionToken() {
    return crypto.createHmac('sha256', SECRET_KEY).update(crypto.randomBytes(32).toString('hex')).digest('hex');
}

function addSession(token) {
    activeSessions.add(token);
    // Prune if too many sessions
    if (activeSessions.size > 100) {
        const arr = Array.from(activeSessions);
        activeSessions.clear();
        arr.slice(-50).forEach(t => activeSessions.add(t));
    }
}

function hasSession(token) {
    return activeSessions.has(token);
}

function removeSession(token) {
    activeSessions.delete(token);
}

// --- Brute-force Protection ---
const authAttempts = {};

function checkAuthRateLimit(ip) {
    const now = Date.now();
    if (!authAttempts[ip]) authAttempts[ip] = { count: 0, resetAt: now + 60000 };
    if (now > authAttempts[ip].resetAt) authAttempts[ip] = { count: 0, resetAt: now + 60000 };
    authAttempts[ip].count++;
    return authAttempts[ip].count <= 10;
}

function resetAuthAttempts(ip) {
    authAttempts[ip] = null;
}

module.exports = {
    activeSessions,
    generateSessionToken,
    addSession,
    hasSession,
    removeSession,
    checkAuthRateLimit,
    resetAuthAttempts,
};
