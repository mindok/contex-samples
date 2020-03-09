

map10_000 = 1..10_000
  |> Enum.map(&(%{col1: &1, col2: 100_000 + &1, col3: "Text #{&1}", col4: &1, col5: &1}))

string_map10_000 = 1..10_000
  |> Enum.map(&(%{"col1" => &1, "col2" => 100_000 + &1, "col3" => "Text #{&1}", "col4" => &1, "col5" => &1}))

list10_000 = 1..10_000
  |> Enum.map(&([&1, 100_000 + &1, "Text #{&1}", &1, &1]))

tuple10_000 = 1..10_000
  |> Enum.map(&({&1, 100_000 + &1, "Text #{&1}", &1, &1}))


# Restructures a map into a list before accessing the list elements
restructure_approach = fn reads ->
  restructured = Enum.map(map10_000, &([&1.col1, &1.col2, &1.col3, &1.col4, &1.col5]))

  for _i <- 1..reads do
    Enum.map(restructured, &Enum.at(&1, 4))
  end
end

# Directly looks up items in a list based on index
list_approach = fn reads ->
  for _i <- 1..reads do
    Enum.map(list10_000, &Enum.at(&1, 4))
  end
end

# Directly looks up items in a tuple based on index
tuple_approach = fn reads ->
  for _i <- 1..reads do
    Enum.map(tuple10_000, &elem(&1, 4))
  end
end

# Looks up items in a map using . notation
direct_map_approach = fn reads ->
  for _i <- 1..reads do
    Enum.map(map10_000, &(&1.col5))
  end
end

# Looks up items in a map using atom keys
key_map_approach = fn reads ->
  for _i <- 1..reads do
    Enum.map(map10_000, &(&1[:col5]))
  end
end

# Looks up items in a map using string keys
string_key_map_approach = fn reads ->
  for _i <- 1..reads do
    Enum.map(string_map10_000, &(&1["col5"]))
  end
end


Benchee.run(%{
  # Perform one read through the dataset per invocation
  "restructure_1" => fn -> restructure_approach.(1) end,
  "direct_1" => fn -> direct_map_approach.(1) end,
  "map_key_1" => fn -> key_map_approach.(1) end,
  "string_key_1" => fn -> string_key_map_approach.(1) end,
  "list_1" => fn -> list_approach.(1) end,
  "tuple_1" => fn -> tuple_approach.(1) end,

  # Perform ten reads through the dataset per invocation
  "restructure_10" => fn -> restructure_approach.(10) end,
  "direct_10" => fn -> direct_map_approach.(10) end,
  "map_key_10" => fn -> key_map_approach.(10) end,
  "string_key_10" => fn -> string_key_map_approach.(10) end,
  "list_10" => fn -> list_approach.(10) end,
  "tuple_10" => fn -> tuple_approach.(10) end
},
memory_time: 2
)

