# Stochastic Verification with Importance Sampling

A short open-source textbook on  statistical verification and estimation methods for Markov processes. Topics include measure theory, importance sampling, stratified sampling, and applications to discrete-time and continuous-time Markov processes. Simulation examples and assignments using Julia and PRISM languages.

This is a work-in-progress and is undergoing a lot of revision. All content is released as-is under the **Creative Commons Attribution and Share-Alike (CC-BY-SA) version 4.0**. In accordance with the terms of this license, all future revisions and versions shall carry the same open-source license terms.



# Dependencies

This document is written using Markdown and LaTeX, and is designed to be built 
as a pdf document using pandoc and GNU make. At time of this writing, the document
is built using pandoc 3.6.4 with the `pandoc-xnos` filter.

## Note on pandoc-xnos

The `pandoc-xnos` filter seems to be no longer maintained and throws errors with
current pandoc versions. A patched version of the filter is available from a forked
version and can be installed using `pip`:

```
pip install git+https://github.com/TimothyElder/pandoc-xnos --force-reinstall
```


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
