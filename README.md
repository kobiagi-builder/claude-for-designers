# Claude for Designers

Turn your Figma designs into production-ready code using Claude Code. This project gives you a pre-configured workspace with skills that connect directly to Figma, generate pixel-perfect code, and preview the result in a browser — all from natural language.

## What You Can Do

- **Implement Figma designs** — Paste a Figma link, get production-ready code that matches your design exactly
- **Extract design systems** — Pull colors, typography, and spacing from Figma into reusable design tokens
- **Preview in browser** — Automatically open your implementation in a browser to compare against the original design
- **Test responsiveness** — Check how your implementation looks across different screen sizes
- **Export assets** — Download images, icons, and illustrations directly from your Figma file

## Prerequisites

1. **Cursor or VS Code** with the Claude Code extension installed
2. **Node.js** (v18 or later) — [Download](https://nodejs.org/)
3. **A Figma account** — you'll be asked for your API key during setup

## Getting Started

### 1. Run the installer

Open Terminal, navigate to the folder where you want the project, and paste:

```bash
curl -sL https://raw.githubusercontent.com/kobiagi-builder/claude-for-designers/main/install.sh | bash
```

The installer will:
1. Clone the repository
2. Ask for your **Figma API key** (with instructions on where to find it)
3. Configure both **Figma** and **Playwright** connections automatically

### 2. Open in Cursor or VS Code

Open the `claude-for-designers` folder in your IDE. The Figma and Playwright connections will load automatically.

### 3. Start using it

Open a Claude chat in your IDE and paste any Figma link — Claude will implement it as code.

### Manual Install (Alternative)

If you prefer to set up without the installer:

```bash
git clone https://github.com/kobiagi-builder/claude-for-designers.git
```

Open the folder in Cursor or VS Code, then type `/prep` in a Claude chat to run the setup wizard.

## How to Get Your Figma API Key

1. Open [Figma](https://www.figma.com) and log in
2. Click your profile icon (top-left) and go to **Settings**
3. Scroll down to **Personal Access Tokens**
4. Click **Generate new token**, give it a name, and copy the key
5. The key starts with `figd_` — keep it somewhere safe until the installer asks for it

## Usage

### Implement a design from Figma

Paste a Figma link and describe what you want:

```
Implement this design: https://figma.com/design/ABC123/MyApp?node-id=1-42

This is a pricing card component with three tiers.
```

Claude will fetch the design data from Figma, generate matching code, and optionally preview it in the browser.

### Quick component implementation

For a single component:

```
Implement this component: https://figma.com/design/ABC123/MyApp?node-id=5-100
```

### Extract a design system

```
Extract the design system from this Figma file: https://figma.com/design/ABC123/MyApp
```

### Compare implementation vs design

```
Compare my implementation against the Figma design
```

### Preview in browser

```
Preview this page in the browser and take a screenshot
```

## Project Structure

```
claude-for-designers/
├── .claude/
│   ├── CLAUDE.md                          # Project instructions for Claude
│   ├── rules/                             # Design system and code quality rules
│   │   ├── design-system-tokens.md        # Use design tokens, never hardcode
│   │   ├── figma-to-code-fidelity.md      # Pixel-perfect implementation rules
│   │   └── component-library-first.md     # Reuse existing components first
│   └── skills/
│       ├── prep/                           # Setup wizard (/prep)
│       ├── figma-implement-design-v1/      # Single component workflow
│       ├── implement-figma-design-v2/      # Full multi-phase workflow
│       └── webapp-testing/                 # Browser preview and testing
├── src/                                    # Your generated code goes here
├── install.sh                              # One-command installer
├── .gitignore                              # Keeps your API key out of git
└── README.md
```

## Built-in Skills

| Command | What it does |
|---|---|
| `/prep` | First-time setup — configures Figma and Playwright connections |
| Paste a Figma link | Automatically implements the design as code |
| `/webapp-testing` | Preview and test your implementation in the browser |

## Troubleshooting

### "MCP server not found" or Figma commands fail
Run `/prep` in a Claude chat to reconfigure, then restart the Claude extension.

### "Invalid Figma API key"
Your key may have expired. Generate a new one in Figma Settings > Personal Access Tokens, then run `/prep` again.

### Playwright isn't working
Make sure Node.js is installed (`node --version` in Terminal). Playwright is downloaded automatically on first use.

### MCP servers not showing up after install
Close and reopen your IDE so the Claude extension reloads the MCP configuration.

## Security

- Your Figma API key is stored only in `.mcp.json` at the project root
- `.mcp.json` is in `.gitignore` — it will **never** be committed or pushed to GitHub
- No keys are stored in environment variables, cloud services, or shared config files
- Each user has their own independent key

## License

MIT
