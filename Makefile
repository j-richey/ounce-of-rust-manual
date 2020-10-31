# Makefile for building the documentation.
# This is a modified version of the Sphinx generated file.

SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
FEATUREDIR    = features
BUILDDIR      = build
PDFOUTPUT	  = $(wildcard $(BUILDDIR)/latex/*project*manual*.pdf)


.PHONY: all html html-open singlehtml pdf linkcheck clean help


# All simply builds all the various outputs then ensures a copy of the PDF and
# single page HTML is in the HTML output directory so these other varients can
# be downloaded.
# sed is used to fix the internal links and copy the single page HTML so
# they point to the correct location.
all: html singlehtml pdf
	@sed -r 's/href="index.html/href="singlepage.html/g' "$(BUILDDIR)/singlehtml/index.html" > "$(BUILDDIR)/html/singlepage.html"
	@cp -v "$(PDFOUTPUT)" "$(BUILDDIR)/html/"


html: _gherkin
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)"

html-open: html
	@python3 -m webbrowser -t "$(BUILDDIR)/html/index.html"

# The single HTML page is copied into the HTML directory and renamed so it can
# use the same resources. Not how the internal links are fixed up.
singlehtml: _gherkin
	@$(SPHINXBUILD) -M singlehtml "$(SOURCEDIR)" "$(BUILDDIR)"


# Note: the -E is used to ensure the LaTeX gets a clean build. Sometimes the
# HTML builds leave a dirty environment behind that cause the LaTeX builder to fail.
# TODO: reduce the amount of output from this command.
pdf: _convert_svg _gherkin
	@$(SPHINXBUILD) -M latexpdf "$(SOURCEDIR)" "$(BUILDDIR)" -E


linkcheck:
	@$(SPHINXBUILD) -M linkcheck "$(SOURCEDIR)" "$(BUILDDIR)"


clean:
	@$(SPHINXBUILD) -M clean "$(SOURCEDIR)" "$(BUILDDIR)"


help:
	@echo "Makefile for building the documentation."
	@echo ""
	@echo "Available commands:"
	@echo "  all         Builds all the different output types. (default)"
	@echo "  html        Builds standalone HTML files for the documentation."
	@echo "  html-open   Opens the manual in the default browser after building"
	@echo "              the standalone HTML files."
	@echo "  singlehtml  Builds a single HTML file of the documentation."
	@echo "  pdf         Builds a PDF of the documentation."
	@echo "  linkcheck   Checks for broken external links."
	@echo "  clean       Cleans the output directory."
	@echo "  help        Shows this help message."
	@echo ""
	@echo "For details on how to build the documentation see the README."

# Helper targets

.PHONY:  _convert_svg _gherkin

_convert_svg:
	@python3 convert-svg-to-pdf.py "$(SOURCEDIR)"

_gherkin:
	@sphinx-gherkindoc --maxtocdepth 1 --toc-name user-stories --raw-descriptions \
		"$(FEATUREDIR)" "$(SOURCEDIR)/requirements"
