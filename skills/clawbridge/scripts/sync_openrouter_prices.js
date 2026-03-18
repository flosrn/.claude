const fs = require('fs');
const path = require('path');

// --- Config ---
const PRICING_FILE = '/root/clawd/skills/clawbridge/data/config/pricing.json';
const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/models';

async function sync() {
    console.log('🔄 Syncing OpenRouter model prices...');
    
    try {
        const response = await fetch(OPENROUTER_API_URL);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const json = await response.json();
        if (!json.data || !Array.isArray(json.data)) throw new Error('Invalid OpenRouter response format');

        const newPricing = {
            "updatedAt": new Date().toISOString(),
            "default": { "input": 0.1, "output": 0.4 } // Safety fallback
        };

        json.data.forEach(model => {
            if (!model.id || !model.pricing) return;

            // OpenRouter prices are in USD per 1 token
            // We store them as USD per 1 Million tokens
            const input = parseFloat(model.pricing.prompt) * 1000000;
            const output = parseFloat(model.pricing.completion) * 1000000;
            const cacheRead = parseFloat(model.pricing.input_cache_read || 0) * 1000000;

            newPricing[model.id] = {
                input: parseFloat(input.toFixed(4)),
                output: parseFloat(output.toFixed(4))
            };

            // Optional: Support cache read if available
            if (cacheRead > 0) {
                newPricing[model.id].cacheRead = parseFloat(cacheRead.toFixed(4));
            }
        });

        // Ensure directory exists
        const dir = path.dirname(PRICING_FILE);
        if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

        fs.writeFileSync(PRICING_FILE, JSON.stringify(newPricing, null, 2));
        console.log(`✅ Success! Updated prices for ${Object.keys(newPricing).length - 2} models.`);
        console.log(`📂 File saved: ${PRICING_FILE}`);

    } catch (e) {
        console.error('❌ Sync Failed:', e.message);
        process.exit(1);
    }
}

sync();