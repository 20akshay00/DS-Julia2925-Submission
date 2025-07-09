using DifferentialEquations, ModelingToolkit, Symbolics
using Makie, GLMakie

using Makie: Mouse
using DataStructures: CircularBuffer
using ModelingToolkit: t_nounits as t, D_nounits as D

function getparam(integrator, param_idx, names...)
    getindex.(Ref(integrator.p[1]), getindex.(Ref(param_idx), names))
end

function generate_coupled_pendulum()
    @variables θ1(t) θ2(t)
    ω1, ω2 = D(θ1), D(θ2)
    dθ1, dθ2 = Differential(θ1), Differential(θ2)
    dω1, dω2 = Differential(ω1), Differential(ω2)
    @parameters m1 m2 l1 l2 l g d k

    kinetic = m1 * l1^2 * ω1^2 / 2 + m2 * l2^2 * ω2^2 / 2
    potential = -m1 * g * l1 * cos(θ1) - m2 * g * l2 * cos(θ2) + 0.5k * (sqrt((d + l2 * sin(θ2) - l1 * sin(θ1))^2 + (l2 * cos(θ2) - l1 * cos(θ2))^2) - l)^2
    lagrangian = kinetic - potential

    equations_of_motion = [
        expand_derivatives(D(dω1(lagrangian)) - dθ1(lagrangian)) ~ 0,
        expand_derivatives(D(dω2(lagrangian)) - dθ2(lagrangian)) ~ 0
    ]

    E1, E2 = simplify.(symbolic_linear_solve(equations_of_motion, [D(D(θ1)), D(D(θ2))]))
    @mtkbuild system = ODESystem([
            D(D(θ1)) ~ E1,
            D(D(θ2)) ~ E2,
            θ1 ~ θ1,
            θ2 ~ θ2
        ], t)

    param_idx = Dict(string(sym) => ModelingToolkit.parameter_index(system, sym).idx for sym in [m1, m2, l1, l2, l, g, d, k])

    prob = ODEProblem(system, merge(Dict(θ1 => π / 4, ω1 => 0, θ2 => -π / 4, ω2 => 0),
            Dict(g => 15, l1 => 2.5, l2 => 2.5, m1 => 1, m2 => 1, d => 5, l => 5, k => 5.)), (0, 10))

    return system, param_idx, prob
end

function compute_cartesian_coords(integrator, param_idx)
    l1, l2 = getparam(integrator, param_idx, "l1", "l2")
    θ1, θ2 = integrator.u[1], integrator.u[3]
    x1, y1 = l1 * sin(θ1), -l1 * cos(θ1)
    x2, y2 = l2 * sin(θ2), -l2 * cos(θ2)
    return x1, y1, x2, y2
end

function makefig(integrator, param_idx)
    rods = [Observable([Point2f(0, 0), Point2f(0, 0)]), Observable([Point2f(0, 0), Point2f(0, 0)])]
    balls = Observable([Point2f(0, 0), Point2f(0, 0)])
    energy1 = Observable(CircularBuffer{Point2f}(500))
    energy2 = Observable(CircularBuffer{Point2f}(500))
    # fill!(energy1[], Point2f(0., 0.))
    # fill!(energy2[], Point2f(0., 0.))

    update_observables!(rods, balls, energy1, energy2, integrator, param_idx)

    fig = Figure(size=(1920, 1080))
    display(fig)
    ax = Axis(fig[1, 1])

    sg = SliderGrid(fig[1, 2],
        (label="Gravity", range=-20.:0.1:0., format="{:.1f}m/s²", startvalue=-15),
        (label="Spring resting length", range=1.:0.1:10., format="{:.1f} m", startvalue=5.),
        (label="Spring k", range=0.:0.1:50., format="{:.1f} N/m", startvalue=5.),
        (label="Mass 1", range=0.5:0.1:15., format="{:.1f} kg", startvalue=1.),
        (label="Mass 2", range=0.5:0.1:15., format="{:.1f} kg", startvalue=1.),
        (label="Length 1", range=1.:0.1:5., format="{:.1f} m", startvalue=2.5),
        (label="Length 2", range=1.:0.1:5., format="{:.1f} m", startvalue=2.5),
        (label="Separation", range=2:0.1:10, format="{:.1f} m", startvalue=5.),
        width=500, tellheight=false)

    for (idx, lab) in enumerate(["g", "l", "k", "m1", "m2", "l1", "l2", "d"])
        on(sg.sliders[idx].value) do new_val
            integrator.p[1][param_idx[lab]] = new_val
        end
    end

    spring_width = lift(sg.sliders[3].value) do val
        2 * val / 5
    end

    bob_sizes = lift(sg.sliders[4].value, sg.sliders[5].value) do s1, s2
        [50 * (log(s1) + 1), 50 * (log(s2) + 1)]
    end

    anchors = lift(sg.sliders[end].value) do val
        [Point2f(-val / 2, 0), Point2f(val / 2, 0)]
    end

    lines!(ax, rods[1]; linewidth=5, color=:black)
    lines!(ax, rods[2]; linewidth=5, color=:black)
    lines!(ax, balls; linewidth=spring_width, color=:black, linestyle=:dot)
    scatter!(ax, balls; marker=:circle, strokewidth=5, strokecolor=:black, color=:white, markersize=bob_sizes)
    scatter!(ax, anchors; marker=:circle, strokewidth=0, color=:black, markersize=[20, 20])

    ax.title = "Coupled Pendulum"
    ax.aspect = DataAspect()
    xlims!(ax, -5, 5)
    ylims!(ax, -3.5, 1)

    ax_energy1 = Axis(fig[2, 1], title="Kinetic Energy 1", xlabel="Time", ylabel="E1")
    lines!(ax_energy1, energy1, color=:black, linewidth=3)
    ylims!(ax_energy1, -0.5, 100.)

    # m1, m2 = getparam(integrator, param_idx, "m1", "m2")
    # l1, l2 = getparam(integrator, param_idx, "l1", "l2")
    # g, = getparam(integrator, param_idx, "g")

    on(energy1) do lims
        xmin, xmax = lims[1].data[1], lims[end].data[1]
        if xmin != xmax
            xlims!(ax_energy1, xmin, xmax)
        else
            xlims!(ax_energy1, 0., 1.)
        end
    end

    ax_energy2 = Axis(fig[3, 1], title="Kinetic Energy 2", xlabel="Time", ylabel="E2")
    lines!(ax_energy2, energy2, color=:black, linewidth=3)
    ylims!(ax_energy2, -0.5, 100.)

    on(energy2) do lims
        xmin, xmax = lims[1].data[1], lims[end].data[1]

        if xmin != xmax
            xlims!(ax_energy2, xmin, xmax)
        else
            xlims!(ax_energy2, 0., 1.)
        end

    end

    return fig, rods, balls, energy1, energy2
