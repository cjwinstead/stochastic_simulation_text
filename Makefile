TEXT_FILES = $(wildcard markdown/*.md)

PANDOC_FLAGS =	--verbose \
                -fmarkdown+definition_lists \
		--pdf-engine=xelatex \
		--template=textbook_template.latex \
		--top-level-division=chapter \
		--lua-filter ./textbook.lua \
		--filter pandoc-fignos \
		--highlight-style tango \
		book_info.yaml

HTML_FLAGS =	--verbose \
                -fmarkdown+definition_lists \
		--lua-filter ./textbook.lua \
		--mathjax \
		--toc \
		--highlight-style tango 

CHUNK_FLAGS =	--verbose \
                -fmarkdown+definition_lists \
		--lua-filter ../../textbook.lua \
		-tchunkedhtml \
		--toc \
		--mathjax \
		--highlight-style tango 

.PHONY: all 
all: pdf/stochastic_simulation_text.pdf


pdf/stochastic_simulation_text.pdf: $(TEXT_FILES) FORCE
	@mkdir -p pdf
	pandoc $(TEXT_FILES) $(PANDOC_FLAGS)  -o "$@"


chunk: $(TEXT_FILES) FORCE
	@mkdir -p chunk/src
	@for x in $(TEXT_FILES); do cp $$x chunk/src/; done
	@for x in chunk/src/*.md; do sed -i 's|figures/\(.*\)\.tex|figures/svg/\1.svg|' $$x ; done
	@for x in chunk/src/*.md; do sed -i 's/# /## /' $$x ; done
	cd chunk/src; pandoc $(CHUNK_FLAGS) *.md ../../book_info.yaml -s -o ../StochasticVerification/

html/stochastic_simulation.html: $(TEXT_FILES) book_info.yaml FORCE
	mkdir -p html/src
	for x in $(TEXT_FILES); do tgt=`echo $$x | sed 's|\([[:digit:]]_\)[^/]*/\([^/]*\)$$|\1\2|'`; printf "$$tgt\n"; cp $$x html/src/$$tgt; done
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
#   make notebooks             merge solutions, build .jl and .ipynb in build/
#   make notebooks NBGRADER=1  same, with nbgrader solution delimiters
#   make check-notebooks       fail if a public source contains a solution
#   make test-course           run the course-file test suite
# ---------------------------------------------------------------------------

SOLUTIONS ?= ../stochastic_simulation_solutions
JULIA     ?= julia
NB_SOURCES = $(wildcard notebooks/M*/*.jl)
NB_LIB     = notebooks/lib/StochasticSimulationCourse.jl notebooks/lib/course_plots.jl
NB_BUILD   = build/notebooks

.PHONY: notebooks check-notebooks test-course

notebooks: check-notebooks
	@for src in $(NB_SOURCES); do \
	  sub=$$(dirname $${src#notebooks/}); name=$$(basename $$src .jl); \
	  out=$(NB_BUILD)/$$sub/$$name; mkdir -p $$out; \
	  python3 tools/solutions.py merge $$src $(SOLUTIONS)/notebooks/$$sub/$$name.solutions.jl \
	    -o $$out/$$name.jl $(if $(NBGRADER),--nbgrader,) || exit 1; \
	  cp $(NB_LIB) $$out/; \
	  jupytext --quiet --to ipynb $$out/$$name.jl || exit 1; \
	done

check-notebooks:
	@python3 tools/solutions.py check $(NB_SOURCES)

test-course:
	cd notebooks/lib && $(JULIA) test_course.jl
