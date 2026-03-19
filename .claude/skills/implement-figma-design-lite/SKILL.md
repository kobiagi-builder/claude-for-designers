---
name: "implement-figma-design-lite"
description: "Translate Figma nodes into production-ready code with 1:1 visual fidelity using the Figma MCP workflow (design context, screenshots, assets, and project-convention translation). Trigger when the user provides Figma URLs or node IDs, or asks to implement designs or components that must match Figma specs. Requires a working Figma MCP server connection."
---


# Implement Design

## Overview

This skill provides a structured workflow for translating Figma designs into production-ready code with pixel-perfect accuracy. It ensures consistent integration with the Figma MCP server, proper use of design tokens, and 1:1 visual parity with designs.

## Prerequisites

- **Design system rules must exist.** Before doing anything else, check if `.claude/rules/design-system.md` and `.claude/rules/styleguide.md` exist. If either file is missing, invoke the `prep-environment` agent (`.claude/agents/prep-environment/AGENT.md`) and wait for it to complete before proceeding. These files contain the user's design tokens, component specs, and interaction patterns — they are essential for accurate implementation.
- Figma MCP server must be connected and accessible
- User must provide a Figma URL in the format: `https://figma.com/design/:fileKey/:fileName?node-id=1-2`
  - `:fileKey` is the file key
  - `1-2` is the node ID (the specific component or frame to implement)
- **OR** when using `figma-desktop` MCP: User can select a node directly in the Figma desktop app (no URL required)
- Project should have an established design system or component library (preferred)

## Required Workflow

**Follow these steps in order. Do not skip steps.**

### Step 0a: Set up Figma MCP (if not already configured)

If any MCP call fails because Figma MCP is not connected, pause and set it up:

1. Add the Figma MCP:
   - `codex mcp add figma --url https://mcp.figma.com/mcp`
2. Enable remote MCP client:
   - Set `[features].rmcp_client = true` in `config.toml` **or** run `codex --enable rmcp_client`
3. Log in with OAuth:
   - `codex mcp login figma`

After successful login, the user will have to restart codex. You should finish your answer and tell them so when they try again they can continue with Step 1.

### Step 0b: Set up shadcn/ui (if not already installed)

Check if shadcn/ui is configured in the project. If not, install and configure it:

1. **Detect project framework** (Next.js, Vite, Remix, etc.)
2. **Check for existing shadcn config**: Look for `components.json` in the project root
3. **If not installed**, run the init command:
   ```bash
   npx shadcn@latest init
   ```
4. **Configure during init**:
   - Select the appropriate style (default/new-york)
   - Set the base color to match the Figma design system
   - Configure the CSS variables option (recommended: yes)
   - Set the components alias path (e.g., `@/components/ui`)
5. **Install required shadcn components** based on what the Figma design uses (buttons, cards, inputs, dialogs, etc.):
   ```bash
   npx shadcn@latest add button card input dialog
   ```
6. **If already installed**, verify the configuration is compatible and install any missing components needed for the current design.

**Skip this step** only if the user explicitly states they don't want shadcn/ui.

### Step 1: Get Node ID

#### Option A: Parse from Figma URL

When the user provides a Figma URL, extract the file key and node ID to pass as arguments to MCP tools.

**URL format:** `https://figma.com/design/:fileKey/:fileName?node-id=1-2`

**Extract:**

- **File key:** `:fileKey` (the segment after `/design/`)
- **Node ID:** `1-2` (the value of the `node-id` query parameter)

**Note:** When using the local desktop MCP (`figma-desktop`), `fileKey` is not passed as a parameter to tool calls. The server automatically uses the currently open file, so only `nodeId` is needed.

**Example:**

- URL: `https://figma.com/design/kL9xQn2VwM8pYrTb4ZcHjF/DesignSystem?node-id=42-15`
- File key: `kL9xQn2VwM8pYrTb4ZcHjF`
- Node ID: `42-15`

#### Option B: Use Current Selection from Figma Desktop App (figma-desktop MCP only)

When using the `figma-desktop` MCP and the user has NOT provided a URL, the tools automatically use the currently selected node from the open Figma file in the desktop app.

**Note:** Selection-based prompting only works with the `figma-desktop` MCP server. The remote server requires a link to a frame or layer to extract context. The user must have the Figma desktop app open with a node selected.

### Step 2: Fetch Design Context

Run `get_design_context` with the extracted file key and node ID.

