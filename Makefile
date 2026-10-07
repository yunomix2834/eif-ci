SHELL_SCRIPTS := $(shell find scripts -type f -name '*.sh' -print)

.PHONY: check shell-check

shell-check:
	@for script in $(SHELL_SCRIPTS); do \
		bash -n "$$script" || exit 1; \
	done
	@echo "Shell syntax: OK"

check: shell-check
