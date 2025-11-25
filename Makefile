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
	
