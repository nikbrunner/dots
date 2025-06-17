# Global Instructions for Claude Code

## Personal Info

- Name: Nik
- Operating System: macOS
- Editor: Neovim (Primary) / Zed (Secondary)
- Terminal: WezTerm
- AI Tooling: Claude Code and Zed Agent

## General Preferences

- Don't acredit yourself as a co-author in the commits
- Don't put and add for claude code in the commit messages
- Use concise, direct but warm communication
- When I have provided you a link, always visit the website before answering
- Before answering, check yourself if there is appropriate documentation in the
  repository
- Offer to use your web fetch tool to get the information you need
- Always ask before creating new files unless absolutely necessary
- Prefer editing existing files over creating new ones if sensible

## Development Workflow

- Commit frequently with clear messages using semantic format (feat:, fix:, refactor:, etc.)
  - Check the previous commit message to understand conventions and context
  - If the branch includes a ticket number, include it in the commit message as
    a prefix (e.g. if the branch contains BCD-1234, start the commit message with
    "BCD-1234: feat/fix/refactor: ...")
- Always test changes before committing when applicable
  - Check for a `check:compile`, `check:format`, `check:types`, and `check:full` etc. in the `package.json` scripts
- Value consistency and maintainable code over clever solutions

## Tools & Environment

- Editor: Neovim
- Package Manager: Homebrew (macOS)
- Shell: Zsh with custom configuration
- Git: Use conventional commit messages with Claude Code attribution
- Terminal multiplexer strategy: WezTerm Multiplexer. Used tmux in the past

## Coding Preferences

- Clean and minimal
- Likes to use explizit and implicit types where it makes sense
  - Is not a fan of absolutes here
  - Sometimes implicit or inferred types make more sense than explicit ones
  - Sometimes its the other way around
- In terms of React prefers the dumb functional component approach in
  combination with smart containers and partials which compose the dumb
  components (See:
  https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0)
- Use clear variable and function names
- Remove unused code and clean up as you go
- Avoid `any` at all costs. At a last resort, use `unknown` instead
- Follow existing project conventions and patterns
- Self-documenting code
- Simple as possible, flexible and complex as necessary
- Prefers object arguments for functions
- Pays attention to performance and efficiency
- Avoids unnecessary comments
- Uses descriptive commit messages
- Pays emphasis on code readability and maintainability for other developers,
  especially when designing abstractions or own libraries and functions
- Is very thorough and pays attention to detail
- Avoids hacky or ad-hoc solutions
- Values typesafety and type annotations alot and likes to use generics

## Communication Style

- Be direct and concise, but warm and friendly, without too much fluff and
  preamble
- Minimize unnecessary explanations unless asked for detail
- Focus on solving the specific problem at hand
- Answer questions directly without extra preamble
- Use technical terms appropriately for the context

## Project Organization

- Keep configurations organized and well-documented
- Prefer modular approaches over monolithic files
- Use consistent naming conventions within projects
- Clean up redundant or outdated code when encountered
