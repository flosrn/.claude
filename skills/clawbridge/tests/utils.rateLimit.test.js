'use strict';

const { rateLimit } = require('../src/utils/rateLimit');

describe('rateLimit()', () => {
    test('allows first call within window', () => {
        // window is 60ms
        expect(rateLimit('ip1', 60)).toBe(true);
    });

    test('blocks second call within window', () => {
        rateLimit('ip2', 60); // first allowed
        expect(rateLimit('ip2', 60)).toBe(false); // second blocked
    });

    test('different keys have independent limiters', () => {
        rateLimit('ipA', 60);
        expect(rateLimit('ipA', 60)).toBe(false); // ipA blocked
        expect(rateLimit('ipB', 60)).toBe(true);  // ipB independent
    });

    test('window resets after TTL', () => {
        jest.useFakeTimers();
        rateLimit('ip3', 1000); // 1 second window
        expect(rateLimit('ip3', 1000)).toBe(false); // blocked now

        jest.advanceTimersByTime(1001);
        expect(rateLimit('ip3', 1000)).toBe(true); // window expired, allowed again
        jest.useRealTimers();
    });
});
