---
name: "implement-figma-design-advanced"
description: "Structured multi-phase Figma-to-code workflow with iterative planning, execution, and Playwright validation. Trigger when the user provides Figma URLs with a description of the flow to implement. Requires Figma MCP and Playwright MCP connections."
---

# Implement Figma Design

Use this skill when the user wants to implement a Figma design. You must follow this skill; if for some reason that becomes impossible, you must stop and tell the user. You must not finish the request in a different way than the user instructed.

The user's instructions are paramount. If anything in this skill conflicts with the user's instructions, follow the user.

## Required User Input

This skill requires two inputs from the user:

1. **Figma link** — a URL in the format `https://figma.com/design/:fileKey/:fileName?node-id=X-Y`
2. **Short description** — a brief description of the flow, component, or page being implemented

**If either input is missing, ask the user to provide it before proceeding.** Do not guess or assume. Both are mandatory.

## Tech Stack (Default)

All implementations use the following stack unless the user explicitly specifies otherwise:

- **Framework**: Next.js (App Router)
- **Styling**: Tailwind CSS
- **Component Library**: shadcn/ui
- **Language**: TypeScript

If the project doesn't have these set up yet, the implementation subagent must initialize them as the first task (e.g., `npx create-next-app`, `npx shadcn@latest init`).

## Prerequisites

- Figma MCP server must be connected and accessible
- Playwright MCP must be connected for visual validation
- A dev server must be running or startable for Playwright screenshots

## Phase wrapper helper

Several steps below reference prompt template files in `<skill-directory>/subagents/`. Do not reconstruct those prompts yourself. Prepare phase prompts with `python3 <skill-directory>/orchestrator/run_phase.py`.

When a step below tells you to prepare a phase:

1. Use `python3 <skill-directory>/orchestrator/run_phase.py prepare --phase <phase-name> --template <template-path> --set NAME=VALUE --set-file NAME=PATH`
2. The wrapper renders the prompt template, writes the result to an artifacts directory, and returns JSON with the `prompt_path`.
3. Send the exact contents of the returned `prompt_path` verbatim to the target subagent.
4. Pass short scalar values with `--set NAME=VALUE`.
5. Pass multiline values (design analysis, review findings) with `--set-file NAME=PATH`. Save multiline content to a temp file before invocation.
6. Use `--require-nonempty-tag TAG` when a prompt requires a tagged block to contain real content.
7. Use `--ignore-tag-for-placeholders TAG` when placeholder-like text may appear inside that tag.

The prompt builder supports conditional blocks: `{{#if NAME}} ... {{/if}}` includes the block only when `NAME` is bound to a non-empty value.

## Subagent Defaults

- Planning subagents are ephemeral: spawn a fresh planning agent for the initial plan and for every plan-edit round.
- Test strategy and test plan subagents are ephemeral.
- The implementation subagent is persistent: create one implementation agent, then resume it for every fix round.
- Review subagents are ephemeral: create a fresh reviewer for each post-implementation review round.

## Timing expectations

Planning and review subagents typically take 5-15 minutes. The implementation subagent typically takes 15-60 minutes for complex pages. Do not poll frequently.

---

## Phase 1: Validate Inputs

Confirm the user has provided both required inputs:

1. **Figma link** — extract `fileKey` and `nodeId` from the URL
2. **Flow description** — the user's description of what to implement

If either is missing, ask:

> To implement a Figma design, I need:
> 1. A Figma link (e.g., `https://figma.com/design/abc123/MyFile?node-id=1-2`)
> 2. A short description of the flow or component
>
> Please provide both so I can get started.

Do not proceed until both are provided.

---

## Phase 2: Fetch Design Context & Visual Reference

### 2.1 Fetch Design Context

Run `get_figma_data` (or `get_design_context`) with the extracted file key and node ID:

```
get_figma_data(fileKey=":fileKey", nodeId=":nodeId")
```

This provides structured data: layout properties, typography, colors, component structure, spacing, and padding.

