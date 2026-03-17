# Eval Notes

This folder holds eval candidates for the implement-figma-design-advanced skill, recovered from real runs.

## Default Run Protocol

- Use the real plan-review step whenever possible.
- Use a fresh reviewing agent for each trial.
- For single-review evals, run exactly one review turn and score immediately.
- For multi-review evals, feed the revised plan into the next review turn with no human edits.
- Score semantic outcome, not wording.
- Because reviewers are stochastic, one run per case is the minimum and three runs is safer.

## Eval Categories

### Visual Fidelity Cases

These cases validate that the Playwright comparison loop correctly identifies and fixes visual discrepancies:

- **Threshold cases**: Start from an implementation that passes visual comparison. Correct verdict: no critical/major issues.
- **Regression cases**: Start from an implementation with known visual differences. Correct verdict: specific issues identified with exact Figma values vs implementation values.

### Planning Quality Cases

These cases validate that the plan-editor loop produces execution-ready plans:

- **Threshold cases**: Start from a plan already reviewed and approved. Correct verdict: `READY` with no changes.
- **Convergence cases**: Start from a weak initial plan. Measure how many rounds to reach an execution-ready state.

### Workflow Integrity Cases

These cases validate end-to-end workflow correctness:

- **Confidence gate**: Verify the 98% confidence threshold correctly blocks when design understanding is incomplete.
- **Review loop termination**: Verify the 8-round limit works and escalates correctly.
- **Plan-editor convergence**: Verify the 5-round limit works and escalates correctly.

## What Each Case Category Catches

- Visual fidelity threshold: over-review (reporting issues where none exist)
- Visual fidelity regression: under-review (missing real visual differences)
- Planning threshold: over-editing (changing an already execution-ready plan)
- Planning convergence: slow convergence (taking too many rounds to fix architectural issues)
- Workflow integrity: phase transitions and escalation behavior

## Scoring Guidelines

### Visual Comparison Scoring

Pass only if:
- Every critical/major issue traces to a specific Figma value vs implementation value
- No false positives (reporting non-issues as critical/major)
- No false negatives (missing real visual differences visible at a glance)

### Planning Scoring

Pass only if:
- `READY` verdicts have zero file changes
- `REVISED` verdicts fix real execution failures
- Plans contain exact Figma values (colors, spacing, typography) from design data

## Adding New Evals

When adding a new eval case:

1. Document the origin (which real run produced it)
2. Specify the input artifacts (plan, design context, Figma screenshot)
3. Define the pass condition precisely
4. Categorize: visual-fidelity | planning | workflow-integrity
5. Note whether it's a threshold (should pass unchanged) or convergence (should improve) case
