# Pins Plugin - Learning Project

## Project Context
This is Nik's learning project for understanding Neovim plugin development, Lua patterns, and the Neovim API. The goal is hands-on learning through building a file pinning system.

## Learning Approach
- **Student-driven development**: Nik writes the code, Claude provides guidance and explains concepts
- **Question-based learning**: Help with specific API questions, debugging, and understanding patterns
- **Concept explanations**: Focus on *why* things work, not just *what* to write

## Current Learning Focus
- Understanding buffer vs window management in Neovim
- Working with extmarks for visual highlighting
- Lua table manipulation and functional patterns
- API indexing differences (0-based vs 1-based, end-inclusive vs end-exclusive)

## Key Learning Areas

### Neovim API Patterns
- Buffer lifecycle and validation (`nvim_buf_is_valid`, `nvim_win_is_valid`)
- Extmarks system for decorations and highlights
- Floating window configuration and management
- Namespace usage for organizing marks/highlights

### Lua Development Patterns
- Module structure with `local M = {}` pattern
- Using `self` with colon syntax `M:function()`
- Table manipulation (`ipairs`, `table.insert`, `table.remove`)
- Type annotations with `---@class` and `---@type`

### Problem-Solving Approaches
- When to use explicit values vs API shortcuts (like `-1` for end-of-line)
- Debugging techniques: print statements, `vim.inspect()`, API validation
- Error handling patterns in dynamic environments

## Help File References
Key documentation paths for quick reference:
- `/Users/nbr/.local/share/bob/nightly/share/nvim/runtime/doc/api.txt`
- Focus areas: extmarks, buffer management, window configuration

## Learning Philosophy
**Ask specific questions** rather than "how do I implement X". Better questions:
- "Why does this API call fail?"
- "What's the difference between these two approaches?"
- "How do I debug this behavior?"

**Experiment first**, then ask for explanations of what you observed.

**Break down complex features** into smaller learning steps rather than trying to build everything at once.