**If the response is too large or truncated:**
1. Run `get_metadata(fileKey=":fileKey", nodeId=":nodeId")` to get the node map
2. Fetch individual child nodes with `get_figma_data` for each child

### 2.2 Capture Visual Reference

Run `get_screenshot` with the same file key and node ID:

```
get_screenshot(fileKey=":fileKey", nodeId=":nodeId")
```

This screenshot is the source of truth for visual validation throughout all phases. Keep it accessible.

### 2.3 Download Required Assets

Download any assets (images, icons, SVGs) returned by the Figma MCP server.

**Asset rules:**
- If the Figma MCP returns a `localhost` source, use it directly
- Do NOT import or add new icon packages — all assets come from the Figma payload
- Do NOT use placeholders if a source URL is provided

---

## Phase 3: Deep Design Analysis

Before any planning, perform thorough analysis of the design.

### 3.1 Structural Analysis

Break down the design into its complete anatomy:

1. **Component Hierarchy**: Map every component, nesting, and relationships
2. **Layout System**: Identify grid structure, flex directions, gaps, spatial relationships
3. **Spacing Map**: Document all padding, margins, and gaps
4. **Responsive Breakpoints**: Identify constraints suggesting responsive rules

### 3.2 Visual Properties Extraction

For every unique element, extract:

- **Typography**: Font family, size, weight, line height, letter spacing, text color, alignment
- **Colors**: Background, border, text, gradients, opacity
- **Effects**: Shadows, blurs, overlays
- **Borders**: Width, style, color, radius (per corner if different)
- **Sizing**: Fixed vs. auto vs. fill, min/max constraints, aspect ratios

### 3.3 Interaction & State Analysis

Identify all interactive elements and their states:

- Hover, active/pressed, focus, disabled, loading, empty states

### 3.4 Content & Data Patterns

- Static vs. dynamic content
- Lists & repetition patterns
- Edge cases: long text truncation, missing images, empty states

### 3.5 Mock Data & Interactivity Plan

The implementation must be **demo-ready** — looking, feeling, and behaving like a real product with realistic content and working interactions.

**Content inventory** — for every piece of content in the design, classify and plan:

| Content Type | Examples | Mock Data Approach |
|---|---|---|
| **User profiles** | Names, avatars, roles, emails | Realistic diverse names, placeholder avatar images, real-looking emails |
| **Metrics & numbers** | Revenue, counts, percentages, KPIs | Plausible business numbers with proper formatting ($12,450, 23.5%, 1,247) |
| **Dates & timestamps** | Created dates, deadlines, last active | Relative to current date (today, yesterday, "3 days ago", "Mar 14, 2026") |
| **Text content** | Descriptions, comments, messages | Domain-appropriate realistic copy, not lorem ipsum |
| **Lists & tables** | Data rows, card grids, feeds | 5-15 items with varied but realistic data, not repetitive |
| **Status indicators** | Badges, progress bars, tags | Mix of different states (active, pending, completed, overdue) |
| **Navigation items** | Menu items, tabs, breadcrumbs | Real labels matching the design's domain |
| **Media** | Images, thumbnails, charts | Placeholder image services or SVG placeholders with realistic dimensions |

**Interactivity inventory** — for every interactive element, plan the demo behavior:

| Element | Demo Behavior |
|---|---|
| **Buttons** | Click handlers with visual feedback (loading state, success toast, or state change) |
| **Navigation/tabs** | Switch between views, highlight active state |
| **Forms & inputs** | Accept input, show validation feedback |
| **Dropdowns/selects** | Open with options, allow selection |
| **Modals/dialogs** | Open on trigger, close on dismiss |
| **Toggle/switch** | Toggle state on click |
| **Expandable sections** | Expand/collapse with animation |
| **Search/filter** | Filter displayed mock data in real-time |
| **Hover states** | Show tooltips, card elevations, color changes |

