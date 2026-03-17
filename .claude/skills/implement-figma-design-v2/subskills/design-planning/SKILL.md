---
name: design-planning
description: Internal implement-figma-design subskill for writing Figma implementation plans — do not invoke directly.
---

## Writing Figma Implementation Plans

### Audience

Plans are written for a skilled developer who has no context about this specific Figma design or codebase. The plan must contain every detail needed to produce a pixel-perfect implementation without backtracking.

### Core Principles

- **Figma is the source of truth**: Every visual property comes from the Figma design data, never approximated
- **Design tokens first**: Map Figma values to project tokens, override where they don't match
- **Component reuse**: Check existing components before creating new ones
- **Bite-sized tasks**: Each task is 2-5 minutes, with a single clear action and verification step
- **TDD where applicable**: For logic-heavy components, write failing tests first

### Plan Structure

#### Header

Every plan starts with:
- **Goal**: What the implementation achieves (reference Figma node)
- **Figma source**: File key, node ID, screenshot reference
- **Architecture**: Component structure and nesting
- **Tech stack**: Framework, styling approach, component library

#### Component Map

List every component to create or modify:
```
Files to create:
- src/components/feature/ComponentName.tsx — Description
- src/components/feature/SubComponent.tsx — Description

Files to modify:
- src/pages/PageName.tsx — Add new component import and usage
- src/styles/tokens.ts — Add new color tokens if needed
```

Organize by responsibility, not technical layer.

#### Design Token Mapping

For every unique value in the design:
```
| Figma Value | Project Token | Action |
|-------------|--------------|--------|
| #1A1A2E     | colors.primary.900 | Use token |
| #F4F4F5     | (no match)   | Add new token or use exact value |
| 16px gap    | spacing.4    | Use token |
| 24px radius | (no match)   | Use exact value |
```

#### Task Breakdown

Each task follows this structure:
```
### Task N: [Clear description]

**Action**: [Single clear action]

**Figma values**:
- Background: #1A1A2E
- Text color: #FFFFFF
- Padding: 16px 24px
- Border radius: 8px
- Font: Inter, 16px, 600 weight, 24px line-height

**Existing components to use**: Button from @/components/ui/button

**Code**:
[Complete code example with exact values]

**Verify**: [What to check — visual output, TypeScript compilation, component rendering]
```

#### Playwright Validation Plan

Specify exactly what to validate:
```
1. Navigate to http://localhost:PORT/path
2. Screenshot at 1440px viewport — compare layout, colors, typography
3. Screenshot at 768px — compare responsive behavior
4. Screenshot at 375px — compare mobile layout
5. Hover over [element] — compare hover state
6. Click [element] — compare active state
7. Tab through interactive elements — verify focus indicators
```

### Quality Checklist

Before finalizing, verify the plan covers:
- [ ] Every visual element from the Figma design
- [ ] All colors with exact hex/rgba values
- [ ] All spacing with exact pixel values
- [ ] All typography with exact font properties
- [ ] All shadows and effects
- [ ] All interactive states (hover, active, focus, disabled)
- [ ] Responsive behavior for relevant breakpoints
- [ ] Accessibility (WCAG compliance)
- [ ] Asset handling (images, icons from Figma MCP)
- [ ] Existing component reuse where possible
- [ ] Playwright validation steps
