---
name: suggest-concept
description: Generates 3 distinct design concepts from a user's raw idea or mind dump. Researches best practices and successful similar products online, then builds each concept as code, pushes them to Figma as editable layers, and presents a comparison with pros/cons and references. Use this skill when the user has an idea, feature request, product concept, or mind dump they want to explore visually. Trigger phrases include "suggest concept", "explore ideas", "concept options", "design concepts", "I have an idea for", "brainstorm designs", "what could this look like", or any time the user describes a product idea and wants to see visual directions. Also use when the user says "I'm thinking about", "what if we built", or shares a rough idea and wants to see it materialized as design options. Requires Figma MCP and Playwright MCP connections.
---

# Suggest Concept

Turn a raw idea into 3 distinct, research-backed design concepts — built as code, pushed to Figma as editable layers, and presented with pros, cons, and the real-world references that inspired each one.

## Prerequisites

- **Figma MCP** connected (for pushing concepts to Figma via `generate_figma_design`)
- **Playwright MCP** connected (for running the dev server and capturing UI)
- **Web search** available (for researching best practices and competitors)

---

## Phase 1: Understand the Idea

The user will share a raw idea — it might be polished or it might be a messy brain dump. Your job is to deeply understand what they're envisioning before moving forward. Rushing past this phase leads to concepts that miss the mark.

### What to extract

Work through these questions. Some answers may already be in the user's message — don't re-ask what's already clear. Only ask about what's genuinely missing or ambiguous.

- **Core problem**: What problem does this solve? Who feels this pain?
- **Target users**: Who are the primary users? What's their context (mobile, desktop, on-the-go, at work)?
- **Key actions**: What are the 2-3 most important things a user should be able to do?
- **Scope**: Is this a full product, a single feature, a page, a flow?
- **Constraints**: Any technical, brand, or business constraints?
- **Mood/feel**: Any references or adjectives for the desired vibe? (fast, playful, professional, minimal, dense)

### How to ask

Group your questions naturally — don't fire 10 questions at once. Ask 2-3 at a time, building on the user's responses. If the user's dump is detailed enough, you may only need 1 round of clarification.

When you're confident you understand the idea well enough to research and design it, summarize your understanding back to the user in 3-4 sentences and ask them to confirm before proceeding.

---

## Phase 2: Establish the Design System

Every concept must follow the user's design system so they feel cohesive with the rest of the product. Before researching or designing, lock down the visual foundation.

### If the user has an existing design system

Ask: "Where's your design system? A Figma link or a style guide works."

Once you have the link:
1. Use `mcp__figma__get_figma_data` to fetch the design system's colors, typography, spacing, and components
2. Extract the key tokens: color palette, font families, font sizes/weights, spacing scale, border radii, shadows
3. Document these in `.claude/rules/design-system-tokens.md` so all concepts (and future work) use them consistently

### If the user doesn't have a formal design system

Ask: "Can you share 2-3 Figma screens from your existing product? I'll extract the design patterns from them."

Then:
1. Fetch each screen's design data via Figma MCP
2. Identify the recurring patterns: primary/secondary colors, fonts, spacing rhythm, component styles, radius/shadow conventions
3. Document the extracted system in `.claude/rules/design-system-tokens.md`

### What to document in design-system-tokens.md

```markdown
# Design System Tokens

## Colors
- Primary: #XXXXXX
- Secondary: #XXXXXX
- Background: #XXXXXX
- Surface: #XXXXXX
- Text primary: #XXXXXX
- Text secondary: #XXXXXX
- Border: #XXXXXX
- Error/Success/Warning: ...

## Typography
- Font family: [name]
- Headings: [sizes, weights, line-heights]
- Body: [sizes, weights, line-heights]
- Captions/labels: ...

## Spacing
- Base unit: Xpx
- Scale: [4, 8, 12, 16, 24, 32, 48, 64] or whatever the pattern is

## Border Radius
- Small: Xpx
- Medium: Xpx
- Large: Xpx

## Shadows
- Card: ...
- Dropdown: ...
- Modal: ...

## Components
- Button styles (primary, secondary, ghost)
- Card patterns
- Input styles
- Any other recurring components
```

---

## Phase 3: Research

This is what separates informed concepts from guesswork. Run two parallel research tracks.

### 3a. Best practices research

Search for UX best practices relevant to the user's idea:
- UX patterns for the specific domain (e.g., "dashboard UX best practices", "onboarding flow patterns")
- Information architecture approaches
- Interaction models that work well for this type of product
- Accessibility considerations specific to this context

