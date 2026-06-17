# Personal Zed fork — common commands.
#
# Daily driver: `make install` builds a release app and installs it into
# /Applications. `make run` is a debug build for quick checks (slow at runtime).
# Pull in changes from the original Zed with `make sync` (merge, no force-push)
# or `make sync-rebase` (clean history, then `make push-force`).
#
# Settings/data are shared with any other Zed install (not channel-separated),
# so don't run the official Zed and this fork at the same time, or isolate this
# one with `zed --user-data-dir <dir>`.

UPSTREAM_URL := https://github.com/zed-industries/zed.git
UPSTREAM_BRANCH := main

.DEFAULT_GOAL := help
.PHONY: help run build bundle install clippy fmt test \
        upstream-init fetch-upstream sync sync-rebase push push-force

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

## --- build & run ---
run: ## Debug build + run (fast iteration, slow runtime)
	cargo run

build: ## Release build (binary at target/release/zed)
	cargo build --release

bundle: ## Build a release .app/.dmg (script/bundle-mac)
	script/bundle-mac

install: ## Build release and install Zed.app into /Applications
	script/bundle-mac -i

## --- quality ---
clippy: ## Lint with the project's clippy script
	./script/clippy

fmt: ## Format the code
	cargo fmt

test: ## Run the test suite (heavy)
	cargo test --workspace

## --- upstream sync ---
upstream-init: ## Add the 'upstream' remote (zed-industries/zed) if missing
	@git remote get-url upstream >/dev/null 2>&1 || git remote add upstream $(UPSTREAM_URL)
	@git remote -v | grep upstream

fetch-upstream: upstream-init ## Fetch latest from upstream
	git fetch upstream

sync: fetch-upstream ## Merge upstream/main into the current branch (no force-push)
	git merge upstream/$(UPSTREAM_BRANCH)

sync-rebase: fetch-upstream ## Rebase the current branch onto upstream/main (needs push-force)
	git rebase upstream/$(UPSTREAM_BRANCH)

## --- push ---
push: ## Push the current branch to your fork (origin)
	git push origin HEAD

push-force: ## Force-push after a rebase (safe --force-with-lease)
	git push --force-with-lease origin HEAD
