ENDPOINT ?= polygon.streamingfast.io:443
CARGO_VERSION := $(shell cargo version 2>/dev/null)

.PHONY: build
build:
ifdef CARGO_VERSION
	cargo build --target wasm32-unknown-unknown --release
else
	@echo "Building substreams target using Docker. To speed up this step, install a Rust development environment."
	docker run --rm -ti --init -v ${PWD}:/usr/src --workdir /usr/src/ rust:bullseye cargo build --target wasm32-unknown-unknown --release
endif

.PHONY: run
run: build
	substreams run -e $(ENDPOINT) substreams.yaml db_out $(if $(START_BLOCK),-s $(START_BLOCK)) $(if $(STOP_BLOCK),-t $(STOP_BLOCK))

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out $(if $(START_BLOCK),-s $(START_BLOCK)) $(if $(STOP_BLOCK),-t $(STOP_BLOCK))

.PHONY: protogen
protogen:
	substreams protogen ./substreams.yaml --output-path="core/src/pb" --exclude-paths="sf/substreams,google"

.PHONY: pack
pack: build
	substreams pack substreams.yaml
