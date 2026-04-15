# Prompting Strategies for Neutral Second Opinions

## Neutrality Principles

The goal is an *independent* opinion. If the prompt reveals what Claude already thinks, Codex may anchor to that position rather than reasoning from scratch.

**Do:**
- State the problem objectively: "The developer is deciding between X and Y"
- Include relevant code as-is, without commentary
- Ask open-ended questions: "What approach would you recommend and why?"

**Don't:**
- Reveal Claude's position: "I think X is better, do you agree?"
- Use leading framing: "Given the obvious benefits of X..."
- Editorialize on the code: "This messy function needs..."

### Neutral vs. Biased Examples

Biased: "This function is overly complex. Should we refactor it to use composition instead of inheritance?"
Neutral: "Here is a function that uses inheritance. The developer is considering whether composition would be a better fit. What are the trade-offs for this specific case?"

Biased: "The tests are clearly missing edge cases. What tests should we add?"
Neutral: "Here is the current test suite for this module. Are there gaps in coverage? What additional test cases would improve confidence?"

## Context Density

Codex automatically reads the working directory, so it already has access to the full repo. The prompt should provide *focused* context, not dump entire files.

**Include:**
- The specific function/class under discussion (10-50 lines)
- Its immediate callers or consumers if relevant
- Error output or stack traces if debugging
- Any constraints the user mentioned (performance, compatibility, etc.)

**Exclude:**
- Entire files when only one function matters
- Unrelated code from other parts of the repo
- Build configuration, CI files, etc. (unless that's the topic)

**Rule of thumb:** Keep inline code context under 200 lines. If more context is needed, name the file paths and let Codex read them itself.

## Prompt Structure

Use the **Context-Question-Constraints** pattern:

```
Context:
[Brief description of the project/module]
[Relevant code snippets or file paths]

Question:
[The specific thing to evaluate or decide]

Constraints:
[Any requirements: performance, backward compatibility, team conventions, etc.]
```

## Anti-Patterns

1. **Multiple unrelated questions** -- Ask one thing at a time. Codex gives better answers to focused questions.
2. **Too much context** -- A 500-line prompt buries the actual question. Be surgical.
3. **Vague questions** -- "Is this code good?" gives vague answers. "Does this error handling cover the case where the API returns a partial response?" gets specific answers.
4. **Implementation requests** -- This is for opinions, not code generation. "What approach should we take?" not "Write the implementation."
