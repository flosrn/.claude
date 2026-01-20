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

let prompt = "";
try {
  const data = JSON.parse(input);
  prompt = data.prompt?.toLowerCase() || "";
} catch {
  process.exit(0);
}

// Skip short prompts or greetings (EN + FR)
if (
  prompt.length < 15 ||
  /^(hi|hello|hey|salut|bonjour|merci|thanks|ok|oui|non|yo|coucou)/i.test(
    prompt,
  )
) {
  process.exit(0);
}

const suggestions: string[] = [];

// Helper: match and capture trigger word
function matchTrigger(regex: RegExp, text: string): string | null {
  const match = text.match(regex);
  return match ? match[0] : null;
}

// 1. ai-multimodal - Media files: PDF, audio, video (EN + FR)
// NOTE: "screenshot" removed - use vision-analyzer for UI debugging instead
const trigger1 = matchTrigger(
  /pdf|audio|video|mp3|mp4|wav|transcri|ocr|extract.*text|extract.*data|fichier.*pdf|fichier.*audio|fichier.*video|transcrire|generate.*image|créer.*image|text.*to.*image/i,
  prompt,
);
if (trigger1) {
  suggestions.push(
    `ALWAYS use Skill "ai-multimodal" for PDFs/audio/video/image-generation. Uses Gemini API. [trigger: "${trigger1}"]`,
  );
}

// 2. repomix - External repos (EN + FR)
const trigger2 = matchTrigger(
  /third.?party|external.*repo|library.*code|security.*audit|analyze.*repo|package.*repo|github\.com|repo.*externe|librairie.*externe|audit.*securite|analyser.*repo/i,
  prompt,
);
if (trigger2) {
  suggestions.push(
    `ALWAYS use Skill "repomix" for external repositories. Do NOT manually clone or browse external repos. [trigger: "${trigger2}"]`,
  );
}

// 3. lsp-navigation - Semantic code ops (EN + FR)
const trigger3 = matchTrigger(
  /rename.*symbol|find.*references|find.*usages|where.*used|refactor.*name|all.*occurrences|renommer.*symbole|trouver.*references|où.*utilisé|toutes.*occurrences/i,
  prompt,
);
if (trigger3) {
  suggestions.push(
    `ALWAYS use Skill "lsp-navigation" for find refs/rename. Do NOT use Grep for semantic code operations. [trigger: "${trigger3}"]`,
  );
}

// 4. /explain - Deep code understanding (EN + FR)
const trigger4 = matchTrigger(
  /trace|architecture|flow|diagram|how.*works.*internally|deep.*dive|understand.*system|comprendre.*système|diagramme|flux|comment.*fonctionne.*interne/i,
  prompt,
);
if (trigger4) {
  suggestions.push(
    `ALWAYS run /explain command for deep code understanding. Do NOT manually search and read files - the command produces ASCII diagrams and structured analysis. [trigger: "${trigger4}"]`,
  );
}

// 5. /brainstorm - Multi-perspective research (EN + FR)
const trigger5 = matchTrigger(
  /best.*approach|should.*i.*use|compare|pros.*cons|evaluate|decision|trade.?offs|alternatives|meilleure.*approche|dois.?je.*utiliser|comparer|avantages.*inconvénients|évaluer|décision/i,
  prompt,
);
if (trigger5) {
  suggestions.push(
    `ALWAYS run /brainstorm command for decisions/comparisons. Uses Opus model with multi-round skeptical analysis. Do NOT give quick opinions. [trigger: "${trigger5}"]`,
  );
}

// 6. /create-context-docs - Knowledge docs (EN + FR)
const trigger6 = matchTrigger(
  /learn.*about|document.*for.*later|reference|cheat.?sheet|remember.*how|knowledge.*base|apprendre|documenter.*pour.*plus.*tard|référence|aide.?mémoire|retenir|base.*connaissance/i,
  prompt,
);
if (trigger6) {
  suggestions.push(
    `ALWAYS run /create-context-docs to save reusable knowledge in .claude/docs/. Do NOT just explain - persist the documentation. [trigger: "${trigger6}"]`,
  );
}

// 7. aesthetic - Design IMPROVEMENT (not debugging) (EN + FR)
// NOTE: For debugging (overflow, cut-off), use vision-analyzer instead
const trigger7 = matchTrigger(
  /beautiful|improv.*design|better.*ui|modern.*look|aesthetic|make.*pretty|rendre.*beau|améliorer.*design|plus.*joli|moderniser|esthétique|score.*design|iterate.*design/i,
  prompt,
);
if (trigger7) {
  suggestions.push(
    `ALWAYS use Skill "aesthetic" for design IMPROVEMENT. Uses Gemini to score, generate alternatives, iterate. NOT for debugging bugs. [trigger: "${trigger7}"]`,
  );
}

