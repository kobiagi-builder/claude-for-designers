---
name: prep
description: Interactive setup wizard that configures Figma and Playwright MCP servers for new users. Uses Figma OAuth (no API key needed) and writes the project .mcp.json automatically.
---

# Project Setup Wizard

This skill configures the MCP servers (Figma + Playwright) so the design-to-code workflow works out of the box.

## When to Use

- After cloning the repo for the first time
- When MCP servers are not working or missing
- When the user says "prep", "setup", "configure", or "my MCP isn't working"

## Workflow

### Step 1: Check Current MCP Status

Check if a project-level `.mcp.json` already exists at the repo root:

```bash
ls -la .mcp.json
```

If it exists, read it and check whether both `figma` and `playwright` servers are configured.

### Step 2: Write the `.mcp.json` File

Write the following to `.mcp.json` at the project root:

```json
{
  "mcpServers": {
    "figma": {
      "url": "https://mcp.figma.com/mcp"
    },
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@playwright/mcp"
      ]
    }
  }
}
```

This uses the **official Figma Remote MCP Server** with OAuth authentication — no API key or token is needed. The user will sign in with their Figma account when they first connect.

If the user already has a `.mcp.json`, merge the config rather than overwriting (preserve any existing servers).

### Step 3: Confirm and Instruct

Tell the user:

1. "Setup complete! Both Figma and Playwright are now configured."
2. "**Please restart Claude Code** (close and reopen) so the MCP servers load."
3. "When Figma appears in your MCP list, click **Connect** — you'll be asked to sign in with your Figma account in your browser."
4. "After connecting, paste any Figma link and I'll implement it as code."

### Important Notes

- `.mcp.json` is listed in `.gitignore` — safe to keep in the project
- No API key or Personal Access Token is needed — Figma uses OAuth (Connected Apps)
- The user authenticates via their browser when they first connect the Figma MCP
- If the user has issues connecting, they can try disconnecting and reconnecting the Figma server in the MCP panel
