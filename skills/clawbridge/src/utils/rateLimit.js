/**
 * Simple in-memory rate limiter for destructive endpoints.
 */
const lastCallTimestamps = {};

function rateLimit(key, windowMs = 10000) {
    const now = Date.now();
    if (lastCallTimestamps[key] && now - lastCallTimestamps[key] < windowMs) {
        return false;
    }
    lastCallTimestamps[key] = now;
    return true;
}

module.exports = { rateLimit };
