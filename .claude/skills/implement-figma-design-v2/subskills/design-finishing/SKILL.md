---
name: design-finishing
description: Internal implement-figma-design subskill for completing design implementation — do not invoke directly.
---

## Finishing a Design Implementation

### Overview

Guide completion of a Figma design implementation by collecting results, reporting to the user, and presenting clear options.

**Core principle:** Verify visual fidelity → Report results → Present options.

### Step 1: Verify Playwright Results

**Before presenting completion, verify all Playwright checks pass:**

Ensure:
- Final Playwright screenshot matches Figma screenshot (no critical/major issues)
- All interactive states verified (hover, active, focus, disabled)
- Responsive viewports verified (if applicable)
- Accessibility scan passes (no critical violations)

**If verification fails:**
```
Visual fidelity checks still have issues:

[Show remaining issues]

Cannot mark as complete until visual parity is achieved.
```

Stop. Don't proceed to Step 2.

**If verification passes:** Continue to Step 2.

### Step 2: Collect Results

Gather all facts from the implementation process:

- **Plan-editor rounds**: How many rounds to finalize the plan
- **Review rounds**: How many Playwright comparison rounds
- **Components created**: List of new component files
- **Components modified**: List of changed existing files
- **Design tokens**: Any new tokens added or overrides documented
- **Assets downloaded**: Images/icons from Figma MCP
- **Residual issues**: Any minor/nit issues from final review
- **Playwright results**: Summary of visual comparison outcomes

### Step 3: Report to User

Present a clear, factual completion report:

```
## Implementation Complete

### Summary
[Concise description of what was implemented]

### Figma Source
- File: [fileKey]
- Node: [nodeId]
- Screenshot comparison: [PASS/number of iterations]

### Process
- Plan-editor rounds: [N]
- Review rounds: [N]
- Total components: [N] created, [N] modified

### Files Changed
[One file per line]

### Visual Validation
- Desktop (1440px): PASS
- Tablet (768px): PASS
- Mobile (375px): PASS
- Hover states: PASS
- Focus states: PASS
- Accessibility: PASS

### Residual Issues
[Any minor/nit issues, or "None"]
```

### Step 4: Present Options

Present exactly these options:

```
What would you like to do next?

1. Review the implementation in the browser (I'll navigate with Playwright)
2. Make adjustments (describe what to change)
3. Implementation is complete — move on
```

**Don't add extra explanation** — keep options concise.

### Step 5: Execute Choice

#### Option 1: Browser Review
Use Playwright to navigate to the implementation and take screenshots at different viewports. Let the user see the result.

#### Option 2: Adjustments
Collect the user's feedback and feed it back into the implementation subagent for another fix round.

#### Option 3: Complete
Mark the implementation as done. Report final file list.

## Common Mistakes

**Skipping visual verification**
- **Problem:** Marking complete with visual discrepancies
- **Fix:** Always verify Playwright screenshots match Figma before reporting completion

**Vague completion report**
- **Problem:** User doesn't know what was done
- **Fix:** Include concrete facts: file count, review rounds, viewport results

**Not offering adjustment option**
- **Problem:** User has no easy path to request changes
- **Fix:** Always present the 3-option menu
