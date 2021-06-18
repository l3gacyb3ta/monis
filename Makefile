CRYSTAL_BIN ?= crystal
SHARDS_BIN ?= shards
PREFIX ?= /usr/local
SHARD_BIN ?= ../../bin
CRFLAGS ?= -p --production

build:
	$(SHARDS_BIN) build $(CRFLAGS)
clean:
	rm -f bin
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/monis $(PREFIX)/bin
bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/monis $(SHARD_BIN)
test: build
	$(CRYSTAL_BIN) spec
	./bin/monis --all