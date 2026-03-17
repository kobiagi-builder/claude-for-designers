---
name: prep
description: Interactive setup wizard that configures Figma and Playwright MCP servers for new users. Asks for Figma API key and writes the project .mcp.json automatically.
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

### Step 2: Ask for Figma API Key

Use the AskUserQuestion tool to ask the user for their Figma Personal Access Token.

**Important context to tell the user:**
- They can get their key from: **Figma > Settings > Personal Access Tokens** (or https://www.figma.com/developers/api#access-tokens)
- The key starts with `figd_`
- The key will be stored locally in this project only (`.mcp.json` is gitignored and will never be committed)

Ask the question clearly and simply. These are non-technical designers — keep the language friendly.

### Step 3: Write the `.mcp.json` File

Write the following to `.mcp.json` at the project root, inserting the user's Figma API key:

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": [
        "-y",
        "figma-developer-mcp",
        "--figma-api-key=USER_KEY_HERE",
        "--stdio"
      ]
    },
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-playwright"
      ]
    }
  }
}
```

Replace `USER_KEY_HERE` with the actual key the user provided.

### Step 4: Confirm and Instruct Restart

Tell the user:

1. "Setup complete! Both Figma and Playwright are now configured."
2. "**Please restart Claude Code** (close and reopen) so the MCP servers load."
3. "After restarting, you can paste any Figma link and I'll implement it as code."

### Important Notes

- `.mcp.json` is listed in `.gitignore` — the user's API key will **never** be committed to git
- If the user already has a `.mcp.json`, merge the config rather than overwriting (preserve any existing servers)
- If the key doesn't start with `figd_`, gently ask the user to double-check — it may not be a valid Figma token
- Do NOT store the key anywhere else (no `.env`, no global config)
