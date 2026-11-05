# Stochastic Verification with Importance Sampling

A short open-source textbook on  statistical verification and estimation methods for Markov processes. Topics include measure theory, importance sampling, stratified sampling, and applications to discrete-time and continuous-time Markov processes. Simulation examples and assignments using Julia and PRISM languages.

This is a work-in-progress and is undergoing a lot of revision. All content is released as-is under the **Creative Commons Attribution and Share-Alike (CC-BY-SA) version 4.0**. In accordance with the terms of this license, all future revisions and versions shall carry the same open-source license terms.



# Dependencies

The text is written in Markdown and LaTeX and built with pandoc and GNU make.
It requires pandoc 3.13 with the `pandoc-crossref` filter, which numbers
figures, equations, tables and sections and resolves references to them.
`pandoc-crossref` is built for a specific pandoc release, so install a matching
pair (for example, from the release page of
[pandoc-crossref](https://github.com/lierdakil/pandoc-crossref/releases) or from
conda-forge). The PDF is typeset with `xelatex`.

The PDF uses pandoc's default LaTeX template. The book's own setup is in two
small files: `latex/preamble.tex` (fonts, TikZ and pgfplots, cleveref, the
Example boxes, title and chapter styling) and `latex/dedication.tex`. Page
layout and the lists of contents, figures and tables are set in
`book_info.yaml`. A full TeX Live or MiKTeX installation has every package the
build needs, including the fonts: DejaVu Serif for text and JuliaMono for code
(Everson Mono is used instead when it is installed).

## Cross-reference syntax

Label a figure, equation or table, then refer to it:

```
![Caption text.](figures/name.tex){#fig:name}

$$ \tilde{\xi} = \frac{1}{N}\sum_{i=1}^N h(y_i)\,\ell(y_i) $$ {#eq:is-estimator}

See @fig:name and @eq:is-estimator.   @Fig:name begins a sentence.
```

In the PDF, references go through `cleveref` and read "Figure 3.1",
"Equation 4.2"; the names are set in `book_info.yaml`.

## Key Terms

A term is defined where it first appears in **bold**, and each chapter ends
with a `## Key Terms` section listing its terms, under the same names, in the
order the chapter defines them. Use *italics*, not bold, for emphasis. An
entry may list synonyms separated by commas (`Expectation, Expected Value`).
`make check-keyterms` reports bold terms without entries, entries without bold
terms, entries out of order, and terms bolded twice; `make check` runs every
check.

## Draft text

New or substantially revised text that awaits the author's review is marked
`draft`. It is set in dark red in the PDF and the HTML; remove the markers once
the text is accepted.

```
::: {.draft}
A whole new section or paragraph...
:::

A sentence with [a revised phrase]{.draft} inside.

![[A caption to review.]{.draft}](figures/name.tex){#fig:name}
```

# Julia environment and builds

The text's examples and the notebooks share one Julia environment,
`notebooks/Project.toml` and `notebooks/Manifest.toml`, which pins Julia 1.12
and every package version. Both files are committed, so every machine and the
JupyterHub image run the same code. The Makefile is the single entry point:

```
make env            install the pinned packages (once per machine)
make check          Key Terms and notebook-solution checks
make test           course-file tests, every Julia example in the text
                    (each run on its own), and every notebook with solutions
make notebooks-pdf  run the notebooks and render them, with solutions,
                    output and plots, in pdf/course_notebooks.pdf
make release        check, test, the PDF, and the notebooks, in build/
make env-update     update packages within Project.toml's compat bounds
```

After `make env-update`, review the change to `Manifest.toml`, run
`make test`, and commit both files together.

The PDF is built in two steps: pandoc writes the LaTeX source to `build/pdf`,
and `latexmk` compiles it there with XeLaTeX. The full log,
`build/pdf/stochastic_simulation_text.log`, is kept, and each build ends with a
summary of missing characters, overfull boxes, undefined references and other
warnings, each with the file being read at the time (`make pdf-warnings`
repeats it). A LaTeX error stops the build and prints the error with its line
in the generated `.tex` file. `latexmk` comes with TeX Live; with MiKTeX it
also needs Perl.

To work in the environment by hand, start `julia --project=notebooks` and use
`instantiate`, not `resolve`: `instantiate` installs exactly the versions in
`Manifest.toml`, while `resolve` may change them. If Pkg reports that a pinned
version is not available ("no versions left"), the local registry is older
than the Manifest; run `registry up` first. `make env` does this for you.

## Code style

Code in the text and the notebooks follows the plan's notation-to-Julia
crosswalk: distributions are `Distribution` objects named after their measure
(`μ`, `ν`, or `μ_X` when there are several), samples are `x` or `y`, an
indicator is `in_E`, the likelihood ratio and its logarithm are `ℓ` and `L`,
and every random call takes an explicit `rng = StableRNG(2026)`. Keyword
arguments have no spaces around `=` (`f(x; N=10_000)`), and code lines stay
under about 80 characters so they fit in an example box.

# Notebooks

Assignment notebooks live in `notebooks/`, one Jupytext percent-format `.jl`
file per video item, named `M<module>_<lesson>_<item>_<Name>.jl`:

```
notebooks/
  Project.toml, Manifest.toml   the pinned Julia environment
  lib/   StochasticSimulationCourse.jl, course_plots.jl, test_course.jl
  M1/    Module 1 notebooks
  M2/    Module 2 notebooks
tools/   solutions.py (split/merge/check), check_keyterms.py,
         text_examples.py, render_notebooks.jl, latex_warnings.py,
         pre-commit
```

Solutions and hidden tests are kept in a separate private repository. In a
public notebook each one is an empty region:

```
#@solution p1
#@end
```

`make notebooks` fills the regions from the private repository (default
location `../stochastic_simulation_solutions`, override with `SOLUTIONS=`),
copies the course files next to each notebook, and writes `.jl` and `.ipynb`
files under `build/notebooks/`. Add `NBGRADER=1` to emit nbgrader delimiters
instead of `#@` markers. Building requires `python3` and `jupytext`.

`make notebooks-pdf` builds a review copy of every notebook in the text's
style, `pdf/course_notebooks.pdf`. It runs each built notebook cell by cell, as
Jupyter would, and shows each cell's printed output, its displayed value and
any plot. As the author's copy it includes the solutions and hidden tests,
with the markers shown as `# --- solution (removed from the student copy) ---`,
and labels the answer cells and the locked test cells with their points. A
cell that raises an error shows `ERROR:` in its output, and the build lists
the count per notebook.

`make check-notebooks` fails if any public notebook contains a solution.
Install the same check as a commit hook with
`cp tools/pre-commit .git/hooks/pre-commit`.
