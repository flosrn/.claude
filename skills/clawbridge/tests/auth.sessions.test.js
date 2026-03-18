'use strict';

// Mock config before loading the module
jest.mock('../src/config', () => ({
    SECRET_KEY: 'testkey123',
    HOME_DIR: '/tmp',
    APP_DIR: '/tmp',
    STATE_DIR: '/tmp/.openclaw',
    PORT: 3456,
    WORKSPACE_DIR: '/tmp/workspace',
    LOG_DIR: '/tmp/logs',
    TOKEN_FILE: '/tmp/token_stats/latest.json',
    CRON_DIR: '/tmp/cron',
    MEMORY_DIR: '/tmp/memory',
    ENABLE_EMBEDDED_TUNNEL: false,
    TUNNEL_TOKEN: null,
}));

const {
    generateSessionToken,
    addSession,
    hasSession,
    removeSession,
    checkAuthRateLimit,
    resetAuthAttempts,
} = require('../src/auth/sessions');

describe('generateSessionToken()', () => {
    test('generates a 64-char hex string', () => {
        const token = generateSessionToken();
        expect(token).toMatch(/^[a-f0-9]{64}$/);
    });

    test('generates unique tokens on each call', () => {
        const tokens = new Set(Array.from({ length: 20 }, generateSessionToken));
        expect(tokens.size).toBe(20);
    });
});

describe('Session store', () => {
    let token;

    beforeEach(() => {
        token = generateSessionToken();
    });

    afterEach(() => {
        removeSession(token);
    });

    test('hasSession returns false for unknown token', () => {
        expect(hasSession('nonexistent')).toBe(false);
    });

    test('addSession + hasSession lifecycle', () => {
        expect(hasSession(token)).toBe(false);
        addSession(token);
        expect(hasSession(token)).toBe(true);
    });

    test('removeSession invalidates a session', () => {
        addSession(token);
        removeSession(token);
        expect(hasSession(token)).toBe(false);
    });
});

describe('checkAuthRateLimit()', () => {
    const ip = '10.0.0.test';

    beforeEach(() => {
        resetAuthAttempts(ip);
    });

    test('first 10 attempts are allowed', () => {
        for (let i = 0; i < 10; i++) {
            expect(checkAuthRateLimit(ip)).toBe(true);
        }
    });

    test('11th attempt is rate limited', () => {
        for (let i = 0; i < 10; i++) checkAuthRateLimit(ip);
        expect(checkAuthRateLimit(ip)).toBe(false);
    });

    test('resetAuthAttempts clears the counter', () => {
        for (let i = 0; i < 10; i++) checkAuthRateLimit(ip);
        resetAuthAttempts(ip);
        expect(checkAuthRateLimit(ip)).toBe(true);
    });
});

describe('Session pruning', () => {
    test('trims store to ≤50 entries when 101 sessions are added', () => {
        const { activeSessions } = require('../src/auth/sessions');
        activeSessions.clear(); // start clean

        for (let i = 0; i < 101; i++) {
            addSession(generateSessionToken());
        }

        // Pruning kicks in at >100 — store should have been trimmed
        expect(activeSessions.size).toBeLessThanOrEqual(50);

        activeSessions.clear(); // clean up for other tests
    });
});
