#!/usr/bin/env bun
/**
 * Tool Router Hook - ASSERTIVE tool suggestions (EN + FR)
 *
 * Based on research: assertive cues ("ALWAYS use") significantly
 * influence tool selection vs passive suggestions ("consider using").
 *
 * Execution time: ~5ms (pure regex, no network)
 */

const input = await Bun.stdin.text();

let prompt = '';
try {
  const data = JSON.parse(input);
  prompt = data.prompt?.toLowerCase() || '';
} catch {
  process.exit(0);
}

// Skip short prompts or greetings (EN + FR)
if (prompt.length < 15 || /^(hi|hello|hey|salut|bonjour|merci|thanks|ok|oui|non|yo|coucou)/i.test(prompt)) {
  process.exit(0);
}

const suggestions: string[] = [];

// 1. ai-multimodal - Media files (EN + FR)
if (/pdf|document|image|screenshot|photo|audio|video|mp3|mp4|transcri|ocr|extract.*from|fichier|extraire|analyser.*image|analyser.*pdf|transcrire/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "ai-multimodal" for PDFs/images/audio/video. Do NOT manually read or describe media files.');
}

// 2. repomix - External repos (EN + FR)
if (/third.?party|external.*repo|library.*code|security.*audit|analyze.*repo|package.*repo|github\.com|repo.*externe|librairie.*externe|audit.*securite|analyser.*repo/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "repomix" for external repositories. Do NOT manually clone or browse external repos.');
}

// 3. lsp-navigation - Semantic code ops (EN + FR)
if (/rename.*symbol|find.*references|find.*usages|where.*used|refactor.*name|all.*occurrences|renommer.*symbole|trouver.*references|où.*utilisé|toutes.*occurrences/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "lsp-navigation" for find refs/rename. Do NOT use Grep for semantic code operations.');
}

// 4. /explain - Deep code understanding (EN + FR)
if (/trace|architecture|flow|diagram|how.*works.*internally|deep.*dive|understand.*system|comprendre.*système|diagramme|flux|comment.*fonctionne.*interne/i.test(prompt)) {
  suggestions.push('ALWAYS run /explain command for deep code understanding. Do NOT manually search and read files - the command produces ASCII diagrams and structured analysis.');
}

// 5. /brainstorm - Multi-perspective research (EN + FR)
if (/best.*approach|should.*i.*use|compare|pros.*cons|evaluate|decision|trade.?offs|alternatives|meilleure.*approche|dois.?je.*utiliser|comparer|avantages.*inconvénients|évaluer|décision/i.test(prompt)) {
  suggestions.push('ALWAYS run /brainstorm command for decisions/comparisons. Uses Opus model with multi-round skeptical analysis. Do NOT give quick opinions.');
}

// 6. /create-context-docs - Knowledge docs (EN + FR)
if (/learn.*about|document.*for.*later|reference|cheat.?sheet|remember.*how|knowledge.*base|apprendre|documenter.*pour.*plus.*tard|référence|aide.?mémoire|retenir|base.*connaissance/i.test(prompt)) {
  suggestions.push('ALWAYS run /create-context-docs to save reusable knowledge in .claude/docs/. Do NOT just explain - persist the documentation.');
}

// 7. aesthetic - Design work (EN + FR, word boundaries for ui/ux)
if (/beautiful|design|\bui\b|\bux\b|aesthetic|inspiration|dribbble|pretty|visual|look.*feel|modern.*look|beau|joli|esthétique|visuel|apparence|moderne/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "aesthetic" for design work. Provides structured design analysis and iteration using Gemini vision.');
}

// 8. /ultrathink - Craftsmanship (EN + FR)
if (/complex|elegant|perfect|best.*way|architect|clean.*code|masterpiece|ideal.*solution|complexe|élégant|parfait|meilleure.*façon|architecturer|code.*propre|idéal/i.test(prompt)) {
  suggestions.push('ALWAYS run /ultrathink for complex problems requiring craftsmanship. Deep thinking mode for elegant solutions.');
}

// 9. vision-analyzer agent - UI debugging (EN + FR)
if (/screenshot|visual.*bug|ui.*issue|looks.*wrong|display.*problem|layout.*broken|capture.*écran|bug.*visuel|problème.*affichage|rendu.*cassé/i.test(prompt)) {
  suggestions.push('ALWAYS use Task agent "vision-analyzer" for UI bugs. Analyzes screenshots to identify visual issues.');
}

// 10. databases skill - DB work (EN + FR)
if (/sql|query|database|postgres|mongo|migration|schema|index|performance.*query|requête|base.*données|schéma|optimiser.*requête/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "databases" for database work. Provides PostgreSQL/MongoDB patterns, optimization, migrations.');
}

// 11. /debug - Bug fixing (EN + FR)
if (/error|exception|bug|crash|broken|not working|fails|ça marche pas|ne fonctionne pas|erreur|plantage|cassé/i.test(prompt)) {
  suggestions.push('ALWAYS run /debug command for systematic debugging. Uses ULTRA THINK for root cause analysis. Do NOT guess at fixes.');
}

// 12. /refactor - Mass code changes (EN + FR)
if (/refactor.*all|rename.*everywhere|change.*across|update.*all.*files|mass.*update|refactoriser|modifier.*partout/i.test(prompt)) {
  suggestions.push('ALWAYS run /refactor command for mass code changes. Uses parallel Snipper agents for speed. Do NOT edit files one by one.');
}

// 13. create-prompt skill - Prompt engineering (EN + FR)
if (/write.*prompt|create.*prompt|optimize.*prompt|improve.*prompt|system.*prompt|écrire.*prompt|améliorer.*prompt|créer.*prompt/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "create-prompt" for prompt engineering. Covers Anthropic/OpenAI best practices.');
}

