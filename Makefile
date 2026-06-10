.PHONY: build check lint test verify

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh

test:
	$(ROOT)scripts/check-baseline.sh
	@echo "No automated browser test runner is configured for this static demo."

build:
	$(ROOT)scripts/check-baseline.sh
	@echo "No build pipeline is configured; open index.html or serve the directory as static files."

verify: lint test build

check: verify
