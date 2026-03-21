---
name: create-concepts
description: Generates 3 distinct design concepts from a user's raw idea or mind dump. Researches best practices and successful similar products online, then builds each concept as code, pushes them to Figma as editable layers, and presents a comparison with pros/cons and references. Use this skill when the user has an idea, feature request, product concept, or mind dump they want to explore visually. Trigger phrases include "create concepts", "suggest concept", "explore ideas", "concept options", "design concepts", "I have an idea for", "brainstorm designs", "what could this look like", or any time the user describes a product idea and wants to see visual directions. Also use when the user says "I'm thinking about", "what if we built", or shares a rough idea and wants to see it materialized as design options. Requires Figma MCP and Playwright MCP connections.
---

# Suggest Concept

Turn a raw idea into 3 distinct, research-backed design concepts — built as code, pushed to Figma as editable layers, and presented with pros, cons, and the real-world references that inspired each one.

## Prerequisites

- **Design system rules must exist.** Before doing anything else, check if `.claude/rules/design-system.md` and `.claude/rules/styleguide.md` exist. If either file is missing, invoke the `prep-environment` agent (`.claude/agents/prep-environment/AGENT.md`) and wait for it to complete before proceeding. These files are used in Phase 2 instead of manual extraction.
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

## Phase 2: Load the Design System

Every concept must follow the user's design system so they feel cohesive with the rest of the product.

Read both `.claude/rules/design-system.md` and `.claude/rules/styleguide.md`. These files were created by the `prep-environment` agent and contain the complete design system — colors, typography, spacing, shadows, border radii, component specs, interaction patterns, and layout conventions.

Use these values for all concepts:
- **Colors**: Use exact hex/rgba values from the design system
- **Typography**: Use the documented font families, sizes, weights, and line heights
- **Spacing**: Follow the documented spacing scale
- **Components**: Match the component variants, sizes, and states from the styleguide
- **Interactions**: Follow hover, focus, active, and disabled patterns from the styleguide

If the files feel incomplete for the concepts you're building (e.g., the user's design system doesn't cover a component type you need), note what's missing and make reasonable choices that are consistent with the existing system's visual language.

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

## Phase 3.5: Select Visual References

Before designing, consult the curated visual reference library bundled with this skill. These are real screenshots from best-in-class products organized by vertical, giving you concrete visual anchors for each concept — not just ideas in the abstract, but proven layouts and patterns you can study and draw from.

### How to select references

1. **Read the reference index** at `references/INDEX.md` (relative to this skill's directory). It contains:
   - 15 verticals (fintech, healthtech, ecommerce, saas-dashboards, social, marketplace, edtech, travel, productivity, crm, analytics, developer-tools, media-streaming, food-delivery, fitness)
   - 3 products per vertical with descriptions of their design strengths
   - A **Quick Reference: Pattern Lookup** table at the bottom for finding products by UI pattern type

2. **Match the user's concept to verticals and patterns.** Consider:
   - **Primary vertical**: Which vertical is the user's product closest to? (e.g., a habit tracker → fitness or productivity)
   - **Secondary verticals**: What adjacent verticals share relevant patterns? (e.g., a health habit tracker might borrow gamification from edtech/Duolingo)
   - **UI pattern needs**: What specific patterns does this concept need? (dashboard, feed, search, onboarding, pricing, etc.) Use the Pattern Lookup table.

3. **Select 3-6 reference products** — at least one per concept you'll design. For each concept, pick the reference(s) whose structural approach most closely matches the direction you're planning.

4. **View the screenshots.** Each product folder contains 3 PNG screenshots (homepage, feature page, pricing/detail). Read them to understand:
   - Layout structure and grid usage
   - Visual hierarchy and spacing rhythm
   - Color application and contrast
   - Typography scale and weight usage
   - Component patterns (cards, lists, navigation)

   Screenshot paths follow this pattern:
   ```
   references/[vertical]/[product-name]/[page-label].png
   ```

### How to use references when designing

- **Don't copy layouts wholesale** — use them as structural inspiration. If Airbnb's card grid works well for discovery, understand *why* (scannable, filterable, image-forward) and apply that reasoning to the user's domain.
- **Cite your references** in the concept presentation (Phase 6). For each concept, list which products inspired it and what specific patterns you borrowed.
- **Cross-pollinate between verticals.** The best concepts often borrow patterns from unexpected places — e.g., applying Duolingo's gamification to a CRM, or Spotify's discovery feed to an analytics dashboard.
- **Prioritize references that match the user's stated mood/feel.** If the user wants "clean and minimal," lean toward Mercury, Linear, Todoist. If they want "dense and powerful," look at Mixpanel, HubSpot, GitHub.

### Reference selection for each concept

When planning your 3 concepts, assign specific references to each:

```
Concept 1: [Name] — References: [Product A] (for layout), [Product B] (for interaction)
Concept 2: [Name] — References: [Product C] (for navigation), [Product D] (for data display)
Concept 3: [Name] — References: [Product E] (for onboarding), [Product F] (for visual style)
```

This ensures each concept is grounded in real, proven design rather than abstract ideas.

---

## Phase 3.7: Load Brand Voice for UX Copy

Before writing any text content for the concepts, load the `ux-writing` skill's brand voice context.

1. Read `.claude/skills/ux-writing/brand-voice.md`
2. **If it has content** — use it as the guide for ALL text in the concepts: headings, button labels, descriptions, empty states, navigation items, tooltips, placeholder text, and microcopy. Every word in the UI is a design decision and must match the brand voice.
3. **If it's empty** — ask the user to set it up before proceeding. They can either:
   - Provide a Figma link to 3-5 existing screens so you can analyze the copy patterns and populate `brand-voice.md` (follow the extraction process in the `ux-writing` skill)
   - Fill in `brand-voice.md` manually with their brand guidelines

Do not proceed to Phase 4 until a brand voice is available. Concepts without on-brand copy feel generic and undermine the entire exercise.

When writing copy for each concept, apply the `ux-writing` skill's five principles (Clear, Useful, Concise, Consistent, Human) and copy patterns (CTAs start with verbs, error messages follow What+Why+Fix structure, empty states follow What+Why+Action structure, etc.). Make the copy distinctions match the concept distinctions — a bold concept gets bold copy, a minimal concept gets spare copy.

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
   - **Study your assigned visual references** from Phase 3.5 — open the screenshots and use them as structural guides for layout, spacing rhythm, and component patterns
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

**Visual references used**:
- [Product name] (`references/[vertical]/[product]/[screenshot].png`) — [what pattern was borrowed and why]
- [Product name] (`references/[vertical]/[product]/[screenshot].png`) — [what pattern was borrowed and why]

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
