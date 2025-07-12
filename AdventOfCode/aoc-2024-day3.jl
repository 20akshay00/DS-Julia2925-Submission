### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 173b98d0-5cf5-11f0-155f-cd9e584c8dbc
filepath = "./aoc-2024-day3.txt"

# ╔═╡ b6135513-b87a-4308-b300-4825dd9befa7
md"# Part 1"

# ╔═╡ bf8292c1-bfa3-4db9-a4b5-bd6576efe8fb
part1(data) = sum(match -> prod(parse.(Int, match.captures)), eachmatch(r"mul\((\d+),(\d+)\)", data))

# ╔═╡ 9e203df7-7cf0-46aa-b3b8-e4e94959223a
begin
	data = read(filepath, String)
	part1(data)
end

# ╔═╡ 6494df33-a19c-4f18-b5e5-bb907cbd07e6
md"# Part 2"

# ╔═╡ aec4c91a-0090-41dd-9bd2-d3b732c3d1ad
function part2(data)
	res = 0
	process = true
	for group in eachmatch(r"(?:mul\((\d+),(\d+)\))|(?:don't\(\))|(?:do\(\))",data)
		if group.match == "don\'t()"
			process = false
		elseif group.match == "do()"
			process = true
		elseif process
			res += prod(parse.(Int, group.captures))
		end
	end

	return res
end

# ╔═╡ 38299dfc-6eef-4f45-a91a-ecab8435082a
part2(data)

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
# ╠═173b98d0-5cf5-11f0-155f-cd9e584c8dbc
# ╟─b6135513-b87a-4308-b300-4825dd9befa7
# ╠═bf8292c1-bfa3-4db9-a4b5-bd6576efe8fb
# ╠═9e203df7-7cf0-46aa-b3b8-e4e94959223a
# ╟─6494df33-a19c-4f18-b5e5-bb907cbd07e6
# ╠═aec4c91a-0090-41dd-9bd2-d3b732c3d1ad
# ╠═38299dfc-6eef-4f45-a91a-ecab8435082a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