```
get_design_context(fileKey=":fileKey", nodeId="1-2")
```

This provides the structured data including:

- Layout properties (Auto Layout, constraints, sizing)
- Typography specifications
- Color values and design tokens
- Component structure and variants
- Spacing and padding values

**If the response is too large or truncated:**

1. Run `get_metadata(fileKey=":fileKey", nodeId="1-2")` to get the high-level node map
2. Identify the specific child nodes needed from the metadata
3. Fetch individual child nodes with `get_design_context(fileKey=":fileKey", nodeId=":childNodeId")`

### Step 3: Capture Visual Reference

Run `get_screenshot` with the same file key and node ID for a visual reference.

```
get_screenshot(fileKey=":fileKey", nodeId="1-2")
```

This screenshot serves as the source of truth for visual validation. Keep it accessible throughout implementation.

### Step 4: Deep Design Analysis

Before writing any code, perform a thorough analysis of the design to ensure complete understanding. This step is inspired by the ideation skill's confidence-gated analysis approach.

#### 4.1 Structural Analysis

Break down the design into its complete anatomy:

1. **Component Hierarchy**: Map every component, its nesting, and relationships (parent/child/sibling)
2. **Layout System**: Identify the grid structure, flex directions, gaps, and how sections relate spatially
3. **Spacing Map**: Document all padding, margins, and gaps — both within and between components
4. **Responsive Breakpoints**: Identify any constraints or behaviors that suggest responsive rules

#### 4.2 Visual Properties Extraction

For every unique element, extract:

- **Typography**: Font family, size, weight, line height, letter spacing, text color, text alignment
- **Colors**: Background colors, border colors, text colors, gradients, opacity values
- **Effects**: Shadows (box-shadow values), blurs, overlays
- **Borders**: Width, style, color, radius (per corner if different)
- **Sizing**: Fixed vs. auto vs. fill, min/max constraints, aspect ratios

#### 4.3 Interaction & State Analysis

Identify all interactive elements and their states:

- **Hover states**: Color changes, shadows, transforms, cursor
- **Active/pressed states**: Visual feedback on click
- **Focus states**: Outlines, rings for accessibility
- **Disabled states**: Opacity, color changes, cursor
- **Loading states**: Spinners, skeletons, shimmer effects
- **Empty states**: What shows when there's no data

#### 4.4 Content & Data Patterns

- **Static vs. dynamic content**: Which text is hardcoded, which comes from data
- **Lists & repetition**: Identify repeating patterns and how they scale (1 item, 10 items, 100 items)
- **Edge cases**: Long text truncation, missing images, empty states

#### 4.5 Confidence Check

Before proceeding, score your understanding (0-100):

| Dimension | Question |
|-----------|----------|
| Component Structure | Can I name every component and its props? |
| Layout Accuracy | Can I reproduce the exact spacing and alignment? |
| Visual Fidelity | Do I know every color, font, shadow, and radius? |
| Interaction Coverage | Do I know all states and transitions? |
| Edge Cases | Have I considered what happens with varying content? |

**If confidence < 98%**: ask the user clarifing questions using askUserQuestions tool. Do NOT proceed until confidence >= 98%.

### Step 5: Download Required Assets

Download any assets (images, icons, SVGs) returned by the Figma MCP server.

**IMPORTANT:** Follow these asset rules:

- If the Figma MCP server returns a `localhost` source for an image or SVG, use that source directly
- DO NOT import or add new icon packages - all assets should come from the Figma payload
- DO NOT use or create placeholders if a `localhost` source is provided
- Assets are served through the Figma MCP server's built-in assets endpoint

### Step 6: Translate to Project Conventions (Identical Fidelity Required)

Translate the Figma output into this project's framework, styles, and conventions.

**CRITICAL REQUIREMENT: The implementation MUST look exactly like the Figma mockup. Components, colors, spacing, typography, behavior — everything must be identical. This is non-negotiable.**

**Key principles:**

- Treat the Figma MCP output (typically React + Tailwind) as a representation of design and behavior, not as final code style
- Replace Tailwind utility classes with the project's preferred utilities or design system tokens
- Reuse existing components (buttons, inputs, typography, icon wrappers) instead of duplicating functionality — but ONLY if they produce an identical visual result to the Figma design
- Use the project's color system, typography scale, and spacing tokens — but override them with exact Figma values when they don't produce an identical match
- Respect existing routing, state management, and data-fetch patterns
- **When conflicts arise between project conventions and Figma specs, the Figma design wins.** The implementation must be visually indistinguishable from the mockup.

