import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

type EdgeList =
  dict.Dict(Int, set.Set(Int))

type Graph {
  Graph(edges: EdgeList, start: Int, end: Int, dac: Int, fft: Int)
}

type VisitedState {
  VisitedState(dac: Bool, fft: Bool, num_paths: Int)
}

fn add_edge(edges: EdgeList, edge: #(Int, Int)) -> EdgeList {
  let #(u, v) = edge

  let new_neighbors = case dict.get(edges, u) {
    Ok(neighbors) -> {
      neighbors |> set.insert(v)
    }
    Error(_) -> {
      set.new() |> set.insert(v)
    }
  }
  edges |> dict.insert(u, new_neighbors)
}

fn parse_input(input: String, vertex_start_str: String) -> Graph {
  let #(edges, vertex_names) =
    input
    |> string.split("\n")
    |> list.fold(#(dict.new(), dict.new()), fn(acc, row_str) {
      let #(curr_edges, curr_vertex_names) = acc
      parse_edge_row(curr_edges, curr_vertex_names, row_str)
      |> result.unwrap(#(curr_edges, curr_vertex_names))
    })

  let assert Ok(vertex_start) = dict.get(vertex_names, vertex_start_str)
  let assert Ok(vertex_end) = dict.get(vertex_names, "out")
  let vertex_dac = dict.get(vertex_names, "dac") |> result.unwrap(-1)
  let vertex_fft = dict.get(vertex_names, "fft") |> result.unwrap(-1)

  Graph(edges, vertex_start, vertex_end, vertex_dac, vertex_fft)
}

fn parse_edge_row(
  edges: EdgeList,
  vertex_names: dict.Dict(String, Int),
  row_str: String,
) -> Result(#(EdgeList, dict.Dict(String, Int)), Nil) {
  let parts = string.split(row_str, " ")

  use source_vertex_str <- result.try(list.first(parts))
  use target_vertices_str <- result.try(list.rest(parts))

  let source_vertex_str = string.replace(source_vertex_str, ":", "")

  let #(vertex_names_with_source, source_vertex) =
    add_or_retrieve_vertex(vertex_names, source_vertex_str)

  let #(new_edges, new_vertex_names) =
    target_vertices_str
    |> list.fold(#(edges, vertex_names_with_source), fn(acc, target_vertex_str) {
      let #(curr_edges, curr_vertex_names) = acc

      let #(new_vertex_names, target_vertex) =
        add_or_retrieve_vertex(curr_vertex_names, target_vertex_str)

      let new_edges = add_edge(curr_edges, #(source_vertex, target_vertex))
      #(new_edges, new_vertex_names)
    })

  Ok(#(new_edges, new_vertex_names))
}

fn add_or_retrieve_vertex(
  vertex_names: dict.Dict(String, Int),
  vertex_str: String,
) -> #(dict.Dict(String, Int), Int) {
  case dict.get(vertex_names, vertex_str) {
    Ok(v) -> #(vertex_names, v)
    _ -> {
      let v = dict.size(vertex_names)
      // io.println(vertex_str <> " --> " <> int.to_string(v))
      #(dict.insert(vertex_names, vertex_str, v), v)
    }
  }
}

fn dfs(
  graph: Graph,
  root: Int,
  visited: dict.Dict(Int, Int),
) -> #(dict.Dict(Int, Int), Int) {
  // io.println("dfs start: " <> int.to_string(root))

  // We just need this to not visit this node in the recurisve calls
  // The num paths will be set at the end of the function to the correct value
  let init_visited = visited |> dict.insert(root, 0)

  dict.get(graph.edges, root)
  |> result.unwrap(set.new())
  |> set.fold(#(init_visited, 0), fn(acc, neighbor) {
    let #(curr_visited, curr_num_paths) = acc
    case dict.get(curr_visited, neighbor) {
      Ok(new_num_paths) -> #(curr_visited, curr_num_paths + new_num_paths)
      Error(_) -> {
        let #(new_visited, new_num_paths) = dfs(graph, neighbor, curr_visited)
        #(new_visited, curr_num_paths + new_num_paths)
      }
    }
  })
  |> fn(state) {
    let #(new_visited, new_num_paths) = state

    // io.println(
    //   "dfs end:   "
    //   <> int.to_string(root)
    //   <> ", paths: "
    //   <> int.to_string(new_num_paths),
    // )
    #(dict.insert(new_visited, root, new_num_paths), new_num_paths)
  }
}

