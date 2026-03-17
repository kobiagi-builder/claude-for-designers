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
3. **A Figma account** — you'll sign in with your Figma account during setup (no API key needed)

## Getting Started

### 1. Run the installer

Open Terminal and run these three commands:

```bash
mkdir my-project
cd my-project
curl -sL https://raw.githubusercontent.com/kobiagi-builder/claude-for-designers/main/install.sh | bash
```

Replace `my-project` with whatever you want your project folder to be called.

The installer will:
1. Set up the project in your current folder
2. Configure both **Figma** (OAuth) and **Playwright** connections automatically
3. Open the project in Cursor or VS Code automatically
4. When you first use Figma, you'll sign in with your Figma account in the browser

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

## Connecting to Figma

This project uses Figma's official OAuth authentication — no API key or token needed.

1. After setup, open a Claude chat and run `/mcp` to see your MCP servers
2. Click **Connect** next to the Figma server
3. Sign in with your Figma account in the browser window that opens
4. Once connected, you can paste any Figma link and Claude will read your designs

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
│       ├── implement-figma-design-lite/     # Single component workflow
│       ├── implement-figma-design-advanced/ # Full multi-phase workflow
│       └── webapp-testing/                 # Browser preview and testing
├── src/                                    # Your generated code goes here
├── install.sh                              # One-command installer
├── .gitignore                              # Keeps local config out of git
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

### Figma connection fails or "Unauthorized"
Try disconnecting and reconnecting the Figma server in the MCP panel. You may need to re-authorize in your browser.

### Playwright isn't working
Make sure Node.js is installed (`node --version` in Terminal). Playwright is downloaded automatically on first use.

### MCP servers not showing up after install
Close and reopen your IDE so the Claude extension reloads the MCP configuration.

## Security

- Figma uses OAuth authentication — no API keys or tokens are stored locally
- `.mcp.json` is in `.gitignore` — it will **never** be committed or pushed to GitHub
- Figma authorization is managed through your browser and Figma account
- Each user authenticates independently with their own Figma account

## License

MIT
