# Use Project Design Tokens

## Pattern to Follow

When writing any CSS, styling, or UI code, always use project design tokens. Never invent or hardcode values.

### Colors

- Only use color tokens from `tokens/colors.ts`
- Never hardcode hex values, RGB, or HSL — always reference token variables
- If a color doesn't exist in the token file, flag it to the user before proceeding

### Spacing

- Use the 4px base unit scale: 4, 8, 12, 16, 24, 32, 48, 64
- Never use arbitrary spacing values outside this scale
- Map Figma spacing values to the nearest token in the scale

### Typography

- Use typography tokens for font-family, font-size, font-weight, line-height, and letter-spacing
- Never hardcode font sizes or weights directly

### Border Radius

- Use border radius tokens defined in the design system
- Never hardcode `border-radius` pixel values directly

## Examples

✅ CORRECT:
```tsx
import { colors } from '@/tokens/colors';

<div style={{ padding: 16, backgroundColor: colors.primary500, borderRadius: 'var(--radius-md)' }}>
  <Text variant="body">Content</Text>
</div>
```

❌ WRONG:
```tsx
<div style={{ padding: 15, backgroundColor: '#3B82F6', borderRadius: '6px' }}>
  <span style={{ fontSize: '14px', fontWeight: 500 }}>Content</span>
</div>
```

## Why This Matters

- Ensures visual consistency across the entire application
- Makes theme changes and dark mode trivial (update tokens, not components)
- Prevents design drift where developers approximate values
- Keeps the codebase aligned with the Figma design system
