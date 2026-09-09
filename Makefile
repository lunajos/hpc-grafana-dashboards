.PHONY: check

check:
	@if command -v jq >/dev/null; then find dashboards -name '*.json' -print0 | xargs -0 -n1 jq empty; else echo "SKIP: jq not installed"; fi
	@if command -v promtool >/dev/null; then promtool check rules prometheus/rules/*.yml; else echo "SKIP: promtool not installed"; fi
	@echo "Validation complete."
