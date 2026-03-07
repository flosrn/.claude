---
name: summarize
description: "Summarize or extract text/transcripts from URLs, podcasts, YouTube videos, and local files using the summarize CLI (summarize.sh). Use when: 'summarize this', 'what is this link about', 'transcribe this video', 'resume cet article', 'c est quoi ce lien', 'TL;DR', or any request to extract content from a URL or file."
---

# Summarize

Fast CLI to summarize URLs, local files, and YouTube links via `summarize` (summarize.sh).

## Quick start

```bash
summarize "https://example.com" --model google/gemini-3-flash-preview
summarize "/path/to/file.pdf" --model google/gemini-3-flash-preview
summarize "https://youtu.be/VIDEO_ID" --youtube auto
```

## YouTube: summary vs transcript

Best-effort transcript (URLs only):

```bash
summarize "https://youtu.be/VIDEO_ID" --youtube auto --extract-only
```

If the user asked for a transcript but it's huge, return a tight summary first, then ask which section/time range to expand.

## Model + keys

Set the API key for your chosen provider:

- Google: `GEMINI_API_KEY`
- OpenAI: `OPENAI_API_KEY`
- Anthropic: `ANTHROPIC_API_KEY`

Default model is `google/gemini-3-flash-preview` if none is set.

## Useful flags

- `--length short|medium|long|xl|xxl|<chars>` — control summary length
- `--max-output-tokens <count>`
- `--extract-only` — raw text extraction, no summary (URLs only)
- `--json` — machine-readable output
- `--firecrawl auto|off|always` — fallback extraction for blocked sites
- `--youtube auto` — Apify fallback if `APIFY_API_TOKEN` set

## Config

Optional config file: `~/.summarize/config.json`

```json
{ "model": "openai/gpt-5.2" }
```

Optional services:

- `FIRECRAWL_API_KEY` for blocked sites
- `APIFY_API_TOKEN` for YouTube fallback
