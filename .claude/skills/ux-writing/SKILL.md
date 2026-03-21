---
name: ux-writing
description: Write, review, or improve UX copy for any interface — buttons, error messages, empty states, onboarding flows, tooltips, confirmation dialogs, navigation labels, and more. Adapts all copy to the project's brand voice (or helps establish one from existing Figma screens). Use this skill when the user asks "what should this button say?", "write copy for this screen", "review this error message", "improve the microcopy", "write UX copy", "help me name this", "what's the right label for", or any time copy needs to be written or reviewed for a UI. Also trigger when another skill (create-concepts, design-feedback) needs UX copy written or evaluated as part of its workflow.
---

# UX Writing

Write clear, useful, on-brand UX copy for any interface context. Every word in a UI is a design decision — this skill treats copy with the same rigor as layout, color, and typography.

## Step 0: Load Brand Voice

Before writing or reviewing any copy, check for brand voice context.

Read the file `brand-voice.md` in this skill's directory (`.claude/skills/ux-writing/brand-voice.md`).

**If `brand-voice.md` has content** — use it as the foundation for all copy decisions. The brand voice defines the product's personality, tone spectrum, vocabulary preferences, and writing patterns. Every piece of copy you write or review must align with it.

**If `brand-voice.md` is empty or missing** — you cannot write on-brand copy without knowing the brand. Ask the user:

> "I don't have your brand voice on file yet. I can set it up in two ways:
>
> 1. **From existing screens** — share a Figma link to 3-5 screens from your product that represent your current voice well, and I'll analyze the patterns and fill in the brand voice guide for you.
> 2. **Manual input** — fill in `.claude/skills/ux-writing/brand-voice.md` with your brand's voice, tone, and vocabulary guidelines.
>
> Which works better for you?"

### If the user provides a Figma link for voice extraction:

1. Use `mcp__figma__get_figma_data` to fetch the design data from the provided screens
2. Use `mcp__figma__download_figma_images` to get screenshots for visual context
3. Analyze ALL text content across the screens — buttons, headings, descriptions, labels, error messages, empty states, tooltips, navigation items
4. Identify patterns across these dimensions:
   - **Personality**: Is the product formal or casual? Warm or neutral? Playful or serious?
   - **Sentence structure**: Short fragments or full sentences? Active or passive voice?
   - **Vocabulary level**: Technical jargon or plain language? Industry terms or everyday words?
   - **Tone range**: How does the voice shift between success, error, neutral, and onboarding contexts?
   - **Capitalization**: Title Case, Sentence case, or ALL CAPS for different elements?
   - **Punctuation habits**: Periods on short labels? Exclamation marks? Ellipsis?
   - **Person**: First person (we/our), second person (you/your), or third person?
   - **CTA style**: Verb-first? Noun-based? How specific?
5. Write the findings into `brand-voice.md` using the template structure below
6. Present the brand voice summary to the user for confirmation before proceeding

### brand-voice.md template structure:

```markdown
# Brand Voice Guide

## Personality
[2-3 adjectives that define the brand personality, with brief explanation]

## Tone Spectrum
| Context | Tone | Example |
|---------|------|---------|
| Success | [e.g., Warm, celebratory but restrained] | [Real example from screens] |
| Error | [e.g., Empathetic, direct, solution-focused] | [Real example from screens] |
| Neutral / Informational | [e.g., Clear, concise, helpful] | [Real example from screens] |
| Onboarding / Empty State | [e.g., Encouraging, guiding] | [Real example from screens] |
| Warning | [e.g., Calm, clear, actionable] | [Real example from screens] |

## Voice Attributes
- **Person**: [First/second/third person and when each is used]
- **Formality**: [Scale from 1-5, with 1 being very casual and 5 being very formal]
- **Sentence length**: [Short fragments / Medium / Full sentences]
- **Active vs passive**: [Preference]
- **Contractions**: [Yes/No/Sometimes]

## Vocabulary
### Preferred terms
| Instead of | Use |
|-----------|-----|
| [generic term] | [brand-specific term] |

### Words to avoid
- [Word/phrase and why]

## Capitalization & Punctuation
- **Headings**: [Title Case / Sentence case]
- **Buttons**: [Title Case / Sentence case]
- **Labels**: [Title Case / Sentence case]
- **Periods**: [When to use / not use]
- **Exclamation marks**: [Policy]

## Patterns
### CTAs
[How the brand writes calls to action — verb choice, specificity level, tone]

### Error messages
[Brand's approach to errors — empathy level, structure, blame avoidance]

### Empty states
[How the brand fills empty screens — motivational, instructional, or minimal]
```

