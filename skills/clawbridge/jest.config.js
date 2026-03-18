/** @type {import('jest').Config} */
module.exports = {
    testEnvironment: 'node',
    rootDir: '.',
    testMatch: ['<rootDir>/tests/**/*.test.js'],
    moduleDirectories: ['node_modules'],
    collectCoverageFrom: [
        'src/**/*.js',
    ],
};
