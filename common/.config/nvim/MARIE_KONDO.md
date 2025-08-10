# Going Marie Kondo on my Neovim Config

## 📊 Current Status: 55 Total Plugins

- **Loaded:** 36 plugins
- **Not Loaded (lazy):** 15 plugins
- **Disabled:** 4 plugins
- **Target:** ~20-25 plugins (55% reduction)

---

## Note

I should probably start a new branch for this, and just run with it.
Reduce everything to the bare minimum, and just see how it goes.

## Keymaps

Another goal would be to mostly stick with the defaults.
There are also new LSP keymaps for example

## Legend

- #keep Keep
- #decide Decide
- #research Research
- #archive Archive

## 🗂️ Complete Plugin Inventory

### ✅ Core Essentials (MUST KEEP - 11 plugins)

- [x] #keep **nvim-treesitter** - Syntax highlighting, text objects
  - Here it would be important to switch to the new `main` branch. Currently we are on
    the old `master` branch. This would also be important for the Black Atom
    development process.
- [ ] #decide **blink.cmp** - Completion engine
  - There is also now built in vim completion, but I don't know which vim version
  - But I really like the command line completion from blink.nvim
  - I would like to try out the built in vim completion
  - There is also I think a option or command which triggers the autocompletion
    automatically? I am not sure.
  - `mini.completion` could also be tried out
- [x] #keep **LuaSnip** - Snippet engine
  - There is also `vim.snippet` (:h vim.snippet) now
    - #keep **friendly-snippets** - Snippet collection
- [x] #keep **Snacks.nvim** - Swiss army knife (picker, utilities)
- [ ] #keep **Mason.nvim** - LSP installer/manager
- [x] #keep **conform.nvim** - Formatting
- [x] #keep **nvim-lint** - Linting
- [x] #keep **lazydev.nvim** - Neovim Lua development
- [x] #archive ~**wezterm-types** - WezTerm type definitions~ ✅ ARCHIVED
  - Can be uninstalled - I am using ghostty atm
- [x] #keep **lazy.nvim** - Plugin manager
  - I would be fine by switching to the new built-in plugin manager `vim.pack` but I
    really like the `lazy-lock.json` file from `lazy.nvim`, but maybe if I not update
    all the time I maybe not need it.

### [x] 📝 TypeScript Development (KEEP - 3 plugins)

- [x] #keep **tsc.nvim** - TypeScript compiler integration
- [x] #keep **ts-error-translator.nvim** - Readable TS errors
- [x] #keep **trouble.nvim** - Diagnostics list (integrates with tsc.nvim)

### [x] 🎨 Colorschemes (Keep 2-3)

- [x] #keep **black-atom** - Custom colorscheme
- [x] #archive **github-nvim-theme** - GitHub themes
- [x] #archive **rose-pine** - Rose Pine theme

### [x] 📁 File Explorers (Choose ONE)

Here its really hard for me to decide which one to use.

- [x] #decide **fyler.nvim** - LOADED - Hybrid tree/buffer explorer
- [x] #decide **oil.nvim** - DISABLED - Pure buffer editing
- [x] #decide **yazi.nvim** - DISABLED - Terminal file manager
- [x] #decide **Snacks explorer** - Available but not configured
- [x] #decide **mini.files** - Not installed - Buffer-like with sync

> I decided on `mini.files`.

### [x] 🔍 File Pickers (Choose ONE)

Fzf-Lua is pretty good, but I really configured Snacks pretty good.
The FzfLua Frecency picker is much better though.
I could really try to switch to FzfLua again, because the Frecency Picker makes a lot
of other pickers obsolete.

- #decide **Snacks picker** - Part of Snacks.nvim - Currently used
- #decide **fzf-lua** - DISABLED - Powerful alternative
- #decide **fzf-lua-frecency** - Part of fzf-lua

#research I would also like to try out `mini.pick`. Does it have a smart / frecency picker?
Maybe from a third party or user?
See here: https://github.com/echasnovski/mini.nvim/discussions/609

> I decided on `mini.pick`. I even got frecency to work with it.

### 🚀 Navigation & Movement (Review each)

- [x] #archive **flash.nvim** - NOT LOADED - Jump anywhere
  - It is pretty good, but it also has some querks, that I cant resolve.
  - For example it auto jumps to the first and only match.
  - I think I should try to archive this.
- #keep **treewalker.nvim** - LOADED - AST-based movement
- [x] #decide **whatthejump.nvim** - NOT LOADED - Enhanced jumplist
  - This is pretty good! It is very small
  - But I can also try to archive this.
  - I also have `<leader>aj` (App Jumps) for this
  - Archived
- [ ] #decide **Navigator.nvim** - NOT LOADED - Tmux navigation
  - Well I am pretty used to this now, but I could try to leave without this
  - But then I would also need mappings to quickly navigate between tmux panes

### 🔧 Git Integration (Review each)

- #keep **gitsigns.nvim** - LOADED - Git signs in gutter
  - Smaller alternative? Something from `mini` maybe?
- #decide **gitlinker.nvim** - LOADED - Generate GitHub links
  - Often used, but maybe Snacks also have something similar?
  - ~/.local/share/nvim/lazy/snacks.nvim/doc/snacks-gitbrowse.txt
