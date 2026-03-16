import { existsSync } from "node:fs";

const CONTEXT_WINDOWS: Record<string, { maxTokens: number; autocompactBuffer: number }> = {
	"200k": { maxTokens: 200_000, autocompactBuffer: 45_000 },
	"1m": { maxTokens: 1_000_000, autocompactBuffer: 200_000 },
};

/**
 * Detect effective context window from model info.
 * Uses exceeds_200k_tokens flag and model ID pattern (e.g. [1m] suffix).
 */
export function getEffectiveContextWindow(
	modelId: string,
	exceeds200k?: boolean,
): { maxTokens: number; autocompactBuffer: number } {
	if (exceeds200k || modelId.includes("[1m]")) {
		return CONTEXT_WINDOWS["1m"];
	}
	return CONTEXT_WINDOWS["200k"];
}

export interface TokenUsage {
	input_tokens: number;
	output_tokens: number;
	cache_creation_input_tokens?: number;
	cache_read_input_tokens?: number;
}

export interface TranscriptLine {
	message?: { usage?: TokenUsage };
	timestamp?: string;
	isSidechain?: boolean;
	isApiErrorMessage?: boolean;
}

export interface ContextResult {
	tokens: number;
	percentage: number;
}

export async function getContextLength(
	transcriptPath: string,
): Promise<number> {
	try {
		const content = await Bun.file(transcriptPath).text();
		const lines = content.trim().split("\n");

		if (lines.length === 0) return 0;

		let mostRecentMainChainEntry: TranscriptLine | null = null;
		let mostRecentTimestamp: Date | null = null;

		for (const line of lines) {
			try {
				const data = JSON.parse(line) as TranscriptLine;

				if (!data.message?.usage) continue;
				if (data.isSidechain === true) continue;
				if (data.isApiErrorMessage === true) continue;
				if (!data.timestamp) continue;

				const entryTime = new Date(data.timestamp);

				if (!mostRecentTimestamp || entryTime > mostRecentTimestamp) {
					mostRecentTimestamp = entryTime;
					mostRecentMainChainEntry = data;
				}
			} catch {}
		}

		if (!mostRecentMainChainEntry?.message?.usage) {
			return 0;
		}

		const usage = mostRecentMainChainEntry.message.usage;

		return (
			(usage.input_tokens || 0) +
			(usage.cache_read_input_tokens ?? 0) +
			(usage.cache_creation_input_tokens ?? 0)
		);
	} catch {
		return 0;
	}
}

export interface ContextDataParams {
	transcriptPath: string;
	maxContextTokens: number;
	autocompactBufferTokens: number;
	useUsableContextOnly?: boolean;
	overheadTokens?: number;
}

export async function getContextData({
	transcriptPath,
	maxContextTokens,
	autocompactBufferTokens,
	useUsableContextOnly = false,
	overheadTokens = 0,
}: ContextDataParams): Promise<ContextResult> {
	if (!transcriptPath || !existsSync(transcriptPath)) {
		return { tokens: 0, percentage: 0 };
	}

	const contextLength = await getContextLength(transcriptPath);
	let totalTokens = contextLength + overheadTokens;

	// If useUsableContextOnly is true, add the autocompact buffer to displayed tokens
	if (useUsableContextOnly) {
		totalTokens += autocompactBufferTokens;
	}

	// Always calculate percentage based on max context window
	// (matching /context display behavior)
	const percentage = Math.min(100, (totalTokens / maxContextTokens) * 100);

	return {
		tokens: totalTokens,
		percentage: Math.round(percentage),
	};
}
