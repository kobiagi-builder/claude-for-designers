# Pixel-Perfect Figma Implementation

## Pattern to Follow

When implementing designs from Figma, match the design data exactly. Never approximate or round values — use the precise measurements from the Figma node data.

### Spacing

- Match spacing within 1px of Figma specs
- Use exact padding, margin, and gap values from the design data
- Map measured values to the closest design token in the spacing scale

### Colors

- Use exact color values from the Figma design data
- Map Figma colors to existing design tokens — if no token matches, flag it to the user
- Preserve opacity values exactly as specified

### Typography

- Preserve font-size, line-height, letter-spacing, and font-weight exactly as specified in the design
- Do not round or approximate typographic values
- Map to typography tokens where they exist

### Layout

- Translate Figma Auto Layout properties directly to flexbox/grid equivalents
- Match alignment (main axis, cross axis) exactly
- Preserve fixed vs. hug vs. fill sizing behavior from the design

### Visual Properties

- Match border-radius, shadow, and blur values exactly from the design data
- Preserve stroke width and style
- Maintain layer order and z-index relationships

## Verification

After implementation, compare the result against the Figma design:
- Use Playwright to screenshot the implementation
- Check spacing, alignment, color, and typography against the source design
- Fix any discrepancies before marking the task complete

## Examples

✅ CORRECT:
```tsx
// Values taken directly from Figma node data
<div className="flex flex-col gap-3 p-4 rounded-lg" style={{
  backgroundColor: colors.surface,
  boxShadow: '0px 1px 3px rgba(0, 0, 0, 0.1), 0px 1px 2px rgba(0, 0, 0, 0.06)',
}}>
  <Text style={{ fontSize: 18, lineHeight: '28px', letterSpacing: '-0.01em' }}>
    Heading
  </Text>
</div>
```

❌ WRONG:
```tsx
// Approximated values, not matching the design
<div className="flex flex-col gap-2 p-3 rounded-md shadow">
  <h3 className="text-lg">Heading</h3>
</div>
```

## Why This Matters

- Designers trust the implementation matches their intent exactly
- Eliminates back-and-forth review cycles caused by visual discrepancies
- Builds confidence in the design-to-code pipeline
- Maintains design integrity across the product