Save the complete design analysis (including mock data and interactivity plan) to a temp file for use by subagents.

---

## Phase 4: Confidence-Gated Critical Unknowns

Before proceeding to planning, score your understanding across these dimensions (0-100):

| Dimension | Question |
|-----------|----------|
| Component Structure | Can I name every component and its props? |
| Layout Accuracy | Can I reproduce the exact spacing and alignment? |
| Visual Fidelity | Do I know every color, font, shadow, and radius? |
| Interaction Coverage | Do I know all states and transitions? |
| Edge Cases | Have I considered what happens with varying content? |

**If confidence < 98% in ANY dimension**: Ask the user clarifying questions. List each blocking question succinctly. Do NOT proceed until confidence >= 98%.

**If confidence >= 98% across all dimensions**: Reply exactly:

`Design fully understood. Getting started with planning.`

If there are critical unknowns beyond design (e.g., routing, state management, data sources), list each blocking question succinctly:

`1. Question?`

Ask them together. Proceed once answered.

---

## Phase 5: Testing Strategy

If the user has already provided detailed instructions for testing, use them and skip to Phase 6.

Otherwise, dispatch a subagent to analyze the design and the codebase and propose a Playwright-based visual testing strategy.

Immediately before dispatch, prepare the `test-strategy` phase via the phase wrapper using template `<skill-directory>/subagents/prompt-test-strategy.md`, with `--set-file DESIGN_ANALYSIS=<analysis-temp-file>`.

When the subagent returns a proposed strategy, present it to the user verbatim and ask for explicit approval or edits. Do not proceed unless the user explicitly accepts or provides changes. Silence or implied approval does not count as agreement.

The strategy must not rely on manual QA or human validation. All visual verification must use Playwright screenshots, comparisons, and automated assertions.

If the user requests changes, redispatch with the updated context. Repeat until explicit approval.

The agreed testing strategy is used in Phase 8.

---

## Phase 6: Plan with design-planning (subagent-owned)

Spec writing must be done by a dedicated subagent. Only subagents read or write plan files.

Spawn a fresh planning subagent. Immediately before dispatch, prepare the `planning-initial` phase via the phase wrapper using template `<skill-directory>/subagents/prompt-planning-initial.md`, with:
- `--set-file USER_FLOW_DESCRIPTION=<description-temp-file>`
- `--set-file DESIGN_ANALYSIS=<analysis-temp-file>`
- `--set-file FIGMA_DESIGN_CONTEXT=<figma-context-temp-file>`
- `--set-file PROJECT_CONTEXT=<project-context-temp-file>`

Wait for the planning subagent to return either:
- A planning report containing `## Plan verdict`, `## Plan path`
- Or a report beginning with `USER DECISION REQUIRED:`

If `USER DECISION REQUIRED:`, present to the user, relay their answer back, and wait again.

Once a planning report is returned, update `{IMPLEMENTATION_PLAN_PATH}` from `## Plan path` and confirm the plan file exists.

---

## Phase 7: Plan-editor loop (up to 5 rounds)

Deploy a fresh planning subagent to critique the current plan against the user's request, the design analysis, and the codebase, then either declare it already excellent unchanged or improve it directly.

The plan editor is stateless: each round is a fresh first-look pass with only the template, the task input, and the current plan.

Immediately before each edit dispatch, prepare the `planning-edit` phase via the phase wrapper using template `<skill-directory>/subagents/prompt-planning-edit.md`, with:
- `--set-file USER_FLOW_DESCRIPTION=<description-temp-file>`
- `--set-file DESIGN_ANALYSIS=<analysis-temp-file>`
- `--set IMPLEMENTATION_PLAN_PATH={IMPLEMENTATION_PLAN_PATH}`

