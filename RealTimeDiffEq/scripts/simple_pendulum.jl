using DifferentialEquations, ModelingToolkit, Symbolics
using Makie, GLMakie
using ModelingToolkit: t_nounits as t, D_nounits as D

function generate_simple_pendulum()
    @variables θ(t)
    ω = D(θ)  # angular velocity
    dθ = Differential(θ)  # derivative to angule
    dω = Differential(ω)  # derivative to angular velocity
    @parameters m l g

    kinetic = m * l^2 * ω^2 / 2  # kinetic energy
    potential = -m * g * l * cos(θ)  # potential (arbitrary reference)
    lagrangian = kinetic - potential  # Lagrangian
    equations_of_motion = expand_derivatives(D(dω(lagrangian))) ~ expand_derivatives(dθ(lagrangian))
    @mtkbuild system = ODESystem(equations_of_motion, t)

    param_idx = Dict(string(sym) => ModelingToolkit.parameter_index(system, sym).idx for sym in [m, l, g])

    prob = ODEProblem(system, merge(Dict(θ => π / 3, ω => 0), Dict(m => 1, g => 9.81, l => 0.5)), (0, 10))

    return prob, param_idx
end

function compute_cartesian_coords(integrator, param_idx)
    l = integrator.p[1][param_idx["l"]]
    θ = integrator.u[1]
    x = l * sin(θ)
    y = -l * cos(θ)
    return x, y
end

function makefig(integrator, param_idx)
    # set up Makie observables
    x, y = compute_cartesian_coords(integrator, param_idx)
    rod = Observable([Point2f(0, 0), Point2f(x, y)])
    balls = Observable([Point2f(x, y)])

    update_observables!(rod, balls, integrator, param_idx)

    # set up Makie figure
    fig = Figure()
    display(fig)
    ax = Axis(fig[1, 1])
    lines!(ax, rod; linewidth=5, color=:black)
    scatter!(ax, balls; marker=:circle, strokewidth=0,
        strokecolor=:purple,
        color=:black, markersize=[50]
    )

    ax.title = "Simple Pendulum"
    ax.aspect = DataAspect()
    l = 2. * integrator.p[1][param_idx["l"]]
    xlims!(ax, -l, l)
    ylims!(ax, -l, 0.5l)

    return fig, rod, balls
end

function update_observables!(rod, balls, integrator, param_idx)
    x, y = compute_cartesian_coords(integrator, param_idx)
    rod[] = [Point2f(0, 0), Point2f(x, y)]
    balls[] = [Point2f(x, y)]
end

function animstep!(integrator, rod, balls, param_idx)
    step!(integrator)
    update_observables!(rod, balls, integrator, param_idx)
end

function create_toggle_button(fig, names::Tuple{String,String})
    label = Observable(names[1])
    button = Button(fig[2, 1]; label=label, tellwidth=false)
    flag = Observable(false)

    on(button.clicks) do clicks
        flag[] = !flag[]
        label[] = names[2-flag[]]
    end

    return button, flag
end

begin
    prob, param_idx = generate_simple_pendulum()
    integrator = init(prob, Tsit5(), adaptive=false, dt=0.005)
    fig, rod, balls = makefig(integrator, param_idx)

    run, isrunning = create_toggle_button(fig, ("Stop", "Start"))

    on(run.clicks) do clicks
        @async while isrunning[]
            isopen(fig.scene) || break # ensures computations stop if closed window
            animstep!(integrator, rod, balls, param_idx)
            sleep(1e-5) # or `yield()` instead
        end
    end

    ax = content(fig[1, 1])
    Makie.deactivate_interaction!(ax, :rectanglezoom)
    # and we'll add a new trigger using the `select_point` function:
    spoint = select_point(ax.scene, marker=:circle)

    on(spoint) do z
        x, y = z
        u = [atan(y, x) + π / 2, 0.]
        reinit!(integrator, u)
        # Reset tail and balls to new coordinates
        update_observables!(rod, balls, integrator, param_idx)
    end
end