# Prep Environment Agent

Extract and document a user's design system and styleguide from Figma into reusable rule files that all other skills reference.

## Purpose

This agent creates two rule files that serve as the single source of truth for the user's visual language:

- `.claude/rules/design-system.md` — Colors, typography, spacing, border radius, shadows, and design tokens
- `.claude/rules/styleguide.md` — Component specifications, patterns, interaction states, layout conventions, and usage guidelines

Once these files exist, every skill in the project (implement-figma-design, create-concepts, fix-differences, design-feedback) uses them automatically — no repeated extraction, no inconsistency.

## When This Agent Is Called

This agent is invoked automatically by other skills when they detect that `.claude/rules/design-system.md` or `.claude/rules/styleguide.md` do not exist. It can also be called directly by the user.

## Prerequisites

- **Figma MCP** must be connected (the agent fetches design data from Figma)

---

## Workflow

### Step 1: Ask for Figma Links

Ask the user for two Figma links:

> "To set up your design environment, I need two Figma links:
>
> 1. **Design system** — The page/frame with your color palette, typography scale, spacing tokens, shadows, border radii, and any defined variables or styles.
> 2. **Styleguide / Component library** — The page/frame with your component specs: buttons, inputs, cards, modals, navigation, etc.
>
> These can be from the same file or different files. Paste the links and I'll extract everything."

If the user only has one link (combined design system + styleguide), use it for both. If they don't have a formal design system, ask them to share 3-5 representative screens from their product and extract the patterns from those.

### Step 2: Fetch Design Data from Figma

For each link provided:

1. Extract the file key and node ID from the URL
2. Use `mcp__figma__get_figma_data` to fetch the full design data for the target node
3. Use `mcp__figma__download_figma_images` to get a visual screenshot for reference
4. If the node is large, use metadata first to identify child sections, then fetch each individually

### Step 3: Analyze and Extract — Design System

From the design system Figma data, extract every token and value. Be exhaustive — missing a single color or font weight means future implementations will deviate.

#### What to extract:

**Colors** (extract every named color or style):
- Primary, secondary, accent colors (all shades/tints if they exist)
- Neutral/gray scale
- Background colors (page, surface, card, overlay)
- Text colors (primary, secondary, disabled, inverse)
- Border colors
- Semantic colors (error, warning, success, info) with all variants
- Gradient definitions (direction, stops, colors)
- Opacity values used in the system

**Typography** (extract every text style):
- Font families (primary, secondary, monospace if used)
- Font weight scale (which weights are used)
- Type scale: for each level (h1-h6, body, caption, label, overline, etc.):
  - Font size (px)
  - Line height (px or multiplier)
  - Letter spacing (em or px)
  - Font weight
  - Text transform (if any)
- Paragraph spacing

**Spacing**:
- Base unit (typically 4px or 8px)
- Complete spacing scale with named tokens
- Common padding patterns (card padding, section padding, input padding)
- Common gap patterns (between elements, between sections)

**Border Radius**:
- Complete radius scale with named tokens
- Component-specific radii (button, card, input, modal, avatar, chip)

**Shadows/Elevation**:
- Each elevation level with exact values (x-offset, y-offset, blur, spread, color)
- Named shadow tokens (sm, md, lg, xl, or elevation-1 through elevation-5)

**Other tokens**:
- Border widths
- Transition/animation durations and easing curves (if defined)
- Z-index scale (if defined)
- Breakpoints (if defined)
- Icon sizes

### Step 4: Analyze and Extract — Styleguide

From the styleguide/component library Figma data, document every component specification.

#### What to extract per component:

For each component (buttons, inputs, selects, checkboxes, radio buttons, toggles, cards, modals/dialogs, navigation/tabs, badges/chips, tooltips, alerts/toasts, avatars, tables, pagination, breadcrumbs, dropdowns, and any others present):

- **Variants**: Every variant (primary, secondary, ghost, destructive, outline, etc.)
- **Sizes**: Every size variant (xs, sm, md, lg, xl)
- **States**: Default, hover, active/pressed, focus, disabled, loading, error
- **Anatomy**: What elements make up the component (icon + label + arrow, etc.)
- **Spacing**: Internal padding, gap between elements
- **Colors**: Background, text, border, icon colors for each variant and state
- **Typography**: Which text style is used
- **Border**: Width, style, color, radius
- **Shadow**: Which elevation token is used
- **Icons**: Size, color, position relative to text
- **Responsive behavior**: How the component adapts (if specified)

#### Layout patterns to document:

- Page layout structure (sidebar + content, top nav + content, etc.)
- Grid system (columns, gutters, margins)
- Card layout patterns
- Form layout patterns (label position, error message placement)
- List/table patterns
- Modal/dialog sizes and positioning
- Navigation patterns (sidebar, top bar, bottom bar, breadcrumbs)

#### Interaction patterns:

- Hover behaviors (what changes on hover — color, shadow, scale)
- Focus ring style (color, offset, width)
- Active/pressed feedback
- Loading indicators (spinner style, skeleton screens, shimmer)
- Transition conventions (duration, easing)
- Tooltip trigger behavior (hover delay, position preference)

### Step 5: Write design-system.md

Write the extracted design system to `.claude/rules/design-system.md` using this structure:

