# Makefile for rendering the website
SHELL := pwsh.exe

# Define the output directory
FREEZE_DIR := _freeze

# Define the render command
QUARTO_CMD := quarto
RENDER_CMD := $(QUARTO_CMD) render
PREVIEW_CMD := $(QUARTO_CMD) preview
PUBLISH_CMD := $(QUARTO_CMD) publish gh-pages
PWSH_CMD := pwsh.exe -Command

# Define the target for rendering all the website
all: render print

README.md: _README.qmd
		$(RENDER_CMD) _README.qmd

# Render the pre tutorial website

render: index.html

index.html: index.qmd
		$(RENDER_CMD) $<

preview:
		$(PREVIEW_CMD)

publish:
		$(PUBLISH_CMD)

# Define the clean target
clean: clean-output clean-freeze clean-print

clean-output:
ifeq ($(OS),Windows_NT)
		$(PWSH_CMD) "Remove-Item -Force index*.html"
		$(PWSH_CMD) "if (Test-Path index_files) {Remove-Item -Recurse -Force index_files}"
		$(PWSH_CMD) "if (Test-Path index_cache) {Remove-Item -Recurse -Force index_cache}"
else
		rm index*.html
		rm -rf index_files
		rm -rf index_cache
endif

clean-freeze:
ifeq ($(OS),Windows_NT)
		$(PWSH_CMD) "if (Test-Path $(FREEZE_DIR)) { Remove-Item -Recurse -Force $(FREEZE_DIR) }"
else
		[ -d $(FREEZE_DIR) ] && rm -rf $(FREEZE_DIR) || true
endif

clean-print:
ifeq ($(OS),Windows_NT)
		$(PWSH_CMD) "Remove-Item -Force slides-*.pdf"
else
		rm -f slides-*.pdf
endif

print: slides-full.pdf

slides-full.pdf: index.html
ifeq ($(OS),Windows_NT)
		$(PWSH_CMD) "docker run --rm -t -v .:/slides astefanutti/decktape -s 1280x720 generic /slides/$< $@"
else
	docker run --rm -t -v .:/slides astefanutti/decktape -s 1280x720 generic /slides/$< $@
endif

print-simple: slides-simple.pdf

slides-simple.pdf: index.html
ifeq ($(OS),Windows_NT)
		$(PWSH_CMD) "docker run --rm -t -v .:/slides astefanutti/decktape -s 1280x720 reveal /slides/$< $@"
else
	docker run --rm -t -v .:/slides astefanutti/decktape -s 1280x720 reveal /slides/$< $@
endif

print-screenshot: slides-screenshot.pdf

slides-screenshot.pdf: index.html
ifeq ($(OS),Windows_NT)
		$(PWSH_CMD) "docker run --rm -t -v .:/slides astefanutti/decktape -s 1280x720  --screenshots-size=1280x720 reveal /slides/$< $@"
else
	docker run --rm -t -v .:/slides astefanutti/decktape -s 1280x720 --screenshots-size=1280x720 reveal /slides/$< $@
endif