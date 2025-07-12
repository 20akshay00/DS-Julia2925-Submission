### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 56163e73-845d-44c4-a35b-276c681fcd6b
filepath = "./aoc-2023-day4.txt"

# ╔═╡ 084bdc80-8c21-48ac-93eb-e30590d73144
md"# Part 1"

# ╔═╡ 5ff8973d-1de2-49cb-aef3-952a10c7b536
begin
	function compute_matches(data)
	    parts = split(data, ":")
		
	    # Extract the two number lists as arrays of Int
	    numbers = [parse.(Int, split(strip(str))) for str in split(parts[2], "|")]
	    num_matches = length(intersect(numbers[1], numbers[2]))
	    return num_matches
	end
	
	function compute_score(data)
	    num_matches = compute_matches(data)
	    return iszero(num_matches) ? 0 : 2^(num_matches - 1)
	end
end

# ╔═╡ 7d8e5a23-5f91-45d1-9cc7-dd8a5a29db8f
sum(compute_score, collect(eachline(filepath)))

# ╔═╡ 19f551f9-b5bb-43aa-9ce4-2dbc2ada454a
md"# Part 2"

# ╔═╡ 5626d07f-f888-4146-b023-941150c2e48c
function total_num_cards(data)
	num_cards = ones(Int, countlines(filepath))
	num_matches = map(compute_matches, collect(eachline(filepath)))
	for card in eachindex(num_cards)
		num_cards[(card+1):(card + num_matches[card])] .+= num_cards[card]
	end
	return sum(num_cards)
end

# ╔═╡ 2b21bba0-06b9-4a31-8217-ad4e41045e8a
total_num_cards(filepath)

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
# ╠═56163e73-845d-44c4-a35b-276c681fcd6b
# ╟─084bdc80-8c21-48ac-93eb-e30590d73144
# ╠═5ff8973d-1de2-49cb-aef3-952a10c7b536
# ╠═7d8e5a23-5f91-45d1-9cc7-dd8a5a29db8f
# ╟─19f551f9-b5bb-43aa-9ce4-2dbc2ada454a
# ╠═5626d07f-f888-4146-b023-941150c2e48c
# ╠═2b21bba0-06b9-4a31-8217-ad4e41045e8a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
