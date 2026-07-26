# AI Fucks Us — slide build
#
#   make setup   download reveal.js assets (once)
#   make html    build index.html from slides.adoc
#   make serve   build, then serve at http://localhost:8000
#   make watch   rebuild on every save (leave running alongside `make serve`)
#   make clean   remove generated index.html

REVEALJS_VERSION := 5.1.0
IMAGE            := asciidoctor/docker-asciidoctor
DOCKER           := docker run --rm -v "$(CURDIR)":/documents $(IMAGE)
SOURCE           := slides.adoc
OUTPUT           := index.html

.PHONY: html serve watch setup clean

html: reveal.js $(OUTPUT)

$(OUTPUT): $(SOURCE) custom.css
	$(DOCKER) asciidoctor-revealjs $(SOURCE) -o $(OUTPUT)
	@echo "Built $(OUTPUT)"

reveal.js:
	@$(MAKE) setup

setup:
	@echo "Downloading reveal.js $(REVEALJS_VERSION)..."
	@curl -sSL "https://github.com/hakimel/reveal.js/archive/refs/tags/$(REVEALJS_VERSION).tar.gz" | tar xz
	@rm -rf reveal.js
	@mv "reveal.js-$(REVEALJS_VERSION)" reveal.js
	@echo "reveal.js $(REVEALJS_VERSION) ready."

serve: html
	@echo "Serving at http://localhost:8000  (Ctrl-C to stop)"
	@python3 -m http.server 8000

watch:
	@node watch.mjs

clean:
	@rm -f $(OUTPUT)
	@echo "Removed $(OUTPUT)"