// 14. nextjs-migration - Next.js 16 upgrade guide (EN + FR)
if (/upgrade.*next|migrer.*next|next.*15.*to.*16|breaking.*changes.*next|proxy\.ts|middleware.*migration/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "nextjs-migration" for Next.js 15→16 upgrade. Covers breaking changes, proxy.ts, codemods.');
}

// 15. claude-code skill - Claude Code customization (EN + FR)
if (/\bhook\b|\bskill\b|\bcommand\b|\bagent\b|\bsubagent\b|\bmcp\b|slash.*command|task.*tool|claude\.md|settings\.json|créer.*hook|créer.*skill|créer.*commande|créer.*agent/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "claude-code" for Claude Code configuration (hooks, skills, commands, agents, MCP). Has comprehensive references.');
}

// 16. docs-seeker - Library documentation (EN + FR)
if (/documentation.*for|docs.*for|how.*to.*use.*library|comment.*utiliser|llms\.txt|context7|chercher.*doc|find.*documentation/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "docs-seeker" for library/framework documentation. Uses context7.com llms.txt and parallel exploration.');
}

// 17. /makerkit:db-sync - Makerkit database migrations (EN + FR)
if (/supabase|drizzle|db.*diff|migration.*supabase|typegen|pnpm.*drizzle|usersInAuth|sync.*drizzle/i.test(prompt)) {
  suggestions.push('ALWAYS run /makerkit:db-sync for Supabase + Drizzle migrations in Makerkit projects. Handles full workflow with automatic Drizzle fixes.');
}

// 18. /makerkit:update - Makerkit codebase updates (EN + FR)
if (/update.*makerkit|makerkit.*update|upgrade.*codebase|mise.*jour.*makerkit|pull.*upstream|merge.*upstream/i.test(prompt)) {
  suggestions.push('ALWAYS run /makerkit:update to update Makerkit codebase from upstream. Handles conflicts, dependencies, and health checks.');
}

// 19. /makerkit:health - Makerkit health checks (EN + FR)
if (/health.*check|typecheck.*lint|verify.*project|check.*project|vérifier.*projet|santé.*projet/i.test(prompt)) {
  suggestions.push('ALWAYS run /makerkit:health to verify project integrity (typecheck, lint, syncpack). Quick validation before commits.');
}

// 20. makerkit-docs skill - Makerkit documentation (EN + FR)
if (/makerkit|enhanceAction|enhanceRouteHandler|makerkit.*pattern|rls.*policy|how.*to.*in.*makerkit|app_permissions/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "makerkit-docs" for Makerkit patterns (enhanceAction, RLS, permissions). Uses Context7 for latest docs.');
}

// 21. systematic-debugging - Deep debugging methodology
if (/root.*cause|systematic.*debug|test.*fail|why.*fail|investigate.*bug|analyser.*en.*profondeur|cause.*profonde/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "systematic-debugging" for deep debugging. Four-phase framework: Root Cause → Pattern → Hypothesis → Implementation.');
}

// 22. typescript-strict - Type safety (EN + FR)
if (/\bany\b.*type|type.*error|ts-ignore|ts-expect-error|type.*guard|unknown.*type|zod.*schema|type.*safety|erreur.*type|typage.*strict|éviter.*any/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "typescript-strict" for TypeScript type safety. Patterns for avoiding `any`, type guards, and Zod validation.');
}

// 23. cache-components skill - Next.js 16 Cache Components (EN + FR)
if (/use cache|cacheLife|cacheTag|cache.*invalidation|fetchCache|force-static|opt.*in.*caching/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "cache-components" for Next.js 16 Cache Components ("use cache", cacheLife, cacheTag). Migration from old patterns included.');
}

// 24. react-compiler skill - React 19 Compiler (EN + FR)
if (/react.*compiler|automatic.*memoization|remove.*useMemo|remove.*useCallback|CannotPreserveMemoization|supprimer.*useMemo/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "react-compiler" for React 19 Compiler patterns. Auto-memoization replaces manual useMemo/useCallback.');
}

// 25. code-splitting skill - Bundle optimization (EN + FR)
if (/barrel.*file|code.*splitting|dynamic.*import|next\/dynamic|optimizePackageImports|bundle.*size|tree.*shaking|réduire.*bundle/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "code-splitting" for bundle optimization. Barrel files, dynamic imports, tree shaking patterns.');
}

// 26. /next-react-optimizer:analyze - Performance analysis (EN + FR)
if (/optimize.*next|optimize.*react|analyze.*performance|performance.*issues|slow.*rendering|lent.*rendu|optimiser.*app/i.test(prompt)) {
  suggestions.push('ALWAYS run /next-react-optimizer:analyze for React/Next.js performance analysis. Finds optimization opportunities automatically.');
}

// 27. react19-patterns skill - React 19 new patterns (EN + FR)
if (/\buse\s*\(\s*\w*Context|useContext|Context\.Provider|ViewTransition|react.*19.*pattern|nouveau.*pattern.*react/i.test(prompt)) {
  suggestions.push('ALWAYS use Skill "react19-patterns" for React 19 patterns: use() hook, Context shorthand, ViewTransition+Suspense. NOT for compiler optimization.');
}

// Output with ASSERTIVE format
if (suggestions.length > 0) {
  console.log(`<tool-router>
MANDATORY TOOL SELECTION:
${suggestions.join('\n')}

These tools exist because they provide better results than manual approaches.
Invoke the specified Skill/command/agent FIRST before attempting manual work.
</tool-router>`);
}

process.exit(0);
