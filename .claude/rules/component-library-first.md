# Use Existing Components Before Creating New Ones

## Pattern to Follow

Before building any UI element, check for an existing component that fits. Only create new components when nothing in the project or its UI library covers the need.

### Lookup Order

1. Check `src/components/ui/` for project-specific components
2. Check shadcn/ui components (Button, Card, Dialog, Input, Select, etc.)
3. Only create a new component if nothing existing fits the requirement

### When Reusing Components

- Use the component's existing API (props, variants, sizes) rather than wrapping or overriding
- If a component is close but needs a minor variant, extend it rather than duplicating
- Compose existing primitives before building from scratch

### When Creating New Components

- Confirm with the user that no existing component fits
- Follow the same patterns and conventions used by existing components in `src/components/ui/`
- Place new components in the appropriate directory under `src/components/`

## Examples

✅ CORRECT:
```tsx
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardContent } from '@/components/ui/card';

<Card>
  <CardHeader>Title</CardHeader>
  <CardContent>
    <Button variant="outline" size="sm">Action</Button>
  </CardContent>
</Card>
```

❌ WRONG:
```tsx
// Creating a custom button when Button component already exists
const MyButton = ({ children, ...props }) => (
  <button className="px-4 py-2 rounded bg-blue-500 text-white" {...props}>
    {children}
  </button>
);
```

## Why This Matters

- Prevents component duplication and inconsistent UI
- Reduces maintenance burden — fixes and updates propagate from shared components
- Keeps bundle size smaller by reusing existing code
- Maintains design consistency across the application
