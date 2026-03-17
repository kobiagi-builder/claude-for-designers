---
name: design-executing
description: Internal implement-figma-design subskill for executing Figma implementation plans — do not invoke directly.
---

## Executing Figma Implementation Plans

### Overview

Load the plan, create TodoWrite entries for all tasks, then execute every task sequentially without pausing. The plan has already been reviewed and approved — follow it exactly.

### Step 1: Load Plan

- Read the plan file completely
- Create a TodoWrite entry for every task in the plan
- Note the Figma design context and screenshot reference for visual verification

### Step 2: Execute All Tasks

For each task in sequence:
1. Mark as `in_progress`
2. Follow each step exactly as written in the plan
3. Use exact Figma values specified (colors, spacing, typography, shadows, radii)
4. Check for existing components before creating new ones
5. Run specified verifications
6. Mark as `completed`

Repeat until all tasks are done.

### Implementation Standards

**Visual fidelity is non-negotiable:**
- Use exact color values from the plan (hex/rgba from Figma data)
- Use exact spacing values (padding, margin, gap in pixels)
- Use exact typography values (font family, size, weight, line height, letter spacing)
- Use exact border-radius, shadow, and effect values
- When project tokens match Figma values, use tokens. When they don't, use exact Figma values.

**Component quality:**
- TypeScript types for all props
- Semantic HTML elements
- WCAG accessibility (alt text, ARIA labels, keyboard nav, focus indicators)
- Follow project naming and file organization conventions

**Asset handling:**
- Use localhost URLs from Figma MCP directly
- Do not add external icon packages
- SVG for icons, appropriate formats for images

**Mock data & interactivity (MANDATORY for demo-ready output):**
- Create `src/data/mockData.ts` as the first implementation task — all dynamic content lives here
- Export typed data with TypeScript interfaces
- Use realistic, diverse content: real-sounding names, plausible business numbers, relative dates
- Never use lorem ipsum, "Item 1/2/3", or repeated placeholder names
- Lists and tables need 5-15 items with varied statuses and content lengths
- All buttons, tabs, toggles, dropdowns, modals must have working click handlers
- Use React `useState` for all interactive state (active tab, open modal, toggle values, selected items)
- Search/filter inputs should filter the mock data list in real-time
- No element that looks clickable should be a dead click — every interactive element must produce visible feedback

### Blocker Definition

Two states exist: **execute** or **stop for a blocker**.

A blocker occurs when the agent cannot use its best judgment because there is no path forward, or because being wrong could cause harm.

Examples of blockers:
- Missing Figma MCP access (can't download required assets)
- Project build is broken in a way unrelated to the implementation
- Critical dependency is missing and installing it could break other things

NOT blockers:
- Uncertainty about the best approach (follow the plan)
- A design choice you disagree with (follow the Figma design)
- Missing edge case handling (implement what's specified, note the gap)

### Remember

- Follow plan steps exactly
- Don't skip verifications
- Use exact Figma values — never approximate
- Stop only for genuine blockers
- When in doubt, match the Figma design