After each edit round:
1. Wait for the subagent to return a planning report or `USER DECISION REQUIRED:`.
2. If `USER DECISION REQUIRED:`, relay to user and wait.
3. Update `{IMPLEMENTATION_PLAN_PATH}` from `## Plan path`.
4. If `## Plan verdict` is `READY`, continue to Phase 8.
5. If `## Plan verdict` is `REVISED`, repeat with a fresh planning subagent.
6. Repeat up to 5 rounds.

If still not `READY` after 5 rounds:
1. Stop looping.
2. Dispatch a subagent to review past sessions and hypothesize why the loop is not converging.
3. Present that report and the latest plan to the user and await instructions.

---

## Phase 8: Build test plan (subagent-owned)

Now that the implementation plan is finalized, dispatch a subagent to reconcile the testing strategy against the plan and produce the concrete Playwright test plan.

Immediately before dispatch, prepare the `test-plan` phase via the phase wrapper using template `<skill-directory>/subagents/prompt-test-plan.md`, with:
- `--set IMPLEMENTATION_PLAN_PATH={IMPLEMENTATION_PLAN_PATH}`
- `--set-file DESIGN_ANALYSIS=<analysis-temp-file>`

When the subagent returns:

1. Update `{TEST_PLAN_PATH}` from `## Test plan summary`.
2. If the report includes `## Strategy changes requiring user approval`, present that section to the user verbatim.
3. If the user requests changes, redispatch and repeat until approved.
4. Do not proceed until the test plan is accepted.

---

## Phase 8.5: Present Plan for User Approval (Plan Mode)

Before executing, enter **Plan Mode** and present the finalized implementation plan and test plan to the user as a structured To-Do checklist.

1. Use `EnterPlanMode` to switch to plan mode.
2. Present the plan as a numbered checklist with clear task groupings:

```
## Implementation Plan

### Setup
- [ ] Initialize Next.js project with Tailwind CSS and shadcn/ui
- [ ] Configure design tokens from Figma analysis

### Components
- [ ] Create [ComponentA] — [description]
- [ ] Create [ComponentB] — [description]
...

### Mock Data & Interactivity
- [ ] Create src/data/mockData.ts with realistic data
- [ ] Wire up interactive handlers (tabs, buttons, modals, etc.)

### Testing
- [ ] Playwright screenshot at 1440px viewport
- [ ] Playwright screenshot at 768px viewport
- [ ] Playwright screenshot at 375px viewport
- [ ] Verify hover/active states
- [ ] Verify interactivity (clicks, toggles, navigation)
```

3. Ask the user: **"Does this plan look good? I'll start building once you approve."**
4. Wait for explicit user approval. If the user requests changes, update the plan accordingly.
5. Once approved, use `ExitPlanMode` and proceed to Phase 9.

**Do not proceed to execution without user approval of the plan.**

---

## Phase 9: Execute with design-executing (subagent-owned)

Code implementation must be done by a new, dedicated subagent.

Spawn a fresh implementation subagent. Immediately before dispatch, prepare the `executing` phase via the phase wrapper using template `<skill-directory>/subagents/prompt-executing.md`, with:
- `--set IMPLEMENTATION_PLAN_PATH={IMPLEMENTATION_PLAN_PATH}`
- `--set-file FIGMA_DESIGN_CONTEXT=<figma-context-temp-file>`

The implementation subagent executes all tasks from the plan continuously without pausing, using TDD where the test plan specifies: establish the red state first, implement to green.

**Critical requirements**:
- The implementation MUST look exactly like the Figma mockup. Components, colors, spacing, typography, behavior — everything must be identical. This is non-negotiable.
- The implementation MUST include a **mock data file** (`src/data/mockData.ts`) with realistic, domain-appropriate data for all dynamic content. No lorem ipsum, no "Item 1, Item 2", no placeholder text.
- The implementation MUST be **interactive and demo-ready** — buttons respond to clicks, tabs switch views, modals open/close, forms accept input, and lists can be filtered/sorted where applicable.
- All interactive state (selected tab, open modal, toggle values) must be managed with React state hooks.

Do not proceed to review until the implementation subagent has returned a report.

---

