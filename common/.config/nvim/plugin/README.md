# Neovim Plugin Scripts

Custom plugin scripts for Neovim.

## cerebras-completion.lua

AI-powered inline completions using Cerebras inference API. Supermaven-style ghost text with Tab to accept.

### Requirements

- `CEREBRAS_API_KEY` environment variable (get from [Cerebras Cloud](https://cloud.cerebras.ai/))
- `curl` for API requests

### Keymaps

| Key | Action |
|-----|--------|
| `<Tab>` | Accept full completion |
| `<S-Tab>` | Accept first word |
| `<C-]>` | Dismiss completion |
| `<leader>aoa` | Toggle auto-completion |

### Commands

- `:CerebrasStatus` - Show current status, model, and pricing

### Available Models (Standard API)

| Model ID | Name | Pricing (in/out per M) |
|----------|------|------------------------|
| `qwen-3-32b` | Qwen3 32B | $0.20 / $0.20 |
| `qwen-3-235b-a22b-instruct-2507` | Qwen3 235B Instruct | $0.60 / $1.20 |
| `llama-3.3-70b` | Llama 3.3 70B | $0.20 / $0.20 |
| `llama3.1-8b` | Llama 3.1 8B | $0.10 / $0.10 |

### Cerebras Code Subscription Models ($50-200/month)

| Model ID | Name | FIM Support |
|----------|------|-------------|
| `qwen-3-coder-480b` | Qwen3 Coder 480B | Yes |

### Links

- [Cerebras Homepage](https://cerebras.ai/)
- [Cerebras Cloud Console](https://cloud.cerebras.ai/)
- [Inference Docs](https://inference-docs.cerebras.ai/)
- [Models Overview](https://inference-docs.cerebras.ai/models/overview)
- [API Reference - List Models](https://inference-docs.cerebras.ai/api-reference/models/list-models)
- [Completions API](https://inference-docs.cerebras.ai/api-reference/completions/create-completion)

### Configuration

Edit the `config` table in `cerebras-completion.lua`:

```lua
local config = {
    enabled = true,
    debounce_ms = 150,           -- delay before requesting completion
    max_context_lines = 200,     -- lines before cursor (nil = full file)
    max_file_size = 100000,      -- skip files larger than 100KB
    model = "qwen-3-235b-a22b-instruct-2507",
    max_tokens = 128,
    temperature = 0.2,
}
```
