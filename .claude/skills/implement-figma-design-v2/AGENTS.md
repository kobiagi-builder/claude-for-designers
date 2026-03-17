# implement-figma-design

This directory is a skill for Claude Code. It translates Figma designs into production-ready code using a multi-phase planning, execution, and Playwright-validated review workflow.

## If you are here to use implement-figma-design

Follow the instructions in the project's CLAUDE.md. Provide a Figma link and a short description of the flow, and the skill orchestrates the rest.

## If you are here to work on implement-figma-design

### Structure

- `SKILL.md` — the main orchestrator (9 phases: input validation → design fetch → analysis → confidence check → planning → plan-editing → execution → review → finish)
- `subagents/` — prompt templates for specialized subagents (planning, plan-editing, executing, testing, reviewing)
- `subskills/` — reusable operational skills (design-planning, design-executing, design-finishing)
- `orchestrator/` — Python scripts for prompt building and phase management
- `docs/` — documentation, information flow diagram, and evaluation cases

### Principles

- **Improve the system, not the symptom** — Prefer clean architecture and correctness over quick patches.
- **Figma is the source of truth** — Every visual property comes from the Figma design data, never approximated. When project conventions conflict with Figma specs, the Figma design wins.
- **It's a skill, not software** — Prefer succinct, meaningful prose and bullet points over complex orchestration paths. Prioritize short instructions that generalize well.
- **User instructions are top priority** — Specific user instructions always have priority over skill defaults.
- **Confidence-gated, not fire-and-forget** — Unlike trycycle, this skill asks the user for clarification when design understanding is below 98% confidence. Visual fidelity demands certainty.
- **Keep the orchestrator minimal** — Work is done in the subagents; the orchestrator saves its context window for user interactions.
- **Playwright validates everything** — All visual verification uses Playwright screenshots compared against Figma screenshots. No manual QA.

### Subagent Architecture

| Subagent | Lifecycle | Purpose |
|----------|-----------|---------|
| Planning | Ephemeral (fresh each round) | Creates and refines implementation plans |
| Plan Editor | Ephemeral (fresh each round) | Critiques and improves plans |
| Test Strategy | Ephemeral | Proposes Playwright testing strategy |
| Test Plan | Ephemeral | Builds concrete test plan from strategy |
| Executing | Persistent (resumed for fixes) | Implements the code |
| Reviewer | Ephemeral (fresh each round) | Playwright visual comparison + code review |

### Key Differences from trycycle

| Aspect | trycycle | implement-figma-design |
|--------|----------|----------------------|
| Input | Any code task | Figma link + flow description |
| Unknowns gate | Simple blocking questions | 98% confidence threshold across 5 dimensions |
| Git/worktrees | Isolated worktree per task | No git operations (removed) |
| Testing | Flexible (unit, integration, E2E) | Playwright-only visual comparison |
| Source of truth | Code behavior | Figma screenshot + design context |
| Finishing | Merge/PR/keep/discard | Browser review / adjust / complete |

### Process

- **No git operations** — This skill does not create branches, worktrees, or commits. The user handles version control.
- **MCP dependencies** — Requires Figma MCP (design data, screenshots, assets) and Playwright MCP (visual validation).

### Subskills

The skills in `subskills/` are adapted from trycycle's upstream superpowers, customized for Figma design implementation. Edit them directly when changes are needed.

### Prompt Templates

The prompt templates in `subagents/` define the instructions for each specialized subagent. They use `{PLACEHOLDER}` syntax for runtime value binding and `{{#if NAME}} ... {{/if}}` for conditional blocks.