```markdown
# Design System

Extracted from Figma on [date]. Source: [Figma URL]

## Colors

### Primary
- primary-50: #XXXXXX
- primary-100: #XXXXXX
- ...
- primary-900: #XXXXXX

### Secondary
[same pattern]

### Neutrals
[full gray scale]

### Semantic
- error: #XXXXXX
- error-light: #XXXXXX
- warning: #XXXXXX
- success: #XXXXXX
- info: #XXXXXX

### Background
- page: #XXXXXX
- surface: #XXXXXX
- card: #XXXXXX
- overlay: rgba(...)

### Text
- primary: #XXXXXX
- secondary: #XXXXXX
- disabled: #XXXXXX
- inverse: #XXXXXX

### Border
- default: #XXXXXX
- subtle: #XXXXXX
- strong: #XXXXXX

## Typography

### Font Families
- Primary: [name]
- Secondary: [name] (if applicable)
- Mono: [name] (if applicable)

### Type Scale
| Token | Size | Weight | Line Height | Letter Spacing |
|-------|------|--------|-------------|----------------|
| h1 | XXpx | 700 | XXpx | -0.02em |
| h2 | XXpx | 600 | XXpx | -0.01em |
| ... | ... | ... | ... | ... |
| body-lg | XXpx | 400 | XXpx | 0em |
| body | XXpx | 400 | XXpx | 0em |
| body-sm | XXpx | 400 | XXpx | 0em |
| caption | XXpx | 400 | XXpx | 0.01em |
| label | XXpx | 500 | XXpx | 0.02em |

## Spacing

Base unit: Xpx

| Token | Value |
|-------|-------|
| spacing-1 | Xpx |
| spacing-2 | Xpx |
| ... | ... |

## Border Radius

| Token | Value |
|-------|-------|
| radius-sm | Xpx |
| radius-md | Xpx |
| radius-lg | Xpx |
| radius-full | 9999px |

## Shadows

| Token | Value |
|-------|-------|
| shadow-sm | 0px Xpx Xpx rgba(...) |
| shadow-md | 0px Xpx Xpx rgba(...) |
| shadow-lg | 0px Xpx Xpx rgba(...) |

## Border

| Token | Value |
|-------|-------|
| border-width-default | Xpx |
| border-width-thick | Xpx |
```

### Step 6: Write styleguide.md

Write the extracted styleguide to `.claude/rules/styleguide.md` using this structure:

```markdown
# Styleguide

Extracted from Figma on [date]. Source: [Figma URL]

## Components

### Button

**Variants**: primary, secondary, outline, ghost, destructive
**Sizes**: sm (32px), md (40px), lg (48px)

| Variant | Background | Text | Border | Hover BG | Hover Text |
|---------|-----------|------|--------|----------|------------|
| primary | #XXXX | #XXXX | none | #XXXX | #XXXX |
| secondary | #XXXX | #XXXX | #XXXX | #XXXX | #XXXX |
| ... | ... | ... | ... | ... | ... |

- Border radius: radius-md
- Font: label (14px/500)
- Padding: 8px 16px (sm), 10px 20px (md), 12px 24px (lg)
- Icon size: 16px (sm), 20px (md), 24px (lg)
- Focus ring: 2px offset, primary-200
- Disabled: 50% opacity, cursor not-allowed
- Loading: spinner replaces icon, text dims to 60% opacity

### Input
[same detailed format]

### Card
[same detailed format]

[...every component...]

## Layout Patterns

### Page Layout
[grid, sidebar, content areas]

### Form Layout
[label position, spacing, error placement]

## Interaction Patterns

### Hover
[what changes, transition duration]

### Focus
[ring style, color]

### Transitions
[default duration, easing]
```

### Step 7: Confirm Completion

Tell the user:

> "Design environment is ready. I've created two rule files:
>
> - `.claude/rules/design-system.md` — [X] colors, [X] typography styles, [X] spacing tokens, [X] shadows, [X] border radii
> - `.claude/rules/styleguide.md` — [X] components documented with all variants, sizes, states, and interaction patterns
>
> All design skills will now use these files automatically when implementing, reviewing, or creating concepts."

### Step 8: Clean Up Old Rules

If `.claude/rules/design-system-tokens.md` exists (the old format), ask the user:

> "I found an older `design-system-tokens.md` file. The new `design-system.md` and `styleguide.md` are more comprehensive. Should I remove the old file?"

Remove it if the user agrees.

---

## Quality Checklist

Before marking the extraction as complete, verify:

- [ ] Every color visible in the Figma design system is documented with its exact hex/rgba value
- [ ] Every text style has font family, size, weight, line height, and letter spacing
- [ ] The spacing scale is complete (no gaps)
- [ ] Every component has all its variants, sizes, and states documented
- [ ] Hover, focus, active, and disabled states are specified for interactive components
- [ ] Shadow and border radius values are exact (not approximated)
- [ ] Both files use consistent formatting and are easy to scan

## Handling Edge Cases

**User has no formal design system**: Extract patterns from 3-5 representative screens. Document what you observe as the de facto design system. Note which values are inferred vs. explicitly defined.

**Design system is spread across multiple Figma files**: Fetch from each file. Merge into the same two output files. Note the source file for each section.

**Conflicting values**: If the same component appears with different values in different places, document the most common/recent version and flag the inconsistency to the user.

**Very large design system**: If the Figma data is too large for a single fetch, use `get_metadata` first to identify sections, then fetch each section individually. The output files can be as long as needed — thoroughness is more important than brevity.
