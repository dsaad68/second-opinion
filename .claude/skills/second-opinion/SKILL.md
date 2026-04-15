---
name: second-opinion
description: >
  Get an independent second opinion from OpenAI Codex on any technical question,
  design decision, code review, debugging strategy, or architectural choice. Use
  when the user wants another perspective on their current work, even if they
  don't mention "Codex" explicitly. Runs Codex in read-only mode — it cannot
  modify files. Invoked via /second-opinion [question or topic].
compatibility: >
  Requires codex-cli installed and authenticated (codex login or OPENAI_API_KEY).
---

# Second Opinion via Codex

## Prerequisites

Before running, verify the environment:

```bash
which codex && codex --version
```

If `codex` is not found, tell the user to install it:
```bash
npm install -g @openai/codex
codex login
```

## Workflow

Follow these steps in order. Steps 1-3 happen before invoking Codex.

### Step 1: Parse the request

Extract the question or topic from `$ARGUMENTS`.

If `$ARGUMENTS` is empty, ask the user: "What would you like a second opinion on?"

### Step 2: Gather context

Identify the 1-3 most relevant files to the question. Read them. Also gather:

- `git diff --stat` if the question relates to recent changes
- Error output or logs if debugging
- Any constraints the user mentioned

Keep inline context under 200 lines. Codex reads the working directory automatically — name file paths instead of pasting entire files when possible.

### Step 3: Form your own opinion FIRST

Before calling Codex, reason about the question internally and form your own position. This is critical — seeing Codex's answer first would create anchoring bias. Do not emit your analysis yet; hold it until Step 5.

### Step 4: Call Codex

Formulate a **neutral** prompt that does NOT reveal your opinion. See [references/prompting-strategies.md](references/prompting-strategies.md) for guidance.

Use the Context-Question-Constraints structure:

```
Context:
[Brief project description + relevant code/file paths]

Question:
[The specific question, framed neutrally]

Constraints:
[Performance requirements, compatibility needs, team conventions, etc.]
```

Run the script:

```bash
bash .claude/skills/second-opinion/scripts/ask-codex.sh "the neutral prompt here"
```

Optional flags:
- `--model MODEL` — override model (default: `gpt-5.4`)
- `--timeout SECS` — max wait time (default: 1200, i.e. 20 minutes)

### Step 5: Present the comparison

Use this format:

```markdown
## Second Opinion: [Topic]

### Claude's Analysis
[Your independent analysis from Step 3]

### Codex's Analysis
[Codex's response from Step 4]

### Comparison

**Agreements:**
- [Points where both analyses converge]

**Disagreements:**
- [Point] — Claude: [position] / Codex: [position]

**Synthesis:**
[Your recommendation weighing both perspectives. When disagreeing with Codex,
cite specific evidence from the code. When Codex raises a point you missed,
acknowledge it.]
```

### Error fallback

If the script fails (codex not installed, timeout, auth error), present the error message to the user and offer your solo analysis instead. Do not silently skip the Codex call.

## Prompt Templates

**Architecture / design decision:**
> Context: This project [brief description]. The relevant code is in [file paths].
> Question: The developer is choosing between [option A] and [option B] for [goal]. What approach would you recommend and why?
> Constraints: [any constraints]

**Code review:**
> Context: Here are the recent changes: [git diff or code snippet].
> Question: Review these changes for correctness, performance issues, and potential bugs. What concerns do you see?
> Constraints: [any constraints]

**Debugging:**
> Context: The following code produces this error: [error]. The relevant code is in [file paths]: [snippet].
> Question: What is the likely root cause and how would you fix it?
> Constraints: [any constraints]

**General technical question:**
> Context: This project [brief description]. Relevant files: [paths].
> Question: [The question, stated neutrally]
> Constraints: [any constraints]

## Gotchas

- Codex reads the working directory automatically. Don't over-stuff the prompt with file contents it can discover on its own — name file paths instead.
- `--sandbox read-only` is hardcoded in the script. Codex will never modify your files.
- Each invocation uses OpenAI API credits. Be aware of cost for large/frequent queries.
- If Codex times out (default 1200s / 20 min), try a more focused question or increase `--timeout`.
- Codex may suggest tools or libraries that don't exist in this project. Cross-check recommendations against the actual codebase.
- When both Claude and Codex agree, state the consensus clearly — convergent independent opinions are a strong signal.

## Troubleshooting

**"codex-cli not found"**
Install: `npm install -g @openai/codex` then `codex login`

**"Codex exited with code N"**
Check authentication: `codex login` or verify `OPENAI_API_KEY` is set. Check network connectivity.

**"Codex timed out"**
The question or context may be too large. Simplify the prompt or increase timeout: `--timeout 180`

**"Codex returned an empty response"**
Retry once. If it persists, the model may be overloaded — try again later or use a different model: `--model o3`
