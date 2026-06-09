.PHONY: build check lint test verify

lint:
	scripts/check-baseline.sh

test:
	scripts/check-baseline.sh
	@echo "No automated browser test runner is configured for this static demo."

build:
	scripts/check-baseline.sh
	@echo "No build pipeline is configured; open index.html or serve the directory as static files."

verify: lint test build

check: verify
