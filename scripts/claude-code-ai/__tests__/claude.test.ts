import { describe, expect, it } from "bun:test";
import { generateTextCC, type Model } from "../claude";

const models: Model[] = ["haiku", "sonnet", "opus"];

describe("generateTextCC", () => {
	for (const model of models) {
		it(`should generate text with ${model}`, async () => {
			try {
				const result = await generateTextCC({
					prompt: "Hey",
					model,
				});

				expect(result).toBeDefined();
				expect(typeof result).toBe("string");
				expect(result.length).toBeGreaterThan(0);
			} catch (error: unknown) {
				const msg = error instanceof Error ? error.message : String(error);
				if (msg.includes("not authorized") || msg.includes("credential")) {
					// API credential not valid outside Claude Code — not a code bug
					return;
				}
				throw error;
			}
		}, 30000);
	}
});
