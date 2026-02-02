.PHONY: fmt-sh fmt-sh-check
SHELL_PATHS := \
	scripts/ \
	common/.local/bin/ \
	arch/.local/bin/ \
	common/.config/tmux/layouts/ \
	common/.config/tmux/scripts/ \
	common/.config/nvim/scripts/

fmt-sh:
	shfmt -w $(SHELL_PATHS)

fmt-sh-check:
	shfmt -d $(SHELL_PATHS)