// 8. /ultrathink - Craftsmanship (EN + FR)
const trigger8 = matchTrigger(
  /complex|elegant|perfect|best.*way|architect|clean.*code|masterpiece|ideal.*solution|complexe|élégant|parfait|meilleure.*façon|architecturer|code.*propre|idéal/i,
  prompt,
);
if (trigger8) {
  suggestions.push(
    `ALWAYS run /ultrathink for complex problems requiring craftsmanship. Deep thinking mode for elegant solutions. [trigger: "${trigger8}"]`,
  );
}

// 9. vision-analyzer agent - Quick UI DEBUGGING (EN + FR)
// NOTE: For design improvement (beautiful, modern), use aesthetic skill instead
const trigger9 = matchTrigger(
  /overflow|cut.*off|misalign|z-?index|layout.*bug|ui.*bug|visual.*bug|looks.*wrong|display.*broken|déborde|coupé|cassé|alignement.*bug|problème.*affichage|rendu.*cassé/i,
  prompt,
);
if (trigger9) {
  suggestions.push(
    `ALWAYS use Task agent "vision-analyzer" for UI bug DEBUGGING (overflow, cut-off, misalignment). Instant Claude Opus analysis. NOT for design improvement. [trigger: "${trigger9}"]`,
  );
}

// 10. databases skill - DB work (EN + FR)
const trigger10 = matchTrigger(
  /sql|query|database|postgres|mongo|migration|schema|index|performance.*query|requête|base.*données|schéma|optimiser.*requête/i,
  prompt,
);
if (trigger10) {
  suggestions.push(
    `ALWAYS use Skill "databases" for database work. Provides PostgreSQL/MongoDB patterns, optimization, migrations. [trigger: "${trigger10}"]`,
  );
}

// 11. /debug - Bug fixing (EN + FR)
const trigger11 = matchTrigger(
  /error|exception|bug|crash|broken|not working|fails|ça marche pas|ne fonctionne pas|erreur|plantage|cassé/i,
  prompt,
);
if (trigger11) {
  suggestions.push(
    `ALWAYS run /debug command for systematic debugging. Uses ULTRA THINK for root cause analysis. Do NOT guess at fixes. [trigger: "${trigger11}"]`,
  );
}

// 12. /refactor - Mass code changes (EN + FR)
const trigger12 = matchTrigger(
  /refactor.*all|rename.*everywhere|change.*across|update.*all.*files|mass.*update|refactoriser|modifier.*partout/i,
  prompt,
);
if (trigger12) {
  suggestions.push(
    `ALWAYS run /refactor command for mass code changes. Uses parallel Snipper agents for speed. Do NOT edit files one by one. [trigger: "${trigger12}"]`,
  );
}

// 13. create-prompt skill - Prompt engineering (EN + FR)
const trigger13 = matchTrigger(
  /write.*prompt|create.*prompt|optimize.*prompt|improve.*prompt|system.*prompt|écrire.*prompt|améliorer.*prompt|créer.*prompt/i,
  prompt,
);
if (trigger13) {
  suggestions.push(
    `ALWAYS use Skill "create-prompt" for prompt engineering. Covers Anthropic/OpenAI best practices. [trigger: "${trigger13}"]`,
  );
}

// 14. nextjs-migration - Next.js 16 upgrade guide (EN + FR)
const trigger14 = matchTrigger(
  /upgrade.*next|migrer.*next|next.*15.*to.*16|breaking.*changes.*next|proxy\.ts|middleware.*migration/i,
  prompt,
);
if (trigger14) {
  suggestions.push(
    `ALWAYS use Skill "nextjs-migration" for Next.js 15→16 upgrade. Covers breaking changes, proxy.ts, codemods. [trigger: "${trigger14}"]`,
  );
}

// 15. claude-code skill - Claude Code customization (EN + FR)
const trigger15 = matchTrigger(
  /\bhook\b|\bskill\b|\bcommand\b|\bagent\b|\bsubagent\b|\bmcp\b|slash.*command|task.*tool|claude\.md|settings\.json|créer.*hook|créer.*skill|créer.*commande|créer.*agent/i,
  prompt,
);
if (trigger15) {
  suggestions.push(
    `ALWAYS use Skill "claude-code" for Claude Code configuration (hooks, skills, commands, agents, MCP). Has comprehensive references. [trigger: "${trigger15}"]`,
  );
}

