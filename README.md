# Second Opinion

A Claude Code skill that asks OpenAI Codex for an independent second opinion on technical questions, design decisions, code reviews, or debugging.

## Usage

```
/second-opinion [question or topic]
```

Claude forms its own opinion first, then calls Codex (read-only), and presents both analyses side-by-side with a synthesis.

## Flow

```mermaid
flowchart TD
    A[User runs /second-opinion] --> B[Parse request]
    B --> C[Gather context: files, diffs, errors]
    C --> D[Claude forms own opinion privately]
    D --> E[Build neutral prompt]
    E --> F[Run ask-codex.sh in read-only sandbox]
    F --> G{Codex responds?}
    G -- yes --> H[Present Claude vs Codex side by side]
    G -- no --> I[Show error and offer solo analysis]
    H --> J[Synthesis and recommendation]
```

## Requirements

- [`codex-cli`](https://github.com/openai/codex) installed and authenticated:
  ```bash
  npm install -g @openai/codex
  codex login
  ```

## Layout

- `SKILL.md` — skill definition and workflow
- `scripts/ask-codex.sh` — invokes Codex in `--sandbox read-only`
- `references/` — prompting guidance