pub fn part1(input: String) -> Int {
  let graph = parse_input(input, "you")
  // io.println("\n")
  let visited = dict.new() |> dict.insert(graph.end, 1)

  let #(_, num_paths) = dfs(graph, graph.start, visited)

  num_paths
}

type State {
  State(dac_fft_paths: Int, dac_paths: Int, fft_paths: Int, paths: Int)
}

fn add_state(a: State, b: State) -> State {
  State(
    a.dac_fft_paths + b.dac_fft_paths,
    a.dac_paths + b.dac_paths,
    a.fft_paths + b.fft_paths,
    a.paths + b.paths,
  )
}

fn dfs_part2(
  graph: Graph,
  root: Int,
  visited: dict.Dict(Int, State),
) -> #(dict.Dict(Int, State), State) {
  // io.println("dfs start: " <> int.to_string(root))

  // We just need this to not visit this node in the recurisve calls
  // The num paths will be set at the end of the function to the correct value
  let init_visited = visited |> dict.insert(root, State(0, 0, 0, 0))

  dict.get(graph.edges, root)
  |> result.unwrap(set.new())
  |> set.fold(#(init_visited, State(0, 0, 0, 0)), fn(acc, neighbor) {
    let #(curr_visited, curr_state) = acc
    case dict.get(curr_visited, neighbor) {
      Ok(visited_state) -> {
        #(curr_visited, add_state(curr_state, visited_state))
      }
      Error(_) -> {
        let #(new_visited, new_state) = dfs_part2(graph, neighbor, curr_visited)
        #(new_visited, add_state(curr_state, new_state))
      }
    }
  })
  |> fn(x) {
    let #(visited, state) = x

    // io.println(
    //   "dfs end:   "
    //   <> int.to_string(root)
    //   <> ", dac_fft: "
    //   <> int.to_string(state.dac_fft_paths)
    //   <> ", dac: "
    //   <> int.to_string(state.dac_paths)
    //   <> ", fft: "
    //   <> int.to_string(state.fft_paths)
    //   <> ", paths: "
    //   <> int.to_string(state.paths),
    // )
    let new_state = case root {
      r if r == graph.dac ->
        State(
          state.dac_fft_paths,
          state.dac_paths + state.paths,
          state.fft_paths,
          0,
        )
      r if r == graph.fft ->
        State(
          state.dac_fft_paths,
          state.dac_paths,
          state.fft_paths + state.paths,
          0,
        )
      _ ->
        case state.dac_paths != 0 || state.dac_fft_paths != 0 {
          True ->
            State(state.dac_fft_paths, state.dac_paths, state.fft_paths, 0)
          False -> state
        }
    }

    // io.println(
    //   "dfs end:   "
    //   <> int.to_string(root)
    //   <> ", dac_fft: "
    //   <> int.to_string(new_state.dac_fft_paths)
    //   <> ", dac: "
    //   <> int.to_string(new_state.dac_paths)
    //   <> ", fft: "
    //   <> int.to_string(new_state.fft_paths)
    //   <> ", paths: "
    //   <> int.to_string(new_state.paths),
    // )

    let final_state = case
      { root == graph.dac && new_state.fft_paths != 0 }
      || { root == graph.fft && new_state.dac_paths != 0 }
    {
      True ->
        State(new_state.dac_paths + new_state.fft_paths, 0, 0, new_state.paths)
      False -> new_state
    }
    // io.println(
    //   "dfs end:   "
    //   <> int.to_string(root)
    //   <> ", dac_fft: "
    //   <> int.to_string(final_state.dac_fft_paths)
    //   <> ", dac: "
    //   <> int.to_string(final_state.dac_paths)
    //   <> ", fft: "
    //   <> int.to_string(final_state.fft_paths)
    //   <> ", paths: "
    //   <> int.to_string(final_state.paths),
    // )
    #(dict.insert(visited, root, final_state), final_state)
  }
}

pub fn part2(input: String) -> Int {
  let graph = parse_input(input, "svr")
  // io.println("\n")
  let visited = dict.new() |> dict.insert(graph.end, State(0, 0, 0, 1))

  let #(_, state) = dfs_part2(graph, graph.start, visited)

  state.dac_fft_paths
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day11.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}
