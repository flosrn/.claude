/**
 * Active context reader — reads OpenClaw agent session logs.
 */
const path = require('path');
const fs = require('fs');
const { HOME_DIR, STATE_DIR } = require('../config');
const { WORKSPACE_DIR } = require('./openclaw');

function getActiveContext() {
    try {
        const sessionsPath = path.join(STATE_DIR, 'agents/main/sessions/sessions.json');
        const altPaths = [
            sessionsPath,
            path.join(HOME_DIR, '.openclaw/agents/main/sessions/sessions.json'),
            path.join(WORKSPACE_DIR, '.openclaw/sessions/sessions.json'),
            path.join(HOME_DIR, '.clawdbot/agents/main/sessions/sessions.json'),
        ];

        let targetPath = null;
        for (const p of altPaths) {
            if (fs.existsSync(p)) {
                targetPath = p;
                break;
            }
        }

        if (!targetPath) return null;

        let sessions;
        try {
            const fileContent = fs.readFileSync(targetPath, 'utf8');
            sessions = JSON.parse(fileContent);
        } catch (e) {
            return null; // File might be empty/corrupt during write
        }

        let latestSession = null;
        let maxTime = 0;

        Object.values(sessions).forEach(s => {
            if (s.updatedAt > maxTime) {
                maxTime = s.updatedAt;
                latestSession = s;
            }
        });

        if (!latestSession) return null;

        // Only consider "Active" if updated within last 15 seconds
        if (Date.now() - maxTime > 15000) return null;

        const logFile = latestSession.sessionFile;
        if (!logFile) return null;

        // Security: validate logFile path is within expected directories
        const resolvedLogFile = path.resolve(logFile);
        const allowedPrefixes = [STATE_DIR, HOME_DIR, WORKSPACE_DIR];
        if (!allowedPrefixes.some(prefix => resolvedLogFile.startsWith(path.resolve(prefix)))) {
            console.warn('[Security] Blocked suspicious logFile path:', resolvedLogFile);
            return null;
        }
        if (!fs.existsSync(logFile)) return null;

        // Use fs.readFileSync instead of exec('tail') to avoid command injection
        const fileContent = fs.readFileSync(logFile, 'utf8');
        const allLines = fileContent.trim().split('\n');
        const tail = allLines.slice(-50).join('\n');
        const lines = tail.trim().split('\n').reverse();

        // Freshness check — skip stale logs during recovery/restart loops
        const FRESHNESS_WINDOW_MS = 5 * 60 * 1000; // 5 minutes
        const now = Date.now();

        for (const line of lines) {
            try {
                const event = JSON.parse(line);

                // --- Freshness Filter ---
                if (event.time) {
                    const evtTime = new Date(event.time).getTime();
                    if (!isNaN(evtTime) && now - evtTime > FRESHNESS_WINDOW_MS) {
                        continue;
                    }
                }

                // 1. Capture Assistant Messages (Thinking + Tool Call Requests)
                if (
                    event.type === 'message' &&
                    event.message &&
                    event.message.role === 'assistant' &&
                    event.message.content
                ) {
                    const msgId = event.id;
                    const content = event.message.content;
                    const events = [];

                    const thinking = content.find(c => c.type === 'thinking');
                    if (thinking && thinking.thinking) {
                        let text = thinking.thinking
                            .replace(/^[#*\- ]+/, '')
                            .replace(/\n/g, ' ')
                            .trim();
                        if (text.length > 5000) text = text.substring(0, 5000) + '...';
                        events.push(`🧠 ${text}`);
                    }

                    const tool = content.find(c => c.type === 'toolCall');
                    if (tool) {
                        let argStr = '';
                        if (tool.arguments) {
                            if (tool.name === 'web_search') argStr = `"${tool.arguments.query}"`;
                            else if (tool.name === 'read') argStr = tool.arguments.path || tool.arguments.file_path;
                            else if (tool.name === 'exec') argStr = tool.arguments.command;
                            else if (tool.name === 'message' || tool.name === 'sessions_send') continue;
                            else argStr = JSON.stringify(tool.arguments);
                        }
                        if (argStr && argStr.length > 5000) argStr = argStr.substring(0, 5000) + '...';
                        events.push(`🔧 ${tool.name} ${argStr}`);
                    }

                    if (events.length > 0) {
                        return { id: msgId, events: events };
                    }
                }

                // 2. Capture Tool Results
                if (event.type === 'message' && event.message && event.message.role === 'toolResult') {
                    const toolName = event.message.toolName;
                    const toolContent = event.message.content;
                    let resultText = '';

                    if (Array.isArray(toolContent)) {
                        resultText = toolContent.map(c => c.text || '').join(' ');
                    } else if (typeof toolContent === 'string') {
                        resultText = toolContent;
                    }

                    if (toolName === 'message' || toolName === 'sessions_send') continue;

                    if (resultText && resultText.length > 0) {
                        if (resultText.length > 2000) resultText = resultText.substring(0, 2000) + '...';
                        return { id: event.id, events: [`🔧 Result: ${resultText}`] };
                    }
                }
            } catch (e) {
                /* expected: not all log lines are valid JSON */
            }
        }
    } catch (e) {
        console.warn('[Context] Failed to read active context:', e.message);
    }
    return null;
}

module.exports = { getActiveContext };
