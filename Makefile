.PHONY: fmt install-git-hooks

SHELL_PATHS := \
	scripts/ \
	common/.local/bin/ \
	arch/.local/bin/ \
	common/.config/tmux/layouts/ \
	common/.config/tmux/scripts/ \
	common/.config/nvim/scripts/

fmt:
	npx prettier --write "**/*.md"
	shfmt -w $(SHELL_PATHS)

install-git-hooks:
	./scripts/setup-hooks.sh