- [ ] **Snacks git** - Part of Snacks.nvim

### 🎯 UI & Visual (Review each)

- #decide **barbecue.nvim** - LOADED - Breadcrumbs
  - **nvim-navic** - LOADED - Required by barbecue
    - Part of barbecue
  - Generally this is very good, but I could also replace this via
    treesitter-context
  - Or maybe there is a modern alternative?
- #decide **bufferline.nvim** - NOT LOADED - Buffer tabs
  - I use tabs pretty often, so I want somekind of styling, but maybe we could just
    do this ourselves with a little custom local plugin?
- #decide **which-key.nvim** - LOADED - Keybinding hints
  - This is good, but could be replaced by mini.clues or how it is called
- #keep **mini.statusline** - LOADED - Statusline
  - Thats fine, but maybe we could just do this ourselves with a little custom local plugin?
- #decide **mini.icons** - LOADED - Icons everywhere
  - I want to try to live without icons
- #decide **bmessages.nvim** - LOADED - Message buffer
  - I find this useful for development, but I can try to live without it
  - All I want to have is to have the ability to open the messages as a buffer
    (Custom Local Plugin?)
  - For notfications logs I have Snacks

### ✏️ Editing Enhancement (Review each)

I also still unsatisfied with the automatically correct indentation.
I saw the **tpope/vim-sleuth** plugin, which I should try out.
This is one of the most important unsatisfing problems for me right now.
#research I don't know how other people solve this.

- #keep **mini.surround** - LOADED - Surround operations
  - Honestly I am using this pretty rarely
- #keep **mini.ai** - LOADED - Text objects
  - Not sure I need this
  - What can I even do with this?
- #decide **nvim-ts-autotag** - LOADED - Auto close/rename tags
  - Yes this is pretty good, but I could also live without it
- #research **ts-comments.nvim** - LOADED - Context-aware comments
  - I think this is not working well for jsx/tsx files atm, and folke is on vacation
  - Are there any issues on the repo?
  - Are there alternatives?
- #keep **timber.nvim** - NOT LOADED - Debug log insertion
  - Using pretty often, but
- #research **undotree** - NOT LOADED - Undo visualization
  - Very good in combination with Snacks
  - But does `Snacks.picker.undo(opts?)` even need the undotree?

### 🛠️ Development Tools (Review each)

- #keep **kulala.nvim** - LOADED - REST client
  - I am using it, but I could also use a GUI client maybe
  - I think I want to keep that
- #keep **qmk.nvim** - LOADED - Keyboard firmware
  - Occasionally I need this
- #keep **grug-far.nvim** - LOADED - Search/replace
  - This is very good
- #decide **SchemaStore.nvim** - LOADED - JSON schemas
  - I find this very useful
  - But I can live without it, since I could just use the documentation

### 📝 Note Taking (Review each)

- #keep **gitpad.nvim** - NOT LOADED - Project notes
- #research/#decide **obsidian.nvim** - NOT LOADED - Obsidian integration
  - Really a pain point for me.
  - This could be very good and also is very well maintained, but it needs a lot of
    setup boilerplate, when I could just use the Obsidian app.
  - But I really would like to write my notes in the terminal
- #research/#decide **markdown-tools.nvim** - NOT LOADED - Markdown utilities
  - This could be very good as a general purpose markdown plugin, but conflicts
    sometimes with **obsidian.nvim**
  - Also it it does not have a toggle checkbox command. (create checkbox if there is
    non, if there is a checkbox, toggle it). **obsidian.nvim** has this.

### 🤖 AI/Completion (Review each)

- #keep **supermaven-nvim** - LOADED - AI completion
- [x] #archive **codecompanion.nvim** - NOT LOADED - AI chat
  - **codecompanion-history.nvim** - NOT LOADED - Chat history
  - I mainly use Claude Code or OpenCode now
  - Archived

### 🔌 Utilities (Review each)

- #keep **persistence.nvim** - LOADED - Session management
  - This is pretty good, but I can't get auto load to work.
  - I can setup auto load, but then the tree sitter highlighting is broken.
- #decide **helpview.nvim** - NOT LOADED - Better help pages
  - Nice to have
- #keep **ccc.nvim** - NOT LOADED - Color picker
  - Imporant for my Black Atom development
  - Are there better alternatives?
- #decide **plenary.nvim** - NOT LOADED - Lua utilities (dependency)
  - Would be nice to not need this

### 🗑️ Already Disabled (DELETE)

- [x] #archive **arrow.nvim** - DISABLED - Harpoon alternative
  - I was unsatisfied with this.
  - I could try to just use global marks and the Snacks.picker.marks() function.

---

## 📈 Potential Outcomes

### Ultra Minimal (~20 plugins)

Core (11) + TS tools (3) + 1 colorscheme + 1 explorer + gitsigns + mini modules (4) = **20 plugins**

### Balanced (~25 plugins)

Ultra Minimal + which-key + persistence + flash + 2 more colorschemes = **25 plugins**

### Comfortable (~30 plugins)

Balanced + barbecue/navic + gitlinker + supermaven + selected tools = **30 plugins**
