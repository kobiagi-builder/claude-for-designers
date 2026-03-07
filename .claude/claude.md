# Claude for Designers

This project helps software designers use Claude Code to accelerate their design-to-code workflow. It connects to Figma for design data and Playwright for browser-based testing and previewing.

## Project Overview

- **Audience**: Software designers who work with Figma and need to translate designs into production-ready code
- **MCP Servers**: Figma (design data extraction), Playwright (browser automation and visual testing)
- **Primary workflow**: Figma design -> code generation -> browser preview/validation

## Key Tools & Capabilities

### Figma MCP
- Use `mcp__figma__get_figma_data` to fetch design data from Figma files, frames, or components
- Use `mcp__figma__download_figma_images` to download image assets from Figma
- When the user provides a Figma URL, extract the file key and node IDs to fetch the relevant design data

### Playwright MCP
- Use Playwright tools to navigate to pages, take screenshots, and validate visual output
- Compare implemented designs against Figma specs by screenshotting the result
- Test responsive behavior across viewport sizes

## Workflow Guidelines

### When the user shares a Figma link:
1. **Always use the `.claude/skills/figma-implement-design` skill** to implement Figma designs. Invoke this skill before any implementation work.
2. Follow the skill's workflow for fetching design data, analyzing structure, and generating code.
3. Use Playwright to preview and validate the result if a dev server is available

### Code Generation Principles
- **Pixel-perfect fidelity**: Match the Figma design as closely as possible - spacing, colors, typography, border radius, shadows
- **Semantic HTML**: Use appropriate HTML elements (`nav`, `main`, `section`, `article`, etc.)
- **Responsive by default**: Implement responsive layouts unless the design is explicitly fixed-width
- **CSS approach**: Prefer modern CSS (flexbox, grid, custom properties) unless the user specifies a framework like Tailwind
- **Component structure**: Break designs into logical, reusable components
- **Design tokens**: Extract repeated values (colors, spacing, font sizes) into variables or tokens

### Design Interpretation
- When Figma data includes Auto Layout, translate it to flexbox or grid
- Map Figma constraints to CSS positioning and responsive behavior
- Preserve the visual hierarchy and spacing relationships from the design
- Handle text styles consistently - extract font family, size, weight, line height, and letter spacing
- Convert Figma color values (including opacity) to appropriate CSS format

### Asset Handling
- Download images and icons from Figma when needed using the image download tool
- Use SVG for icons and simple illustrations when available
- Suggest appropriate image formats (WebP for photos, SVG for icons)

## Communication Style

- Use clear, non-technical language when explaining design decisions to the user
- When suggesting alternatives to a design, explain the tradeoff (visual vs performance vs accessibility)
- Ask before making assumptions about interactions, animations, or states not shown in the design
- Present code in digestible chunks rather than overwhelming with full implementations
- When showing design-to-code mappings, reference specific Figma layers/frames by name

## Common Tasks

- **"Implement this design"**: Always use the `figma-implement-design` skill, then generate code matching the design
- **"Extract the design system"**: Pull colors, typography, spacing from Figma and create a token/variable system
- **"Make this responsive"**: Adapt a fixed design to work across screen sizes
- **"Compare my implementation"**: Screenshot the current implementation and compare against the Figma design
- **"Export assets"**: Download images, icons, and illustrations from the Figma file
