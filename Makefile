.PHONY: fmt

SHELL_PATHS := \
	scripts/ \
	common/.local/bin/ \
	arch/.local/bin/ \
	common/.config/tmux/layouts/ \
	common/.config/tmux/scripts/ \

fmt:
	npx prettier --write "**/*.md"
	shfmt -w $(SHELL_PATHS)