### Step 7: Achieve 1:1 Visual Parity

The implementation must be a pixel-perfect replica of the Figma design.

**Requirements:**

- Every color must match the Figma value exactly (use the hex/rgba from the design context)
- Every spacing value (padding, margin, gap) must match exactly
- Typography must be identical: font family, size, weight, line height, letter spacing
- Border radius, shadows, and effects must match exactly
- Component behavior (hover, active, disabled states) must match the design
- Follow WCAG requirements for accessibility
- Add component documentation as needed

### Step 8: Validate Against Figma with Playwright (Iterative)

Use Playwright to take a screenshot of the implementation and compare it against the Figma screenshot from Step 3. **Iterate until there is a complete visual and behavioral match.**

#### 8.1 Take Implementation Screenshot

1. Ensure the dev server is running
2. Use Playwright to navigate to the implemented page/component:
   ```
   playwright_navigate(url="http://localhost:PORT/path")
   ```
3. Take a screenshot of the implementation:
   ```
   playwright_screenshot()
   ```

#### 8.2 Compare Against Figma

Place the Figma screenshot (from Step 3) and the implementation screenshot side by side. Perform a detailed comparison:

**Comparison checklist:**

- [ ] **Layout**: Spacing, alignment, sizing, positioning — are they identical?
- [ ] **Typography**: Font family, size, weight, line height, letter spacing, color — all matching?
- [ ] **Colors**: Background, text, border, shadow colors — exact hex/rgba match?
- [ ] **Borders & Radius**: Border width, style, color, corner radius — identical?
- [ ] **Shadows & Effects**: Box shadows, blurs, opacity — matching?
- [ ] **Icons & Assets**: Correct icons, correct sizing, correct color?
- [ ] **Component Structure**: All components present, correctly nested?
- [ ] **Interactive States**: Use Playwright to hover/click elements and verify hover, active, focus, disabled states match the design

#### 8.3 List All Differences

Create an explicit list of every difference found, no matter how small:

```
DIFFERENCES FOUND:
1. [Component] - [Property]: Expected [Figma value], Got [Implementation value]
2. [Component] - [Property]: Expected [Figma value], Got [Implementation value]
...
```

**If no differences found**: Proceed to mark as complete.

#### 8.4 Fix and Iterate

For each difference found:

1. Fix the code to match the Figma design exactly
2. Re-take the Playwright screenshot
3. Re-compare against the Figma screenshot
4. Repeat until zero differences remain

**Do NOT mark the implementation as complete until:**
- [ ] Playwright screenshot is visually indistinguishable from the Figma screenshot
- [ ] All interactive states have been tested with Playwright (hover, click, focus)
- [ ] Responsive behavior matches Figma constraints (test multiple viewport sizes if applicable)
- [ ] Accessibility standards met (WCAG)

#### 8.5 Final Validation Commands

Use Playwright to perform a final comprehensive check:

```
# Screenshot at default viewport
playwright_screenshot()

# Test hover states
playwright_hover(selector="[button/link/interactive element]")
playwright_screenshot()

# Test responsive (if applicable)
playwright_resize(width=768, height=1024)
playwright_screenshot()

playwright_resize(width=375, height=812)
playwright_screenshot()
```

Compare each screenshot against the corresponding Figma frame. Only proceed when ALL viewports match.

## Implementation Rules

### Component Organization

- Place UI components in the project's designated design system directory
- Follow the project's component naming conventions
- Avoid inline styles unless truly necessary for dynamic values

### Design System Integration

- **Read `.claude/rules/design-system.md`** for all color, typography, spacing, shadow, and radius values. Use these tokens instead of hardcoding values from Figma.
- **Read `.claude/rules/styleguide.md`** for component specifications. When implementing a button, input, card, or any documented component, match the variants, sizes, states, and interaction patterns defined in the styleguide.
- ALWAYS use components from the project's design system when possible
- Map Figma design tokens to project design tokens
- When a matching component exists, extend it rather than creating a new one
- Document any new components added to the design system

### Code Quality

- Avoid hardcoded values - extract to constants or design tokens
- Keep components composable and reusable
- Add TypeScript types for component props
- Include JSDoc comments for exported components

## Examples

### Example 1: Implementing a Button Component

