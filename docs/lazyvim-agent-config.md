# Lazyvim-configuration

## Install agents

Install codex:

```bash
npm install -g @openai/codex@latest
codex --version
```

Install claude code:

```
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

Start both tools

```bash
codex
claude
```

Configure a.sidekick

```bash
mkdir -p ~/.config/nvim/lua/plugins
nvim ~/.config/nvim/lua/plugins/sidekick.lua
```

Paste

```bash

return {
  {
    "folke/sidekick.nvim",
    opts = {
      -- Use Codex and Claude without requiring Copilot
      nes = { enabled = false },
    },
    keys = {
      {
        "<leader>ac",
        function()
          require("sidekick.cli").show({ name = "codex" })
        end,
        desc = "Open Codex",
      },
      {
        "<leader>al",
        function()
          require("sidekick.cli").show({ name = "claude" })
        end,
        desc = "Open Claude Code",
      },
    },
  },
}

```
