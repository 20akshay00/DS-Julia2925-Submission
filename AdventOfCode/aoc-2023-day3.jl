### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 067c0d8a-f3bf-48ba-9630-7bb26a185743
begin
	function isvalidgame(game, info)
		for elt in eachmatch(r"(\d+) (red|green|blue)", game)
			num_balls, color = elt.captures
			(info[color] < parse(Int, num_balls)) && (return false)
		end
		return true
	end
end

# ╔═╡ 43722ccb-705f-4f23-a7bd-868cded5c3a2
function find_minimum_cubes(game)
	min_cubes = Dict("red" => 0, "blue" => 0, "green" => 0)
	for set in split(game, ";")
		for elt in eachmatch(r"(\d+) (red|green|blue)", set)
			num_balls, color = elt.captures
			min_cubes[color] = max(min_cubes[color], parse(Int, num_balls))
		end
	end
	return min_cubes
end

# ╔═╡ f71f2af4-4a5e-4ed8-a7f0-7663d2b52260
filepath = "./aoc-2023-day3.txt"

# ╔═╡ cdcf6ec1-2859-4b8d-be74-c4f94bbca392
md"# Part 1"

# ╔═╡ a3a4b6ff-7cec-41bb-9359-4ec7aaab7b64
begin
	info = Dict("red"=>12, "green"=>13, "blue"=>14)
	sum(findall(game -> isvalidgame(game, info), collect(eachline(filepath))))
end

# ╔═╡ 252f300b-0ff2-43fa-802c-0fd99bb7be11
md"# Part 2"

# ╔═╡ b5bbfeb5-091a-4bba-9a16-08dde36a9eba
sum(game -> prod(values(find_minimum_cubes(game))), collect(eachline(filepath)))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.5"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═f71f2af4-4a5e-4ed8-a7f0-7663d2b52260
# ╟─cdcf6ec1-2859-4b8d-be74-c4f94bbca392
# ╠═067c0d8a-f3bf-48ba-9630-7bb26a185743
# ╠═a3a4b6ff-7cec-41bb-9359-4ec7aaab7b64
# ╟─252f300b-0ff2-43fa-802c-0fd99bb7be11
# ╠═43722ccb-705f-4f23-a7bd-868cded5c3a2
# ╠═b5bbfeb5-091a-4bba-9a16-08dde36a9eba
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
