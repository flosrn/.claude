#!/usr/bin/env node

/**
 * Claude Code Hook - Detect 'any' types and request proper type fixes
 * 
 * This hook detects TypeScript 'any' usage and sends a message back to Claude
 * to fix them with proper types instead of just replacing with 'unknown'
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Read hook input from stdin
let input = '';
process.stdin.setEncoding('utf8');

process.stdin.on('data', (chunk) => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const hookData = JSON.parse(input);
    const toolName = hookData.tool_name || '';
    const toolInput = hookData.tool_input || {};
    
    // Only check for Edit, Write, and MultiEdit operations on TypeScript files
    if (!['Edit', 'Write', 'MultiEdit'].includes(toolName)) {
      process.exit(0);
    }
    
    const filePath = toolInput.file_path || '';
    
    // Only check TypeScript/TSX files
    if (!filePath.endsWith('.ts') && !filePath.endsWith('.tsx')) {
      process.exit(0);
    }
    
    // Skip node_modules and build directories
    if (filePath.includes('node_modules') || filePath.includes('dist') || filePath.includes('build')) {
      process.exit(0);
    }
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      process.exit(0);
    }
    
    // Read file content
    const content = fs.readFileSync(filePath, 'utf8');
    
    // Patterns to detect 'any' usage
    const anyPatterns = [
      /:\s*any(\s|,|;|\)|$|\[)/gm,
      /<any>/g,
      /\sas\s+any\s/g,
      /\[\s*\]\s*as\s+any/g,
      /=\s*any/g,
      /\(\s*\w+\s*:\s*any\s*\)/g,
      /\|\s*any/g,
      /any\s*\|/g,
      /:\s*any\[\]/g
    ];
    
    const detectedAny = [];
    const lines = content.split('\n');
    
    lines.forEach((line, index) => {
      anyPatterns.forEach(pattern => {
        if (pattern.test(line)) {
          // Skip comments and string literals
          const trimmedLine = line.trim();
          if (trimmedLine.startsWith('//') || trimmedLine.startsWith('*') || trimmedLine.startsWith('/*')) {
            return;
          }
          
          // Check if it's inside a string literal (basic check)
          const beforeAny = line.substring(0, line.search(pattern));
          const singleQuotes = (beforeAny.match(/'/g) || []).length;
          const doubleQuotes = (beforeAny.match(/"/g) || []).length;
          const backticks = (beforeAny.match(/`/g) || []).length;
          
          if (singleQuotes % 2 === 1 || doubleQuotes % 2 === 1 || backticks % 2 === 1) {
            return; // Inside a string
          }
          
          detectedAny.push({
            line: index + 1,
            content: line.trim(),
            pattern: pattern.source
          });
        }
      });
    });
    
    // Remove duplicates
    const uniqueDetections = detectedAny.filter((item, index, self) => 
      index === self.findIndex((t) => t.line === item.line)
    );
    
    if (uniqueDetections.length > 0) {
      // Send message to Claude to fix the types properly
      const message = `
⚠️ TypeScript 'any' types detected in ${filePath}

I found ${uniqueDetections.length} usage(s) of 'any' type that need proper typing:

${uniqueDetections.slice(0, 5).map(d => `  Line ${d.line}: ${d.content}`).join('\n')}
${uniqueDetections.length > 5 ? `  ... and ${uniqueDetections.length - 5} more` : ''}

Please fix these 'any' types with proper TypeScript types by:
1. Analyzing the code context to understand what type is actually needed
2. Using specific interfaces, types, or generics instead of 'any'
3. If the type is truly unknown, consider using 'unknown' with proper type guards
4. For event handlers, use proper event types (e.g., React.MouseEvent<HTMLButtonElement>)
5. For API responses, create proper interfaces matching the data structure

Do NOT just replace 'any' with 'unknown' - analyze and use the correct specific types.
`;
      
      // Write to stderr to send message to Claude
      console.error(message);
      
      // Exit with code 2 to block and request fixes
      process.exit(2);
    }
    
    // No 'any' detected, continue normally
    process.exit(0);
    
  } catch (error) {
    console.error('Error in detect-any-types hook:', error.message);
    // On error, allow operation to continue
    process.exit(0);
  }
});

// Set a timeout to prevent hanging
setTimeout(() => {
  process.exit(0);
}, 5000);