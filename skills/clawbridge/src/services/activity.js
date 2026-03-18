/**
 * Activity logger and file watcher service.
 */
const path = require('path');
const fs = require('fs');
const { LOG_DIR } = require('../config');
const { WORKSPACE_DIR } = require('./openclaw');

function logActivity(task, id = null) {
    if (!task || task === 'System Idle') return;

    // --- ID-BASED IN-MEMORY DEDUPLICATION ---
    if (id) {
        if (!global.processedEventIds) global.processedEventIds = new Set();
        const key = `${id}:${task}`;
        if (global.processedEventIds.has(key)) return;

        global.processedEventIds.add(key);
        if (global.processedEventIds.size > 200) {
            const arr = Array.from(global.processedEventIds);
            global.processedEventIds = new Set(arr.slice(-100));
        }
    }

    // For non-ID tasks (CPU, Scripts), use strict text+time
    if (!id) {
        if (global.lastLoggedTask === task && Date.now() - global.lastLoggedTime < 60000) return;
        global.lastLoggedTask = task;
        global.lastLoggedTime = Date.now();
    }

    const now = new Date();
    const ts = now.toISOString();
    const entry = { ts, task };

    const monthDir = path.join(LOG_DIR, ts.substring(0, 7));
    const logFile = path.join(monthDir, `${ts.substring(8, 10)}.jsonl`);

    try {
        if (!fs.existsSync(monthDir)) fs.mkdirSync(monthDir, { recursive: true });
        fs.appendFileSync(logFile, JSON.stringify(entry) + '\n');
    } catch (e) {
        console.error('Log write failed:', e);
    }
}

let fileState = {};
const WATCH_DIRS = [path.join(WORKSPACE_DIR, 'memory'), path.join(WORKSPACE_DIR, 'scripts')];
const WATCH_FILES = ['MEMORY.md', 'AGENTS.md', 'HEARTBEAT.md'].map(f => path.join(WORKSPACE_DIR, f));

function checkFileChanges() {
    WATCH_FILES.forEach(f => scanFile(f));
    WATCH_DIRS.forEach(d => {
        if (!fs.existsSync(d)) return;
        try {
            const files = fs.readdirSync(d);
            files.forEach(file => {
                if (file.startsWith('.') || file.endsWith('.tmp')) return;
                scanFile(path.join(d, file));
            });
        } catch (e) {
            console.debug('[Watch] Error reading directory:', d, e.message);
        }
    });
}

function scanFile(filePath) {
    try {
        if (!fs.existsSync(filePath)) return;
        const stat = fs.statSync(filePath);
        const mtime = stat.mtimeMs;
        const ctime = stat.ctimeMs;

        if (!fileState[filePath]) {
            fileState[filePath] = mtime;
            if (Date.now() - ctime < 60000) {
                const rel = path.relative(WORKSPACE_DIR, filePath);
                logActivity(`📄 Created: ${rel}`);
            }
            return;
        }

        if (mtime > fileState[filePath]) {
            fileState[filePath] = mtime;
            if (Date.now() - mtime < 60000) {
                const rel = path.relative(WORKSPACE_DIR, filePath);
                logActivity(`📝 Updated: ${rel}`);
            }
        }
    } catch (e) {
        console.debug('[Watch] Error scanning file:', filePath, e.message);
    }
}

module.exports = { logActivity, checkFileChanges, scanFile };
