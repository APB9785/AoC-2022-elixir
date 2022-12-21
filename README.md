# Advent2022

### Day 1
Summing and sorting lists of integers

### Day 2
Rock-Paper-Scissors simulation

### Day 3
ASCII encoding, comparing sets of letters

### Day 4
Using Ranges to find overlap in 1-D space

### Day 5
Queue/stack operations

### Day 6
"Sliding window" text analysis

### Day 7
Scan over a "file system" structure, recursively calculating directory size

### Day 8
2-D heightmap analysis

### Day 9
Simple 2-D physics simulation for a snake-like object

### Day 10
Part 1:  Build a simple VM with one register and one command  
Part 2:  Run a program with the VM to print an array of "pixels" to the terminal

### Day 11
Part 1:  Move and transform integers between several lists  
Part 2:  Use modular arithmetic to continue transformation as integers grow infinitely

### Day 12
Model a graph using [`:digraph`](https://www.erlang.org/doc/man/digraph.html) and compare shortest paths among various start nodes

### Day 13
Custom `compare/2` function for `Enum.sort/2` on nested lists

### Day 14
Simple 2-D physics simulation using MapSet for collision detection

### Day 15
Part 1:  Graph simple functions in 2-D space, storing values in a MapSet  
Part 2:  Use a [region quadtree](https://en.wikipedia.org/wiki/Quadtree) to analyze overlapping 2-D shapes

### Day 16
Part 1:  Transform an unweighted digraph into a [complete graph](https://en.wikipedia.org/wiki/Complete_graph) with edges weighted by distance and nodes weighted by value over time, in order to find an ideal path which maximizes node access value  
Part 2:  Each path now traverses the graph twice, exponentially increasing the number of potential paths

### Day 17
Part 1:  2-D movement and collision detection for Tetris-like game  
Part 2:  Cycle detection to allow simulating games of extremely long length

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `advent_2022` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:advent_2022, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/advent_2022>.