// 16. docs-seeker - Library documentation (EN + FR)
const trigger16 = matchTrigger(
  /documentation.*for|docs.*for|how.*to.*use.*library|comment.*utiliser|llms\.txt|context7|chercher.*doc|find.*documentation/i,
  prompt,
);
if (trigger16) {
  suggestions.push(
    `ALWAYS use Skill "docs-seeker" for library/framework documentation. Uses context7.com llms.txt and parallel exploration. [trigger: "${trigger16}"]`,
  );
}

// 17. /makerkit:db-sync - Makerkit database migrations (EN + FR)
const trigger17 = matchTrigger(
  /supabase|drizzle|db.*diff|migration.*supabase|typegen|pnpm.*drizzle|usersInAuth|sync.*drizzle/i,
  prompt,
);
if (trigger17) {
  suggestions.push(
    `ALWAYS run /makerkit:db-sync for Supabase + Drizzle migrations in Makerkit projects. Handles full workflow with automatic Drizzle fixes. [trigger: "${trigger17}"]`,
  );
}

// 18. /makerkit:update - Makerkit codebase updates (EN + FR)
const trigger18 = matchTrigger(
  /update.*makerkit|makerkit.*update|upgrade.*codebase|mise.*jour.*makerkit|pull.*upstream|merge.*upstream/i,
  prompt,
);
if (trigger18) {
  suggestions.push(
    `ALWAYS run /makerkit:update to update Makerkit codebase from upstream. Handles conflicts, dependencies, and health checks. [trigger: "${trigger18}"]`,
  );
}

// 19. /makerkit:health - Makerkit health checks (EN + FR)
const trigger19 = matchTrigger(
  /health.*check|typecheck.*lint|verify.*project|check.*project|vérifier.*projet|santé.*projet/i,
  prompt,
);
if (trigger19) {
  suggestions.push(
    `ALWAYS run /makerkit:health to verify project integrity (typecheck, lint, syncpack). Quick validation before commits. [trigger: "${trigger19}"]`,
  );
}

// 20. makerkit-docs skill - Makerkit documentation (EN + FR)
const trigger20 = matchTrigger(
  /makerkit|enhanceAction|enhanceRouteHandler|makerkit.*pattern|rls.*policy|how.*to.*in.*makerkit|app_permissions/i,
  prompt,
);
if (trigger20) {
  suggestions.push(
    `ALWAYS use Skill "makerkit-docs" for Makerkit patterns (enhanceAction, RLS, permissions). Uses Context7 for latest docs. [trigger: "${trigger20}"]`,
  );
}

// 21. debugging - Systematic debugging with Makerkit patterns (EN + FR)
const trigger21 = matchTrigger(
  /root.*cause|systematic.*debug|test.*fail|why.*fail|investigate.*bug|supabase.*error|drizzle.*error|rls.*fail|migration.*fail|turborepo.*fail|hydration.*mismatch|server.*component.*error|analyser.*en.*profondeur|cause.*profonde|erreur.*supabase|erreur.*migration/i,
  prompt,
);
if (trigger21) {
  suggestions.push(
    `ALWAYS use Skill "debugging" for systematic debugging. Four-phase framework + Makerkit patterns (Supabase, Drizzle, Turborepo, Next.js). [trigger: "${trigger21}"]`,
  );
}

// 22. typescript-strict - Type safety (EN + FR)
const trigger22 = matchTrigger(
  /\bany\b.*type|type.*error|ts-ignore|ts-expect-error|type.*guard|unknown.*type|zod.*schema|type.*safety|erreur.*type|typage.*strict|éviter.*any/i,
  prompt,
);
if (trigger22) {
  suggestions.push(
    `ALWAYS use Skill "typescript-strict" for TypeScript type safety. Patterns for avoiding \`any\`, type guards, and Zod validation. [trigger: "${trigger22}"]`,
  );
}

// 23. cache-components skill - Next.js 16 Cache Components (EN + FR)
const trigger23 = matchTrigger(
  /use cache|cacheLife|cacheTag|cache.*invalidation|fetchCache|force-static|opt.*in.*caching/i,
  prompt,
);
if (trigger23) {
  suggestions.push(
    `ALWAYS use Skill "cache-components" for Next.js 16 Cache Components ("use cache", cacheLife, cacheTag). Migration from old patterns included. [trigger: "${trigger23}"]`,
  );
}

// 24. react-compiler skill - React 19 Compiler (EN + FR)
const trigger24 = matchTrigger(
  /react.*compiler|automatic.*memoization|remove.*useMemo|remove.*useCallback|CannotPreserveMemoization|supprimer.*useMemo/i,
  prompt,
);
if (trigger24) {
  suggestions.push(
    `ALWAYS use Skill "react-compiler" for React 19 Compiler patterns. Auto-memoization replaces manual useMemo/useCallback. [trigger: "${trigger24}"]`,
  );
}

