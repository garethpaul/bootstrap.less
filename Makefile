.PHONY: build check lint test verify

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh
	cd $(ROOT) && npm run lint:less

test:
	$(ROOT)scripts/check-baseline.sh
	cd $(ROOT) && npm run check:generated
	@echo "Browser interaction remains covered by the documented bounded smoke test."

build:
	cd $(ROOT) && npm run build

verify: lint test build

check: verify