User says: "Implement this Figma button component: https://figma.com/design/kL9xQn2VwM8pYrTb4ZcHjF/DesignSystem?node-id=42-15"

**Actions:**

1. Ensure shadcn/ui is installed; add `button` component if needed
2. Parse URL to extract fileKey=`kL9xQn2VwM8pYrTb4ZcHjF` and nodeId=`42-15`
3. Run `get_design_context(fileKey="kL9xQn2VwM8pYrTb4ZcHjF", nodeId="42-15")`
4. Run `get_screenshot(fileKey="kL9xQn2VwM8pYrTb4ZcHjF", nodeId="42-15")` for visual reference
5. Deep design analysis: extract all colors, typography, spacing, hover/active/disabled states
6. Download any button icons from the assets endpoint
7. Implement button component — must look identical to Figma (colors, radius, shadows, states)
8. Use Playwright to screenshot the button, compare against Figma, fix any differences, iterate until identical

**Result:** Button component matching Figma design, integrated with project design system.

### Example 2: Building a Dashboard Layout

User says: "Build this dashboard: https://figma.com/design/pR8mNv5KqXzGwY2JtCfL4D/Dashboard?node-id=10-5"

**Actions:**

1. Ensure shadcn/ui is installed; add needed components (card, table, etc.)
2. Parse URL to extract fileKey=`pR8mNv5KqXzGwY2JtCfL4D` and nodeId=`10-5`
3. Run `get_metadata(fileKey="pR8mNv5KqXzGwY2JtCfL4D", nodeId="10-5")` to understand the page structure
4. Identify main sections from metadata (header, sidebar, content area, cards) and their child node IDs
5. Run `get_design_context(fileKey="pR8mNv5KqXzGwY2JtCfL4D", nodeId=":childNodeId")` for each major section
6. Run `get_screenshot(fileKey="pR8mNv5KqXzGwY2JtCfL4D", nodeId="10-5")` for the full page
7. Deep design analysis: map every component, color, spacing value, and interaction state
8. Download all assets (logos, icons, charts)
9. Build layout — must be identical to Figma (spacing, alignment, proportions)
10. Use Playwright to screenshot at multiple viewports, compare against Figma, fix differences, iterate until identical

**Result:** Complete dashboard matching Figma design with responsive layout.

## Best Practices

### Always Start with Context

Never implement based on assumptions. Always fetch `get_design_context` and `get_screenshot` first.

### Incremental Validation

Validate frequently during implementation, not just at the end. This catches issues early.

### Document Deviations

If you must deviate from the Figma design (e.g., for accessibility or technical constraints), document why in code comments.

### Reuse Over Recreation

Always check for existing components before creating new ones. Consistency across the codebase is more important than exact Figma replication.

### Design System First

When in doubt, prefer the project's design system patterns over literal Figma translation.

## Common Issues and Solutions

### Issue: Figma output is truncated

**Cause:** The design is too complex or has too many nested layers to return in a single response.
**Solution:** Use `get_metadata` to get the node structure, then fetch specific nodes individually with `get_design_context`.

### Issue: Design doesn't match after implementation

**Cause:** Visual discrepancies between the implemented code and the original Figma design.
**Solution:** Use Playwright to take a screenshot of the implementation (Step 8). Compare side-by-side with the Figma screenshot from Step 3. List every difference explicitly. Fix each one, re-screenshot, and iterate until the implementation is visually identical to the Figma design.

### Issue: Assets not loading

**Cause:** The Figma MCP server's assets endpoint is not accessible or the URLs are being modified.
**Solution:** Verify the Figma MCP server's assets endpoint is accessible. The server serves assets at `localhost` URLs. Use these directly without modification.

### Issue: Design token values differ from Figma

**Cause:** The project's design system tokens have different values than those specified in the Figma design.
**Solution:** When project tokens differ from Figma values, prefer project tokens for consistency but adjust spacing/sizing to maintain visual fidelity.

## Understanding Design Implementation

The Figma implementation workflow establishes a reliable process for translating designs to code:

**For designers:** Confidence that implementations will match their designs with pixel-perfect accuracy.
**For developers:** A structured approach that eliminates guesswork and reduces back-and-forth revisions.
**For teams:** Consistent, high-quality implementations that maintain design system integrity.

By following this workflow, you ensure that every Figma design is implemented with the same level of care and attention to detail.

## Additional Resources

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Figma MCP Server Tools and Prompts](https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/)
- [Figma Variables and Design Tokens](https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma)