---

## Step 1: Understand the Context

When the user asks for copy, gather what you need. Some of this may already be clear from the conversation — don't re-ask what's obvious.

- **Where does this copy live?** Screen, component, flow step, notification, email
- **What is the user doing?** The action or task they're in the middle of
- **What emotional state are they likely in?** Frustrated (error), accomplished (success), confused (onboarding), neutral (navigation)
- **Are there constraints?** Character limits, platform guidelines, space in the UI, accessibility requirements
- **Is there existing copy to improve?** Or is this new copy from scratch?

If a Figma link is provided, use `mcp__figma__get_figma_data` to see the full screen context. Copy doesn't exist in isolation — seeing the surrounding UI helps you write copy that fits the visual hierarchy and user flow.

---

## Step 2: Apply the Five Principles

Every piece of copy must pass these five tests. They're ordered by priority — when principles conflict, the one listed first wins.

### 1. Clear
Say exactly what you mean. No jargon unless the audience expects it. No ambiguity. If a user could misread it two ways, rewrite it.

**Test**: Could someone unfamiliar with this product understand this on first read?

### 2. Useful
Every word should help the user accomplish their goal. Decorative copy is noise. If removing a word doesn't change the meaning or helpfulness, remove it.

**Test**: Does this copy help the user do something, understand something, or decide something?

### 3. Concise
Use the fewest words that convey the full meaning. But concise doesn't mean cryptic — clarity always beats brevity.

**Test**: Can you say the same thing in fewer words without losing meaning?

### 4. Consistent
Same terms for the same things, everywhere. If you call it "project" in the sidebar, don't call it "workspace" in the modal. Consistency builds trust and reduces cognitive load.

**Test**: Is this term used the same way everywhere else in the product?

### 5. Human
Write like a helpful person, not a robot or a legal document. Match the brand voice from Step 0. Real humans use contractions, active voice, and direct address.

**Test**: Would you say this out loud to a colleague without feeling weird?

---

## Step 3: Write Using Copy Patterns

Apply the right pattern for the UI element you're writing for. These patterns encode best practices — use them as starting structures, then adapt to the brand voice.

### CTAs (Buttons, Links, Actions)
- **Start with a verb**: "Start free trial", "Save changes", "Download report"
- **Be specific**: "Create account" not "Submit". "Remove item" not "Delete"
- **Match the outcome**: The button label should describe what happens when you click it
- **Primary vs secondary**: Primary CTA uses strong action verb. Secondary uses softer language ("Cancel", "Maybe later", "Skip for now")

### Error Messages
**Structure**: What happened + Why (if helpful) + How to fix

> "Payment declined. Your card was declined by your bank. Try a different card or contact your bank."

- Never blame the user ("You entered an invalid email" -> "That doesn't look like an email address")
- Always offer a next step
- Be specific about what went wrong — "Something went wrong" is never acceptable as a final state

### Empty States
**Structure**: What this is + Why it's empty + How to start

> "No projects yet. Create your first project to start collaborating with your team."

- This is a moment of opportunity, not a dead end
- Guide the user toward the first action
- Keep it warm but not patronizing

### Confirmation Dialogs
- **Make the action explicit**: "Delete 3 files?" not "Are you sure?"
- **Describe consequences**: "This can't be undone" or "Team members will lose access"
- **Label buttons with the action**: "Delete files" / "Keep files" — never "OK" / "Cancel"
- **Destructive actions get specific labels**: "Remove from team" not "Remove"