## Phase 10: Post-implementation review loop with Playwright (up to 8 rounds)

After execution completes, deploy a fresh reviewer with no prior context.

Immediately before dispatch, prepare the `post-implementation-review` phase via the phase wrapper using template `<skill-directory>/subagents/prompt-post-impl-review.md`, with:
- `--set IMPLEMENTATION_PLAN_PATH={IMPLEMENTATION_PLAN_PATH}`
- `--set-file FIGMA_DESIGN_CONTEXT=<figma-context-temp-file>`
- `--set DEV_SERVER_URL=<dev-server-url>`

The reviewer must:

### 10.1 Take Implementation Screenshot

1. Ensure the dev server is running
2. Use Playwright to navigate to the implemented page/component
3. Take a screenshot of the implementation

### 10.2 Compare Against Figma

Place the Figma screenshot (from Phase 2) and the implementation screenshot side by side. Perform a detailed comparison:

**Comparison checklist:**
- [ ] **Layout**: Spacing, alignment, sizing, positioning — identical?
- [ ] **Typography**: Font family, size, weight, line height, letter spacing, color — all matching?
- [ ] **Colors**: Background, text, border, shadow colors — exact hex/rgba match?
- [ ] **Borders & Radius**: Border width, style, color, corner radius — identical?
- [ ] **Shadows & Effects**: Box shadows, blurs, opacity — matching?
- [ ] **Icons & Assets**: Correct icons, correct sizing, correct color?
- [ ] **Component Structure**: All components present, correctly nested?
- [ ] **Interactive States**: Use Playwright to hover/click and verify states match design

### 10.3 Mock Data & Interactivity Review

Verify the implementation is demo-ready:

- [ ] **Mock data file exists** (`src/data/mockData.ts` or equivalent) with typed exports
- [ ] **No placeholder text**: No "lorem ipsum", "Item 1", "John Doe" repeated, or "TODO" content
- [ ] **Realistic data variety**: Lists have 5-15 items with diverse, domain-appropriate content
- [ ] **Numbers are plausible**: Metrics, counts, and percentages look realistic for the domain
- [ ] **Dates are relative**: Timestamps make sense relative to today's date
- [ ] **Interactive elements work**: Buttons, tabs, toggles, dropdowns respond to user interaction
- [ ] **State management**: UI state changes are reflected visually (active tab, selected item, open modal)
- [ ] **No dead clicks**: Every clickable element does something visible

### 10.4 Code Quality Review

Also review for:
- Mismatches between implementation and plan
- Mismatches between tests and test plan
- Correctness and logic issues
- Missing edge cases
- Accessibility (WCAG compliance)
- Component reuse (using existing components vs. creating duplicates)
- Design token usage vs. hardcoded values

### 10.5 Output Format

Numbered list of issues, each with severity: **critical**, **major**, **minor**, or **nit**.

- **Critical**: Visual difference visible at a glance, broken functionality, missing major component
- **Major**: Measurable deviation from Figma specs, missing state, accessibility failure
- **Minor**: Small spacing/color discrepancy, code quality issue
- **Nit**: Style preference, naming suggestion

Include the specific Figma value vs. implementation value for every visual discrepancy.

If no issues: respond "No issues found."

### 10.6 Fix Loop

When critical or major issues are found:
1. Capture the reviewer's findings as `{POST_IMPLEMENTATION_REVIEW_FINDINGS}`.
2. Save findings to a temp file.
3. Prepare the `executing` phase again via the phase wrapper using template `<skill-directory>/subagents/prompt-executing.md`, with `--set-file POST_IMPLEMENTATION_REVIEW_FINDINGS=<findings-temp-file>`.
4. Resume the persistent implementation subagent with the rendered prompt.
5. After the fix round, deploy a fresh reviewer to compare again.
6. Repeat until no critical or major issues remain, or 8 rounds completed.

