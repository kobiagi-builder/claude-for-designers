---
name: fix-differences
description: Pixel-by-pixel visual comparison between a live UI and its Figma design, with automatic fixing of all differences. Use this skill when the user wants to compare their implementation against a Figma design, fix visual discrepancies, check fidelity, or says things like "fix differences", "compare to Figma", "match the design", "it doesn't look right", "check against Figma", "visual diff", "pixel perfect", or "compare my implementation". Also trigger when the user has just finished implementing a Figma design and wants to verify accuracy. Requires Figma MCP and Playwright MCP connections.
---

# Fix Differences

Compare a live UI implementation against its Figma source design, document every visual difference down to the pixel, fix them all, and repeat until the implementation is indistinguishable from the design.

## Prerequisites

- **Figma MCP** connected (for design data and screenshots)
- **Playwright MCP** connected (for UI screenshots)
- A running dev server with the UI accessible in a browser

## The Loop

This skill runs a tight compare-fix loop. Each pass through the loop brings the implementation closer to the design. The loop exits only when there are zero differences.

```
┌─────────────────────────────────┐
│  Step 1: Capture Screenshots    │
│  (UI via Playwright + Figma)    │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  Step 2: Compare & Document     │
│  (pixel-by-pixel diff report)   │
│                                 │
│  0 differences? ──► EXIT ✓      │
└──────────────┬──────────────────┘
               │ differences found
               ▼
┌─────────────────────────────────┐
│  Step 3: Fix All Differences    │
│  (use exact Figma values)       │
└──────────────┬──────────────────┘
               │
               ▼
         Back to Step 1
```

---

## Before Starting: Identify the Figma Target

Before entering the loop, you need to know exactly which Figma screen or node to compare against.

**If the Figma URL is available** (from conversation context, recent implementation, or user message), use it directly. Extract the file key and node ID from the URL.

**If it's ambiguous** — multiple possible screens, no URL in context, or unclear which part of a file to compare — **ask the user directly**. Don't guess. Say something like:

> "Which Figma screen should I compare against? Please paste the Figma URL or tell me which screen/component to use."

Also confirm which page or route in the running app to screenshot. If there's only one obvious page, proceed without asking.

---

## Step 1: Capture Screenshots

Take both screenshots at the same viewport width for a fair comparison.

### 1a. Screenshot the live UI

Use Playwright to navigate to the page and capture a full-page screenshot:

1. Navigate to the page URL (e.g., `http://localhost:3000/`)
2. Wait for the page to fully load (network idle, animations settled)
3. Take a screenshot at the primary viewport (default: **1440px wide**)
4. If the design has responsive variants, also capture at **768px** and **375px**

### 1b. Screenshot the Figma design

Use the Figma MCP to get the design screenshot:

1. `mcp__figma__get_figma_data` — fetch the full design data for the target node (you need this for exact values in Step 3)
2. `mcp__figma__download_figma_images` — download a screenshot/render of the target node

Keep the Figma design data loaded — you'll need the exact values (colors, spacing, typography, shadows, radii) when fixing differences in Step 3.

---

## Step 2: Compare & Document Differences

Place the Figma screenshot and the UI screenshot side by side (visually, in your analysis) and examine every region of the design systematically. Work through the screenshots section by section — top to bottom, left to right — so nothing is missed.

### What to compare

Check **every** visual property. The goal is completeness — even a 1px difference counts.

| Category | What to look for |
|---|---|
| **Layout & spacing** | Padding, margins, gaps between elements, overall dimensions, element positioning |
| **Colors** | Background colors, text colors, border colors, icon colors, gradient values, opacity |
| **Typography** | Font family, font size, font weight, line height, letter spacing, text alignment, text color |
| **Borders & radius** | Border width, border color, border style, corner radius (all four corners) |
| **Shadows & effects** | Box shadows (offset, blur, spread, color), backdrop blur, overlays |
| **Sizing** | Element widths, heights, aspect ratios, icon sizes |
| **Alignment** | Horizontal/vertical centering, text alignment, element alignment within containers |
| **Content** | Missing elements, extra elements, different text content, different icons |
| **States** | Default states matching (hover/active states are secondary) |
| **Images & icons** | Correct assets, correct sizing, correct positioning |

### Document the differences

Create a structured differences report. Every difference gets an entry, no matter how small.

**Format each difference as:**
```
[PRIORITY] Category — Description
- Element: [which element]
- Figma value: [exact value from design data]
- Current value: [what the implementation has]
- Location: [where on the page]
```

**Priority levels:**
- **CRITICAL** — Missing or completely wrong elements, major layout breaks, wrong page structure
- **MAJOR** — Wrong colors, wrong typography, significant spacing errors (>4px off)
- **MINOR** — Small spacing differences (1-4px), subtle color variations, minor radius differences

### Zero differences = done

If after thorough comparison there are genuinely zero differences — the implementation is pixel-perfect — report this to the user and exit. Don't invent differences that aren't there.

> "Comparison complete — 0 differences found. The implementation matches the Figma design."

---

## Step 3: Fix All Differences

Work through the differences report and fix every single one. Use the exact values from the Figma design data (fetched in Step 1b).

### Fixing rules

- **Use exact Figma values.** Don't approximate. If Figma says `#1A1A2E`, use `#1A1A2E`, not `#1B1B2F`.
- **Check design tokens first.** If the project has design tokens (Tailwind config, CSS variables, token files), use the token when it matches the Figma value exactly. If no token matches, use the raw Figma value.
- **Fix in priority order.** Critical first, then major, then minor. This way if you need to stop early, the biggest issues are already resolved.
- **Don't introduce new problems.** When fixing one element, make sure you're not breaking adjacent elements. Be surgical.
- **Preserve functionality.** Only change visual properties. Don't alter component logic, event handlers, or data flow.

### After fixing all differences

Go back to **Step 1**. Take fresh screenshots and compare again. Fixes can sometimes shift other elements or reveal differences that were previously obscured.

---

## Loop Limits

To avoid infinite loops in edge cases:

- **Maximum 5 passes** through the loop. If differences persist after 5 rounds, report the remaining differences to the user and ask how they'd like to proceed.
- **If the same difference keeps reappearing** after being fixed (oscillating fix), flag it to the user — there may be a CSS specificity issue, a dynamic style, or a constraint conflict that needs manual resolution.

---

## Multi-Viewport Comparison (When Relevant)

If the Figma design has responsive variants or the implementation is responsive:

1. Run the full loop at the **primary viewport** (1440px) first
2. Once that's pixel-perfect, run comparison passes at **768px** and **375px**
3. Document viewport-specific differences separately

Only do multi-viewport if the design clearly has responsive breakpoints. Don't test mobile if the design is desktop-only.

---

## Example Output

After each comparison pass, present results like this:

**Pass 1 — 7 differences found:**

```
[CRITICAL] Content — Navigation logo is missing
- Element: Header logo
- Figma value: Logo image present, 120x32px
- Current value: No logo rendered
- Location: Top-left header

[MAJOR] Color — Hero section background is wrong
- Element: Hero container
- Figma value: #1A1A2E
- Current value: #000000
- Location: Main hero section

[MAJOR] Typography — Heading font weight is too light
- Element: h1 "Welcome back"
- Figma value: 700 (bold)
- Current value: 400 (regular)
- Location: Hero section heading

[MINOR] Spacing — Card gap is 2px too wide
- Element: Feature cards container
- Figma value: gap 24px
- Current value: gap 26px (Tailwind gap-6.5 computed)
- Location: Features grid
```

Then fix all 7 and re-run. Continue until 0 differences.