end

function update_observables!(rods, balls, energy1, energy2, integrator, param_idx)
    x1, y1, x2, y2 = compute_cartesian_coords(integrator, param_idx)
    d, = getparam(integrator, param_idx, "d")
    rods[1][] = [Point2f(-d / 2, 0), Point2f(x1 - d / 2, y1)]
    rods[2][] = [Point2f(d / 2, 0), Point2f(x2 + d / 2, y2)]
    balls[] = [Point2f(x1 - d / 2, y1), Point2f(x2 + d / 2, y2)]

    m1, m2 = getparam(integrator, param_idx, "m1", "m2")
    l1, l2 = getparam(integrator, param_idx, "l1", "l2")

    push!(energy1[], Point2f(integrator.t, 0.5 * m1 * l1^2 * integrator.u[2]^2))
    push!(energy2[], Point2f(integrator.t, 0.5 * m2 * l2^2 * integrator.u[4]^2))
    energy1[] = energy1[]
    energy2[] = energy2[]
end

function animstep!(integrator, rods, balls, energy1, energy2, param_idx)
    step!(integrator)
    update_observables!(rods, balls, energy1, energy2, integrator, param_idx)
end

function create_toggle_button(fig, names::Tuple{String,String})
    label = Observable(names[1])
    button = Button(fig[end+1, 1]; label=label, tellwidth=false)
    flag = Observable(false)
    on(button.clicks) do clicks
        flag[] = !flag[]
        label[] = names[2-flag[]]
    end
    return button, flag
end

begin
    system, param_idx, prob = generate_coupled_pendulum()
    integrator = init(prob, Tsit5(), adaptive=false, dt=0.005)

    fig, rods, balls, energy1, energy2 = makefig(integrator, param_idx)
    run, isrunning = create_toggle_button(fig, ("Stop", "Start"))

    on(run.clicks) do clicks
        @async while isrunning[]
            isopen(fig.scene) || break
            animstep!(integrator, rods, balls, energy1, energy2, param_idx)
            sleep(1e-5)
        end
    end

    reset = Button(fig[end, 2]; label="Reset", tellwidth=false)
    on(reset.clicks) do clicks
        reinit!(integrator, [0., 0., 0., 0.])
        empty!(energy1[])
        empty!(energy2[])
        update_observables!(rods, balls, energy1, energy2, integrator, param_idx)
    end

    ax = content(fig[1, 1])
    Makie.deactivate_interaction!(ax, :rectanglezoom)

    spoint = select_point(ax.scene, marker=:circle)
    last_button = Observable(:left)

    on(ax.scene.events.mousebutton) do e
        if e.action == Mouse.press
            last_button[] = e.button == Mouse.left ? :left : :right
        end
    end

    on(spoint) do z
        x, y = z
        d, = getparam(integrator, param_idx, "d")
        u = (last_button[] == :left) ? [atan(y, x + d / 2) + π / 2, 0., integrator.u[3], 0.] :
            [integrator.u[1], 0., atan(y, x - d / 2) + π / 2, 0.]
        reinit!(integrator, u)
        empty!(energy1[])
        empty!(energy2[])
        update_observables!(rods, balls, energy1, energy2, integrator, param_idx)
    end
end