If critical/major issues remain after 8 rounds:
1. Stop looping.
2. Dispatch a subagent to review past sessions and hypothesize why the loop is not converging.
3. Present that report and the latest review output to the user and await instructions.

### 10.7 Final Validation

Once no critical/major issues remain, perform a final comprehensive check with Playwright:

```
# Screenshot at default viewport
playwright_navigate(url="http://localhost:PORT/path")
playwright_screenshot()

# Test hover states
playwright_hover(selector="[interactive element]")
playwright_screenshot()

# Test responsive (if applicable)
playwright_resize(width=768, height=1024)
playwright_screenshot()

playwright_resize(width=375, height=812)
playwright_screenshot()
```

Compare each screenshot against the corresponding Figma frame. Only proceed when ALL viewports match.

---

## Phase 11: Finish

Once the review loop passes (no critical or major issues):

Read and follow `<skill-directory>/subskills/design-finishing/SKILL.md` to complete the implementation.

Report the process to the user using concrete facts and returned artifacts:
- How many plan-editor rounds
- How many review rounds
- The implementation summary and verification results
- The changed-file list
- Any residual minor/nit issues
- Final Playwright validation results (viewport screenshots)

Then present the user with options for what to do next (review in browser, make adjustments, or mark complete).

---

## Implementation Rules

### Pixel-Perfect Fidelity
- Every color must match the Figma value exactly
- Every spacing value must match exactly
- Typography must be identical: font family, size, weight, line height, letter spacing
- Border radius, shadows, and effects must match exactly
- When project conventions conflict with Figma specs, **the Figma design wins**

### Component Organization
- Place UI components in the project's designated directory
- Follow the project's component naming conventions
- Check for existing components before creating new ones (component-library-first)

### Design System Integration
- Map Figma design tokens to project design tokens
- Use existing components when they produce identical visual results
- Override project tokens with exact Figma values when they don't match
- Never hardcode values — extract to constants or design tokens

### Code Quality
- Use TypeScript for component props
- Follow project conventions for styling (CSS modules, Tailwind, styled-components, etc.)
- Semantic HTML elements (`nav`, `main`, `section`, `article`)
- WCAG accessibility standards

### Asset Handling
- Use localhost URLs from Figma MCP directly
- Do NOT add external icon packages
- Use SVG for icons, WebP for photos when available

---

## Examples

### Example 1: Implementing a Component

User says: "Implement this button: https://figma.com/design/abc123/DS?node-id=42-15 — it's a primary CTA button with hover and disabled states"

**Flow:**
1. Validate inputs → both provided
2. Fetch design context + screenshot from Figma MCP
3. Deep analysis: colors, typography, spacing, hover/active/disabled states
4. Confidence check → 98%+ → proceed
5. Testing strategy: Playwright screenshots at default viewport + hover/disabled states
6. Planning subagent creates implementation plan
7. Plan-editor validates plan (1-2 rounds)
8. Test plan: 4 Playwright comparisons (default, hover, active, disabled)
9. Implementation subagent builds the button
10. Playwright review loop: screenshots + comparison (iterate until identical)
11. Finish: report completion with viewport results

### Example 2: Implementing a Full Page

User says: "Build this dashboard: https://figma.com/design/xyz789/App?node-id=10-5 — it's the main analytics dashboard with sidebar nav, chart cards, and a data table"

**Flow:**
1. Validate inputs → both provided
2. Fetch metadata first (complex page), then child nodes individually + full-page screenshot
3. Deep analysis of every section: sidebar, header, cards, table
4. Confidence check — ask about data sources, routing, state management if unclear
5. Testing strategy: multi-viewport Playwright screenshots + interactive states + accessibility
6. Planning subagent creates phased plan (layout → sections → components → integration)
7. Plan-editor loop (2-3 rounds for complex pages)
8. Test plan: 12+ Playwright comparisons across viewports and states
9. Implementation subagent builds everything
10. Playwright review loop at multiple viewports, hover states, responsive behavior
11. Finish: report with process facts, present options