// 25. code-splitting skill - Bundle optimization (EN + FR)
const trigger25 = matchTrigger(
  /barrel.*file|code.*splitting|dynamic.*import|next\/dynamic|optimizePackageImports|bundle.*size|tree.*shaking|réduire.*bundle/i,
  prompt,
);
if (trigger25) {
  suggestions.push(
    `ALWAYS use Skill "code-splitting" for bundle optimization. Barrel files, dynamic imports, tree shaking patterns. [trigger: "${trigger25}"]`,
  );
}

// 26. /next-react-optimizer:analyze - Performance analysis (EN + FR)
const trigger26 = matchTrigger(
  /optimize.*next|optimize.*react|analyze.*performance|performance.*issues|slow.*rendering|lent.*rendu|optimiser.*app/i,
  prompt,
);
if (trigger26) {
  suggestions.push(
    `ALWAYS run /next-react-optimizer:analyze for React/Next.js performance analysis. Finds optimization opportunities automatically. [trigger: "${trigger26}"]`,
  );
}

// 27. react19-patterns skill - React 19 new patterns (EN + FR)
const trigger27 = matchTrigger(
  /\buse\s*\(\s*\w*Context|useContext|Context\.Provider|ViewTransition|react.*19.*pattern|nouveau.*pattern.*react/i,
  prompt,
);
if (trigger27) {
  suggestions.push(
    `ALWAYS use Skill "react19-patterns" for React 19 patterns: use() hook, Context shorthand, ViewTransition+Suspense. NOT for compiler optimization. [trigger: "${trigger27}"]`,
  );
}

// 28. mcp-management skill - MCP scopes and configuration (EN + FR)
const trigger28 = matchTrigger(
  /mcp.*scope|user.*scope|project.*scope|local.*scope|\.mcp\.json|mcp.*server|ajouter.*mcp|configurer.*mcp|scope.*mcp|partager.*mcp/i,
  prompt,
);
if (trigger28) {
  suggestions.push(
    `ALWAYS use Skill "mcp-management" for MCP server configuration and scopes (user/local/project). Covers all scope types and sharing with team. [trigger: "${trigger28}"]`,
  );
}

// 29. websearch agent - Web search for current info (EN + FR)
const trigger29 = matchTrigger(
  /search.*web|web.*search|cherche.*sur.*le.*web|recherche.*internet|what'?s.*the.*latest|quoi.*de.*neuf|find.*online|current.*news|actualités|latest.*version|dernière.*version|chercher.*en.*ligne/i,
  prompt,
);
if (trigger29) {
  suggestions.push(
    `ALWAYS use Task agent "websearch" for current information, news, or documentation not in codebase. Fast web search with sources. [trigger: "${trigger29}"]`,
  );
}

// 30. intelligent-search agent - Multi-provider search with LLM routing (EN + FR)
const trigger30 = matchTrigger(
  /deep.*search|intelligent.*search|recherche.*approfondie|compare.*sources|multi.*provider|privacy.*search|recherche.*privée|analyze.*multiple|best.*provider|exa.*search|perplexity|tavily|brave.*search|omnisearch/i,
  prompt,
);
if (trigger30) {
  suggestions.push(
    `ALWAYS use Task agent "intelligent-search" for deep research with multiple providers (Tavily, Exa, Brave, Perplexity). Routes to best provider based on query intent. [trigger: "${trigger30}"]`,
  );
}

// 31. code-review-mastery - Complete code review lifecycle (EN + FR)
const trigger31 = matchTrigger(
  /code.*review|review.*pr|review.*code|check.*my.*code|audit.*code|pr.*review|revue.*code|vérifier.*code|analyser.*pr|revoir.*code|recevoir.*feedback|verification.*gate/i,
  prompt,
);
if (trigger31) {
  suggestions.push(
    `ALWAYS use Skill "code-review-mastery" for complete code review lifecycle. WHAT to review (OWASP, SOLID) + HOW to interact + Verification gates. [trigger: "${trigger31}"]`,
  );
}

// Output with ASSERTIVE format
if (suggestions.length > 0) {
  console.log(`<tool-router>
MANDATORY TOOL SELECTION:
${suggestions.join("\n")}

These tools exist because they provide better results than manual approaches.
Invoke the specified Skill/command/agent FIRST before attempting manual work.
</tool-router>`);
}

process.exit(0);
