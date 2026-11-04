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

# Notebooks

Assignment notebooks live in `notebooks/`, one Jupytext percent-format `.jl`
file per video item, named `M<module>_<lesson>_<item>_<Name>.jl`:

```
notebooks/
  lib/   StochasticSimulationCourse.jl, course_plots.jl, test_course.jl
  M1/    Module 1 notebooks
  M2/    Module 2 notebooks
tools/   solutions.py (split/merge/check), pre-commit
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

`make check-notebooks` fails if any public notebook contains a solution.
Install the same check as a commit hook with
`cp tools/pre-commit .git/hooks/pre-commit`.
