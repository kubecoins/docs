OS := $(shell go env GOOS)
ARCH := $(shell go env GOARCH)
UNAME := $(shell uname -s)

BIN_DIR := bin
SHARE_DIR := share

$(BIN_DIR):
	mkdir -p $@

$(SHARE_DIR):
	mkdir -p $@

MDBOOK_VERSION := v0.4.6
BOOKS_DIR := book
RUST_TARGET := unknown-$(OS)-gnu
MDBOOK_EXTRACT_COMMAND := tar xfvz $(SHARE_DIR)/mdbook.tar.gz -C $(BIN_DIR)
MDBOOK_ARCHIVE_EXT := .tar.gz
ifeq ($(OS), windows)
	RUST_TARGET := pc-windows-msvc
	MDBOOK_ARCHIVE_EXT := .zip
	MDBOOK_EXTRACT_COMMAND := unzip -d /tmp
endif

ifeq ($(OS), darwin)
	RUST_TARGET := apple-darwin
endif
MDBOOK := $(BIN_DIR)/mdbook

##@ Docs

MDBOOK_SHARE := $(SHARE_DIR)/mdbook$(MDBOOK_ARCHIVE_EXT)
$(MDBOOK_SHARE): $(SHARE_DIR)
	curl -sL -o $(MDBOOK_SHARE) "https://github.com/rust-lang/mdBook/releases/download/$(MDBOOK_VERSION)/mdBook-$(MDBOOK_VERSION)-x86_64-$(RUST_TARGET)$(MDBOOK_ARCHIVE_EXT)"

MDBOOK := $(BIN_DIR)/mdbook
$(MDBOOK): $(BIN_DIR) $(MDBOOK_SHARE)
	$(MDBOOK_EXTRACT_COMMAND)
	chmod +x $@
	touch -m $@


.PHONY: docs-build
docs-build: $(MDBOOK) ## Build the book
	$(MDBOOK) build $(BOOKS_DIR)

.PHONY: docs-serve
docs-serve: $(MDBOOK) ## Run a local webserver with the compiled book
	$(MDBOOK) serve $(BOOKS_DIR)

.PHONY: docs-clean
docs-clean:
	rm -rf $(BOOKS_DIR)/book