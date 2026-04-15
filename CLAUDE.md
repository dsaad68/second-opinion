# Using the second-opinion skill

Invoke `/second-opinion [question]` whenever the user wants an independent perspective on a design decision, code review, debugging, or architecture choice — even if they don't say "Codex".
Form your own opinion first, then call Codex (read-only) and present both side-by-side with a synthesis.
Requires `codex-cli` installed and authenticated (`npm install -g @openai/codex && codex login`, or `OPENAI_API_KEY`).
See [.claude/skills/second-opinion/SKILL.md](.claude/skills/second-opinion/SKILL.md) for the full workflow.
