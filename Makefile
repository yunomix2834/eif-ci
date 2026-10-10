.PHONY: check shell-check test

shell-check:
	bash scripts/check-shell.sh

test:
	bash scripts/tests/release.sh

check: shell-check test
