import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import simplifile

type Graph =
  dict.Dict(Int, set.Set(Int))

type Vec3 {
  Vec3(x: Int, y: Int, z: Int)
}

fn list_to_vec3(in: List(String)) -> Vec3 {
  case in {
    [x, y, z] -> Vec3(str_to_int(x), str_to_int(y), str_to_int(z))
    _ -> Vec3(0, 0, 0)
  }
}

fn distance(a: Vec3, b: Vec3) -> Float {
  let diff_x_2 = int.power(a.x - b.x, 2.0) |> result.unwrap(0.0)
  let diff_y_2 = int.power(a.y - b.y, 2.0) |> result.unwrap(0.0)
  let diff_z_2 = int.power(a.z - b.z, 2.0) |> result.unwrap(0.0)

  float.square_root(diff_x_2 +. diff_y_2 +. diff_z_2) |> result.unwrap(0.0)
}

// fn print_vec3(v: Vec3) {
//   io.println(
//     "("
//     <> int.to_string(v.x)
//     <> ", "
//     <> int.to_string(v.y)
//     <> ", "
//     <> int.to_string(v.z)
//     <> ")",
//   )
// }

fn str_to_int(in: String) -> Int {
  int.parse(in)
  |> result.unwrap(0)
}

fn parse_input(input: String) -> List(Vec3) {
  input
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.split(",")
    |> list_to_vec3
  })
}

fn add_edge(graph: Graph, edge: #(Int, Int)) -> Graph {
  let #(u, v) = edge

  let new_neighbors = case dict.get(graph, u) {
    Ok(neighbors) -> {
      neighbors |> set.insert(v)
    }
    Error(_) -> {
      set.new() |> set.insert(v)
    }
  }
  graph |> dict.insert(u, new_neighbors)
}

fn construct_graph(edges: List(#(Int, Int))) -> Graph {
  edges
  |> list.fold(dict.new(), fn(graph, edge) {
    // We have an undirected graph so add both ways the edge can point
    graph
    |> add_edge(edge)
    |> add_edge(#(edge.1, edge.0))
  })
}

fn dfs(graph: Graph, root: Int, visited: set.Set(Int)) -> set.Set(Int) {
  let init_visited = visited |> set.insert(root)

  dict.get(graph, root)
  |> result.unwrap(set.new())
  |> set.fold(init_visited, fn(curr_visited, neighbor) {
    case set.contains(curr_visited, neighbor) {
      True -> curr_visited
      False -> {
        dfs(graph, neighbor, curr_visited)
      }
    }
  })
}

fn get_components(graph: Graph) -> List(set.Set(Int)) {
  graph
  |> dict.fold(#([], set.new()), fn(state, root, _) {
    let #(components, visited) = state

    case set.contains(visited, root) {
      True -> state
      False -> {
        let component = dfs(graph, root, set.new())
        let new_components = [component, ..components]

        #(new_components, set.union(visited, component))
      }
    }
  })
  |> fn(x) { x.0 }
}

pub fn part1(input: String, num_closest_pairs: Int) -> Int {
  let closest_pairs =
    parse_input(input)
    |> list.index_map(fn(v, idx) { #(idx, v) })
    |> list.combination_pairs
    |> list.sort(fn(u, v) {
      let #(#(_, u1), #(_, u2)) = u
      let #(#(_, v1), #(_, v2)) = v
      let u_dist = distance(u1, u2)
      let v_dist = distance(v1, v2)
      float.compare(u_dist, v_dist)
    })
    |> list.take(num_closest_pairs)

  let graph =
    closest_pairs
    // Discard the coordinats (Vec3)
    |> list.map(fn(x) {
      let #(#(u_idx, _), #(v_idx, _)) = x
      #(u_idx, v_idx)
    })
    |> construct_graph

  get_components(graph)
  |> list.map(set.size)
  |> list.sort(fn(x, y) {
    int.compare(x, y)
    |> order.negate
  })
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

pub fn part2(input: String) -> Int {
  let vertices =
    parse_input(input)
    |> list.index_map(fn(v, idx) { #(idx, v) })

  let closest_pairs =
    vertices
    |> list.combination_pairs
    |> list.sort(fn(u, v) {
      let #(#(_, u1), #(_, u2)) = u
      let #(#(_, v1), #(_, v2)) = v
      let u_dist = distance(u1, u2)
      let v_dist = distance(v1, v2)
      float.compare(u_dist, v_dist)
    })

  let edges =
    closest_pairs
    |> list.map(fn(x) {
      let #(#(u_idx, _), #(v_idx, _)) = x
      #(u_idx, v_idx)
    })

  let assert #(_, option.Some(last_edge)) =
    edges
    |> list.fold(#(dict.new(), option.None), fn(state, edge) {
      let #(graph, last_edge_for_connectivity) = state

      case last_edge_for_connectivity {
        option.Some(_) -> state
        option.None -> {
          let new_graph =
            // We have an undirected graph so add both ways the edge can point
            graph
            |> add_edge(edge)
            |> add_edge(#(edge.1, edge.0))

          let num_visited = dfs(new_graph, 0, set.new()) |> set.size

          let maybe_last_edge = case num_visited == list.length(vertices) {
            // Visited all vertices, i.e., connected
            True -> option.Some(edge)
            False -> option.None
          }

          #(new_graph, maybe_last_edge)
        }
      }
    })

  vertices
  |> list.fold(1, fn(acc, v_idx) {
    let #(idx, v) = v_idx
    case last_edge.0 == idx || last_edge.1 == idx {
      True -> acc * v.x
      False -> acc
    }
  })
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day08.txt")
    |> result.map(string.trim)

  let res1 = part1(input, 1000)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}
