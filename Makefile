BIN     = token
NIMBLE  = nimble
# Make sure VERSION is aligned with token.nimble
VERSION = 0.1.1

SOURCES = $(shell find src/ -name '*.nim')

PREFIX  ?= /usr/local
DATADIR ?= $(PREFIX)/share
MANDIR  ?= $(DATADIR)/man

NIMFLAGS ?= -d:release

.PHONY: all clean dist install test

all: $(BIN)

$(BIN): $(SOURCES)
	$(NIMBLE) build $(NIMFLAGS)

install: $(BIN) man
	mkdir -p ${DESTDIR}$(PREFIX)/bin
	cp -f $(BIN) ${DESTDIR}$(PREFIX)/bin
	chmod 755 ${DESTDIR}$(PREFIX)/bin/$(BIN)
	mkdir -p ${DESTDIR}$(MANDIR)/man1
	sed "s/VERSION/$(VERSION)/g" man/token.1 > ${DESTDIR}$(MANDIR)/man1/token.1
	chmod 644 ${DESTDIR}$(MANDIR)/man1/token.1
	cp -r share/. ${DESTDIR}$(DATADIR)/

test: $(SOURCES) $(wildcard tests/*.nim)
	$(NIMBLE) test

clean:
	rm -f token tests/run_tests
	rm -f token-$(VERSION).tar.gz

dist: clean
	mkdir -p "token-$(VERSION)/"
	cp -r src/ man/ tests/ share/ "token-$(VERSION)/"
	cp -f Makefile LICENSE README.rst token.nimble "token-$(VERSION)/"
	tar -c -f "token-$(VERSION).tar" "token-$(VERSION)/"
	rm -rf "token-$(VERSION)/"
	gzip token-$(VERSION).tar

