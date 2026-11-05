TEXT_FILES = $(wildcard markdown/*.md)

PANDOC_FLAGS =	--verbose \
                -fmarkdown+definition_lists \
		--pdf-engine=xelatex \
		--include-before-body=latex/dedication.tex \
		--top-level-division=chapter \
		--filter pandoc-crossref \
		--lua-filter ./textbook.lua \
		--syntax-highlighting=tango \
		book_info.yaml

HTML_FLAGS =	--verbose \
                -fmarkdown+definition_lists \
		--filter pandoc-crossref \
		--lua-filter ./textbook.lua \
		--math-method=mathjax \
		--toc \
		--syntax-highlighting=tango

CHUNK_FLAGS =	--verbose \
                -fmarkdown+definition_lists \
		--filter pandoc-crossref \
		--lua-filter ../../textbook.lua \
		-tchunkedhtml \
		--toc \
		--math-method=mathjax \
		--syntax-highlighting=tango

.PHONY: all 
all: pdf/stochastic_simulation_text.pdf


# The PDF is built in two steps so that the LaTeX log is kept: pandoc writes
# the LaTeX source, and latexmk compiles it with XeLaTeX in $(PDF_BUILD),
# rerunning until cross-references settle. The log, with every warning, is
# $(PDF_BUILD)/stochastic_simulation_text.log; a summary is printed after
# each build (tools/latex_warnings.py), and make pdf-warnings repeats it.
PDF_BUILD = build/pdf
PDF_NAME  = stochastic_simulation_text

pdf/stochastic_simulation_text.pdf: $(TEXT_FILES) FORCE
	@mkdir -p pdf $(PDF_BUILD)
	pandoc $(TEXT_FILES) $(PANDOC_FLAGS) -s -o $(PDF_BUILD)/$(PDF_NAME).tex
	@latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
	  -outdir=$(PDF_BUILD) $(PDF_BUILD)/$(PDF_NAME).tex > $(PDF_BUILD)/latexmk.out 2>&1 \
	  || { echo "LaTeX stopped with an error (full log: $(PDF_BUILD)/$(PDF_NAME).log):"; \
	       grep -m1 -A6 -E '^(!|[^ ]+:[0-9]+: )' $(PDF_BUILD)/$(PDF_NAME).log; exit 1; }
	@cp $(PDF_BUILD)/$(PDF_NAME).pdf $@
	@echo "Built $@. LaTeX warnings:"
	@python3 tools/latex_warnings.py $(PDF_BUILD)/$(PDF_NAME).log

.PHONY: pdf-warnings
pdf-warnings:
	@python3 tools/latex_warnings.py $(PDF_BUILD)/$(PDF_NAME).log


chunk: $(TEXT_FILES) FORCE
	@mkdir -p chunk/src
	@for x in $(TEXT_FILES); do cp $$x chunk/src/; done
	@for x in chunk/src/*.md; do sed -i 's|figures/\(.*\)\.tex|figures/svg/\1.svg|' $$x ; done
	@for x in chunk/src/*.md; do sed -i 's/# /## /' $$x ; done
	cd chunk/src; pandoc $(CHUNK_FLAGS) *.md ../../book_info.yaml -s -o ../StochasticVerification/

html/stochastic_simulation.html: $(TEXT_FILES) book_info.yaml FORCE
	mkdir -p html/src
	for x in $(TEXT_FILES); do cp $$x html/src/; done
	@for x in html/src/*.md; do sed -i 's|figures/\(.*\)\.tex|figures/svg/\1.svg|' $$x ; done
	pandoc html/src/*.md book_info.yaml $(HTML_FLAGS) -s -o html/stochastic_verification.html

FORCE:
	


# ---------------------------------------------------------------------------
# Notebooks
#
#   notebooks/M*/NAME.jl            public sources; solution regions are empty
#   notebooks/lib/*.jl              course files, copied next to every notebook
#   $(SOLUTIONS)/notebooks/M*/NAME.solutions.jl   private solutions
#
#   make check                 run every check below
#   make check-keyterms        Key Terms match the bold terms in each chapter
#   make notebooks             merge solutions, build .jl and .ipynb in build/
#   make notebooks NBGRADER=1  same, with nbgrader solution delimiters
#   make check-notebooks       fail if a public source contains a solution
#
# Julia environment (notebooks/Project.toml and notebooks/Manifest.toml)
#
#   make env                   update the package registry, then install the
#                              pinned packages; run once per machine
#   make env-update            update packages within the compat bounds in
#                              Project.toml, rewriting Manifest.toml (review the
#                              change, run make test, and commit both files)
#   make test                  run all three tests below
#   make test-course           the course-file test suite
#   make test-examples         every Julia example in the text, each on its own
#   make test-notebooks        every notebook, built with its solutions
#   make notebooks-pdf         run every notebook (with solutions) and render it,
#                              outputs and plots included, as a review copy in
#                              pdf/course_notebooks.pdf, styled like the text
#   make release               checks, tests, PDF and notebooks: the full build
# ---------------------------------------------------------------------------

SOLUTIONS ?= ../stochastic_simulation_solutions
JULIA     ?= julia
JULIA_ENV  = notebooks
JULIA_RUN  = GKSwstype=100 $(JULIA) --project=$(abspath $(JULIA_ENV))
NB_SOURCES = $(wildcard notebooks/M*/*.jl)
NB_LIB     = notebooks/lib/StochasticSimulationCourse.jl notebooks/lib/course_plots.jl
NB_BUILD   = build/notebooks

.PHONY: check check-keyterms notebooks check-notebooks env env-update \
	test test-course test-examples test-notebooks notebooks-pdf release

check: check-keyterms check-notebooks

check-keyterms:
	@python3 tools/check_keyterms.py $(TEXT_FILES)

notebooks: check-notebooks
	@for src in $(NB_SOURCES); do \
	  sub=$$(dirname $${src#notebooks/}); name=$$(basename $$src .jl); \
	  out=$(NB_BUILD)/$$sub/$$name; mkdir -p $$out; \
	  python3 tools/solutions.py merge $$src $(SOLUTIONS)/notebooks/$$sub/$$name.solutions.jl \
	    -o $$out/$$name.jl $(if $(NBGRADER),--nbgrader,) || exit 1; \
	  cp $(NB_LIB) $$out/; \
	  jupytext --quiet --to ipynb $$out/$$name.jl || exit 1; \
	done
	@cp $(JULIA_ENV)/Project.toml $(JULIA_ENV)/Manifest.toml $(NB_BUILD)/

check-notebooks:
	@python3 tools/solutions.py check $(NB_SOURCES)

env:
	$(JULIA_RUN) -e 'using Pkg; Pkg.Registry.update(); Pkg.instantiate(); Pkg.precompile()'

env-update:
	$(JULIA_RUN) -e 'using Pkg; Pkg.update(); Pkg.status()'

test: test-course test-examples test-notebooks

test-course:
	cd notebooks/lib && $(JULIA_RUN) test_course.jl

test-examples:
	@mkdir -p build/examples && cp $(NB_LIB) build/examples/
	@failed=0; for f in $$(python3 tools/text_examples.py build/examples $(TEXT_FILES)); do \
	  if (cd build/examples && $(JULIA_RUN) $$f > $${f%.jl}.out 2>&1); then echo "ok      $$f"; \
	  else echo "FAILED  $$f (see build/examples/$${f%.jl}.out)"; failed=1; fi; \
	done; exit $$failed

test-notebooks: notebooks
	@failed=0; for d in $(NB_BUILD)/M*/*/; do name=$$(basename $$d); \
	  if (cd $$d && $(JULIA_RUN) $$name.jl > $$name.out 2>&1); then echo "ok      $$name"; \
	  else echo "FAILED  $$name (see $$d$$name.out)"; failed=1; fi; \
	done; exit $$failed

NB_REVIEW = build/notebooks-review
NB_PANDOC_FLAGS = $(filter-out --include-before-body=%,$(PANDOC_FLAGS))

notebooks-pdf: notebooks
	@rm -rf $(NB_REVIEW) && mkdir -p $(NB_REVIEW) $(PDF_BUILD)
	$(JULIA_RUN) tools/render_notebooks.jl $(NB_BUILD) $(NB_REVIEW)
	pandoc $(NB_REVIEW)/M*.md $(NB_PANDOC_FLAGS) \
	  -M title="Course Notebooks: Review Copy" -M subtitle="with solutions and hidden tests" \
	  -M lof=false -M lot=false --resource-path=$(NB_REVIEW) \
	  -s -o $(PDF_BUILD)/course_notebooks.tex
	@latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error \
	  -outdir=$(PDF_BUILD) $(PDF_BUILD)/course_notebooks.tex > $(PDF_BUILD)/latexmk-notebooks.out 2>&1 \
	  || { echo "LaTeX stopped with an error (full log: $(PDF_BUILD)/course_notebooks.log):"; \
	       grep -m1 -A6 -E '^(!|[^ ]+:[0-9]+: )' $(PDF_BUILD)/course_notebooks.log; exit 1; }
	@mkdir -p pdf && cp $(PDF_BUILD)/course_notebooks.pdf pdf/
	@echo "Built pdf/course_notebooks.pdf. LaTeX warnings:"
	@python3 tools/latex_warnings.py $(PDF_BUILD)/course_notebooks.log

release: check test all notebooks notebooks-pdf