Keep notes on 5-8 relevant patterns or principles. You'll reference these when presenting the concepts.

### 3b. Competitive / inspirational research

Search for the best existing products that solve similar problems or serve similar users:
- Direct competitors (solve the same problem)
- Indirect competitors (solve adjacent problems with transferable patterns)
- Best-in-class examples from other domains that share UX characteristics

For each product worth noting, capture:
- What they do well (specific UX/design strengths)
- What makes them successful
- What could be improved

Aim for 4-6 solid references. These become the inspiration citations in your final presentation.

---

## Phase 4: Design 3 Concepts

Now create three genuinely distinct design concepts. The key word is **distinct** — not three color variations of the same layout, but three fundamentally different approaches to solving the user's problem.

### What makes concepts truly distinct

Good distinction comes from varying the **structure, hierarchy, or interaction model** — not surface styling. Examples of real distinction:

- **Concept A**: Dashboard-centric — everything on one dense screen, data-forward
- **Concept B**: Task-flow — guided step-by-step experience, wizard-like
- **Concept C**: Conversational — chat-based interface, progressive disclosure

Or:
- **Concept A**: Card grid layout with filtering
- **Concept B**: List-based layout with inline expansion
- **Concept C**: Map/spatial layout with contextual panels

### Building each concept

For each concept:

1. **Name it** — give it a short, evocative name that captures its personality (e.g., "Command Center", "Guided Journey", "Canvas")

2. **Build it as code** using the project's default tech stack (Next.js + Tailwind CSS + shadcn/ui + TypeScript):
   - Create a separate route for each concept (e.g., `/concept-1`, `/concept-2`, `/concept-3`)
   - Use the design system tokens from Phase 2 for all colors, typography, spacing
   - Include realistic mock data — no lorem ipsum
   - Make interactive elements functional (tabs switch, buttons respond, etc.)
   - Focus on the key screens/states that communicate the concept's approach

3. **Keep it focused** — each concept should clearly communicate its structural approach in 1-2 screens. Don't over-build. The goal is to show the *direction*, not a finished product.

### Ask where to store in Figma

Before pushing to Figma, ask the user:

> "Where should I store the concepts in Figma? Please share the Figma file link and the page name where you'd like them placed."

---

## Phase 5: Push to Figma

With the concepts built as code and the dev server running:

1. Start the dev server (`npm run dev`)
2. For each concept:
   - Navigate to its route via Playwright
   - Use `generate_figma_design` to capture the live UI and push it to the user's specified Figma file/page
   - Each concept should be clearly labeled in Figma with its name
3. Collect the Figma links for each pushed concept

If `generate_figma_design` is not available or fails, fall back to:
- Take Playwright screenshots of each concept
- Present the screenshots to the user directly
- Note that the code is available locally for them to view in the browser

---

## Phase 6: Present Results

Present all three concepts to the user in a clear, structured comparison. For each concept, include:

### Presentation format

```
## Concept 1: [Name]

**Figma**: [link to the concept in Figma]

**Approach**: [1-2 sentence summary of the structural/UX approach]

**Inspired by**:
- [Product/pattern name] — [what was borrowed and why]
- [Product/pattern name] — [what was borrowed and why]

**Pros**:
- [Strength 1]
- [Strength 2]
- [Strength 3]

**Cons**:
- [Tradeoff or limitation 1]
- [Tradeoff or limitation 2]

---

## Concept 2: [Name]
...

## Concept 3: [Name]
...
```

### After presenting

Ask the user which direction resonates, or if they'd like to combine elements from different concepts. Common responses:
- "I like Concept 2" → offer to refine and flesh it out
- "I like the layout from 1 but the interaction from 3" → offer to create a hybrid
- "None of these feel right" → ask what's missing and iterate

---

## Tips for Strong Concepts

- **Ground every decision in research.** If you're using a card grid, cite why (e.g., "Notion and Linear both use card grids for project overviews because they support scanning and quick comparison").
- **Make the pros/cons honest.** Every approach has real tradeoffs. A dashboard-centric design is efficient for power users but overwhelming for newcomers. Say that.
- **Use the design system religiously.** The concepts should feel like they belong to the user's product, not like generic dribbble shots.
- **Show realistic content.** Domain-appropriate data, realistic names/numbers/dates, mixed states. This helps the user evaluate whether the concept actually works, not just whether it looks pretty.
