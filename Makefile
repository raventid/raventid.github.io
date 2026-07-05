EMACS ?= emacs

.PHONY: publish serve clean

# Regenerate the site (HTML at the repo root) from the org files in src/.
publish:
	$(EMACS) -Q --batch -l publish.el

# Preview locally at http://localhost:8000
serve:
	@echo "Serving on http://localhost:8000 (C-c to stop)"
	@python3 -m http.server 8000

# Drop the package/timestamp cache; next publish rebuilds everything.
clean:
	rm -rf .cache
