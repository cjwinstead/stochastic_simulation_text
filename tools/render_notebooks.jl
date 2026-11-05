# render_notebooks.jl: run the built notebooks and write them as Markdown,
# with each code cell's printed output and plots, for a PDF review copy.
#
# Usage: julia --project=notebooks tools/render_notebooks.jl BUILD_DIR OUT_DIR
#
# BUILD_DIR holds the notebooks built by `make notebooks` (one folder per
# notebook, solutions merged in). Each notebook runs in its own module, in its
# own folder, cell by cell, the way Jupyter runs it. For each notebook the
# script writes OUT_DIR/NAME.md, and plots as PNG files in OUT_DIR/figures.
#
# Solution regions and graded cells are labelled, since this is the author's
# copy: students see neither the solutions nor the hidden tests.

using Plots

const CELL = r"^# %%(.*)$"
const MAX_OUTPUT_LINES = 40

struct Cell
    markdown::Bool
    meta::String
    lines::Vector{String}
end

function read_cells(path)
    lines = readlines(path)
    # skip the Jupytext header (# --- ... # ---)
    i = 1
    if !isempty(lines) && lines[1] == "# ---"
        i = findnext(==("# ---"), lines, 2) + 1
    end
    cells = Cell[]
    for line in lines[i:end]
        m = match(CELL, line)
        if m !== nothing
            meta = m.captures[1]
            push!(cells, Cell(occursin("[markdown]", meta), meta, String[]))
        elseif !isempty(cells)
            push!(cells[end].lines, line)
        end
    end
    return cells
end

trim(lines) = (s = join(lines, "\n"); strip(s, '\n'))

meta_flag(meta, key) = occursin(Regex("\"$key\"\\s*:\\s*true"), meta)
function meta_points(meta)
    m = match(r"\"points\"\s*:\s*(\d+)", meta)
    return m === nothing ? nothing : parse(Int, m.captures[1])
end

function cell_label(c::Cell)
    occursin("nbgrader", c.meta) || return nothing
    pts = meta_points(c.meta)
    pts_text = pts === nothing ? "" : " ($pts point$(pts == 1 ? "" : "s"))"
    graded, solution = meta_flag(c.meta, "grade"), meta_flag(c.meta, "solution")
    if c.markdown && solution
        return "Hand-graded answer$pts_text. The model answer below is removed from the student copy."
    elseif solution
        return "Answer cell. The solution is removed from the student copy, leaving the comments above it."
    elseif graded
        return "Locked test cell$pts_text. Hidden tests are removed from the student copy."
    end
    return nothing
end

function markdown_text(c::Cell)
    out = String[]
    for line in c.lines
        line == "#" && (push!(out, ""); continue)
        s = startswith(line, "# ") ? line[3:end] : line
        occursin(r"^#@(solution|hidden-tests|end)\b", s) && continue
        push!(out, s)
    end
    return trim(out)
end

function code_text(c::Cell)
    out = map(c.lines) do line
        s = strip(line)
        startswith(s, "#@solution") ? "# --- solution (removed from the student copy) ---" :
        startswith(s, "#@hidden-tests") ? "# --- hidden tests (removed from the student copy) ---" :
        startswith(s, "#@end") ? "# --- end ---" : line
    end
    return trim(out)
end

# Jupyter shows the value of a cell's last expression unless it ends with ";"
function shows_value(code)
    lines = [strip(l) for l in split(code, '\n') if !isempty(strip(l)) && !startswith(strip(l), "#")]
    return !isempty(lines) && !endswith(lines[end], ";")
end

function run_cell(mod, code, name)
    value, err = nothing, nothing
    printed = mktemp() do path, io
        redirect_stdout(io) do
            redirect_stderr(io) do
                try
                    value = Base.invokelatest(Base.include_string, mod, code, name)
                catch e
                    err = sprint(showerror, e isa LoadError ? e.error : e)
                end
            end
        end
        flush(io)
        read(path, String)
    end
    return printed, value, err
end

function limit_lines(text)
    lines = split(rstrip(text), '\n')
    length(lines) <= MAX_OUTPUT_LINES && return join(lines, "\n")
    return join(lines[1:MAX_OUTPUT_LINES], "\n") * "\n[... $(length(lines) - MAX_OUTPUT_LINES) more lines]"
end

function render(nb_dir, out_dir)
    name = basename(rstrip(nb_dir, '/'))
    src = joinpath(nb_dir, name * ".jl")
    isfile(src) || return nothing
    fig_dir = joinpath(out_dir, "figures")
    mkpath(fig_dir)
    # A fresh module per notebook, with its own include and eval, like Main
    mod = Module(Symbol(name))
    Core.eval(mod, :(include(path) = Base.include($mod, abspath(path))))
    Core.eval(mod, :(eval(x) = Core.eval($mod, x)))
    md = String[]
    nfig, nerr = 0, 0
    cd(nb_dir) do
        for (k, c) in enumerate(read_cells(src))
            label = cell_label(c)
            label === nothing || push!(md, "*" * label * "*\n")
            if c.markdown
                push!(md, markdown_text(c) * "\n")
                continue
            end
            code = code_text(c)
            isempty(code) && continue
            push!(md, "```julia\n" * code * "\n```\n")
            printed, value, err = run_cell(mod, join(c.lines, "\n"), "$name cell $k")
            out = rstrip(printed)
            if err !== nothing
                nerr += 1
                out = (isempty(out) ? "" : out * "\n") * "ERROR: " * err
            elseif value !== nothing && shows_value(code)
                if value isa Plots.Plot
                    nfig += 1
                    png = joinpath(fig_dir, "$(name)_$(nfig).png")
                    Base.invokelatest(savefig, value, png)
                    push!(md, "```{=latex}\n\\begin{center}\\includegraphics[width=0.75\\linewidth]{$png}\\end{center}\n```\n")
                else
                    shown = sprint() do io
                        ctx = IOContext(io, :limit => true, :displaysize => (24, 80))
                        Base.invokelatest(show, ctx, MIME"text/plain"(), value)
                    end
                    out = isempty(out) ? shown : out * "\n" * shown
                end
            end
            isempty(out) || push!(md, "```text\n" * limit_lines(out) * "\n```\n")
        end
    end
    write(joinpath(out_dir, name * ".md"), join(md, "\n"))
    println(rpad(name, 32), nfig, " plot(s)", nerr == 0 ? "" : ", $nerr cell error(s)")
    return nerr
end

function main(args)
    length(args) == 2 || (println("usage: render_notebooks.jl BUILD_DIR OUT_DIR"); exit(2))
    build, out = abspath(args[1]), abspath(args[2])
    mkpath(out)
    dirs = sort([d for m in readdir(build; join=true) if isdir(m) && startswith(basename(m), "M")
                 for d in readdir(m; join=true) if isdir(d)])
    errors = sum((render(d, out) for d in dirs); init=0)
    errors == 0 || println("$errors cell(s) raised an error; see ERROR in the rendered output")
end

main(ARGS)