### Tooltips
- One sentence maximum. If you need more, it belongs somewhere else.
- Answer "what is this?" or "why should I care?" — never state the obvious
- Don't repeat the label. If the button says "Export", the tooltip shouldn't say "Click to export"

### Loading States
- Set expectations: "Loading your dashboard..." or "Importing 24 contacts..."
- For long waits, add progress or reassurance: "This usually takes about 30 seconds"
- Keep it calm — loading states are not the place for personality

### Onboarding
- One concept per step. Progressive disclosure, not information dump.
- Focus on what the user can DO, not on what the feature IS
- Use the user's goal as the frame: "Let's set up your first project" not "Welcome to the project management module"

### Navigation Labels
- Nouns, not verbs: "Settings" not "Configure". "Reports" not "View reports"
- Match the user's mental model, not the system's architecture
- Maximum 2 words for primary navigation items

### Success Messages
- Confirm the action: "Project created" not just a green checkmark
- Suggest a next step when relevant: "Project created. Invite your team to start collaborating."
- Match the effort — a major accomplishment deserves more acknowledgment than a settings change

### Form Labels and Help Text
- Labels should be nouns or short noun phrases: "Email address", "Company name"
- Placeholder text is NOT a replacement for labels — it disappears on focus
- Help text goes below the field: "Must be at least 8 characters" not in the placeholder
- Use examples in placeholders when helpful: "e.g., acme-corp"

---

## Step 4: Deliver the Copy

Present your copy in this format:

```markdown
## UX Copy: [Context]

### Recommended Copy

**[Element]**: [Copy]
**[Element]**: [Copy]
...

### Alternatives

| Option | Copy | Tone | Best for |
|--------|------|------|----------|
| A | [Copy] | [Tone description] | [When this version works better] |
| B | [Copy] | [Tone description] | [When this version works better] |

### Rationale

[Why this copy works — connect it to the user's context, emotional state, and the brand voice. Reference specific brand voice attributes from brand-voice.md when relevant.]

### Consistency Check

[Flag any terminology conflicts with existing copy visible in the design. Note if any terms need alignment across the product.]

### Localization Notes

[Only include if relevant — idioms to avoid, character expansion concerns, cultural considerations for international audiences.]
```

---

## When Used by Other Skills

This skill can be invoked by other skills that need UX copy as part of their workflow. When called from another skill:

### From create-concepts
When the `create-concepts` skill invokes `ux-writing`, apply the brand voice to ALL text content in each concept:
- Navigation labels, page titles, section headings
- Button copy and CTAs
- Empty states, placeholder text, help text
- Any microcopy (tooltips, badges, status labels)
- Ensure copy distinctions between concepts match their structural distinctions — a "playful" concept should have playful copy, a "professional" concept should have professional copy

### From design-feedback
When the `design-feedback` skill invokes `ux-writing`, evaluate all visible copy in the design against:
- The brand voice guide (is it on-brand?)
- The five principles (clear, useful, concise, consistent, human)
- The copy patterns (are CTAs verb-first? Are error messages structured correctly?)
- Provide specific rewrites for any copy that falls short, not just "the copy could be improved"

---

## Common Mistakes to Watch For

These are the copy problems you should always flag, whether writing or reviewing:

- **"Click here"** — The link text should describe the destination, not the action of clicking
- **"Please"** in error messages — It adds length without adding empathy. "Try again" is kinder than "Please try again" because it's faster to read when frustrated
- **"Successfully"** — "Project created" says the same thing as "Project successfully created" in fewer words
- **"Are you sure?"** — Tell them what will happen, not ask if they're sure
- **"Invalid input"** — Tell them what's wrong and how to fix it
- **"N/A" or "-" for empty values** — Use a human-readable explanation or hide the field
- **Inconsistent terminology** — "Delete" in one place and "Remove" in another for the same action
- **Robot voice** — "Your request has been processed" vs "Done! Your changes are saved"
- **Feature-speak vs user-speak** — "Utilize the dashboard analytics module" vs "See how your project is doing"
