import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Vec2 {
  Vec2(x: Int, y: Int)
}

type Edge =
  #(Vec2, Vec2)

type Orientation {
  Collinear
  Clockwise
  CounterClockwise
}

fn str_to_int(in: String) -> Int {
  int.parse(in)
  |> result.unwrap(0)
}

fn list_to_vec2(in: List(String)) -> Vec2 {
  case in {
    [x, y] -> Vec2(str_to_int(x), str_to_int(y))
    _ -> Vec2(0, 0)
  }
}

fn parse_input(input: String) -> List(Vec2) {
  input
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.split(",")
    |> list_to_vec2
  })
}

pub fn part1(input: String) -> Int {
  input
  |> parse_input
  |> list.combination_pairs
  |> list.fold(0, fn(acc, pair) {
    let #(v1, v2) = pair

    let diff_x = int.absolute_value(v1.x - v2.x) + 1
    let diff_y = int.absolute_value(v1.y - v2.y) + 1
    let area = diff_x * diff_y

    case acc < area {
      True -> area
      False -> acc
    }
  })
}

fn generate_bounding_edges(points: List(Vec2)) -> List(Edge) {
  let last = list.last(points) |> result.unwrap(Vec2(0, 0))
  let first = list.first(points) |> result.unwrap(Vec2(0, 0))

  let edges_without_last =
    points
    |> list.zip(list.rest(points) |> result.unwrap([]))

  [#(last, first), ..edges_without_last]
}

fn is_on_segment(pt: Vec2, edge: Edge) -> Bool {
  let #(p1, p2) = edge
  let Vec2(px, py) = pt

  let in_box =
    px >= int.min(p1.x, p2.x)
    && px <= int.max(p1.x, p2.x)
    && py >= int.min(p1.y, p2.y)
    && py <= int.max(p1.y, p2.y)

  case in_box {
    False -> False
    True -> {
      let cross_product =
        { py - p1.y } * { p2.x - p1.x } - { p2.y - p1.y } * { px - p1.x }

      cross_product == 0
    }
  }
}

fn is_point_in_polygon(pt: Vec2, polygon_edges: List(Edge)) -> Bool {
  let on_boundary = list.any(polygon_edges, fn(e) { is_on_segment(pt, e) })

  case on_boundary {
    True -> True
    False -> {
      let Vec2(px, py) = pt

      list.fold(polygon_edges, False, fn(inside, edge) {
        let #(p1, p2) = edge

        let p1_above = p1.y > py
        let p2_above = p2.y > py

        case p1_above != p2_above {
          False -> inside
          // No Y-intersection
          True -> {
            // Calculate X intersection
            let p1x = int.to_float(p1.x)
            let p1y = int.to_float(p1.y)
            let p2x = int.to_float(p2.x)
            let p2y = int.to_float(p2.y)
            let py_float = int.to_float(py)

            let intersect_x =
              { { p2x -. p1x } *. { py_float -. p1y } /. { p2y -. p1y } } +. p1x

            case int.to_float(px) <. intersect_x {
              True -> !inside
              False -> inside
            }
          }
        }
      })
    }
  }
}

fn orientation(p: Vec2, q: Vec2, r: Vec2) -> Orientation {
  let v = { q.y - p.y } * { r.x - q.x } - { q.x - p.x } * { r.y - q.y }

  case v {
    _ if v > 0 -> Clockwise
    _ if v < 0 -> CounterClockwise
    _ -> Collinear
  }
}

fn strict_intersection(edge1: Edge, edge2: Edge) -> Bool {
  let #(p1, q1) = edge1
  let #(p2, q2) = edge2

  let o1 = orientation(p1, q1, p2)
  let o2 = orientation(p1, q1, q2)
  let o3 = orientation(p2, q2, p1)
  let o4 = orientation(p2, q2, q1)

  o1 != o2
  && o3 != o4
  && o1 != Collinear
  && o2 != Collinear
  && o3 != Collinear
  && o4 != Collinear
}

fn is_rect_inside_poly(polygon: List(Edge), rectangle: List(Edge)) -> Bool {
  let corners = list.map(rectangle, fn(e) { e.0 })
  let corners_valid =
    list.all(corners, fn(c) { is_point_in_polygon(c, polygon) })

  case corners_valid {
    False -> False
    True -> {
      let has_bad_crossing =
        polygon
        |> list.any(fn(poly_edge) {
          rectangle
          |> list.any(fn(rect_edge) {
            strict_intersection(poly_edge, rect_edge)
          })
        })

      !has_bad_crossing
    }
  }
}

pub fn part2(input: String) -> Int {
  let vertices = parse_input(input)
  let poly_edges = generate_bounding_edges(vertices)

  vertices
  |> list.combination_pairs
  |> list.fold(0, fn(max_area, pair) {
    let #(v1, v2) = pair

    let v3 = Vec2(v1.x, v2.y)
    let v4 = Vec2(v2.x, v1.y)
    let rect_edges = [#(v1, v3), #(v3, v2), #(v2, v4), #(v4, v1)]

    case is_rect_inside_poly(poly_edges, rect_edges) {
      True -> {
        let diff_x = int.absolute_value(v1.x - v2.x) + 1
        let diff_y = int.absolute_value(v1.y - v2.y) + 1
        let area = diff_x * diff_y

        int.max(max_area, area)
      }
      False -> max_area
    }
  })
}

pub fn run() {
  let assert Ok(input) =
    simplifile.read("inputs/day09.txt")
    |> result.map(string.trim)

  let res1 = part1(input)
  io.println("Part 1: " <> int.to_string(res1))
  let res2 = part2(input)
  io.println("Part 2: " <> int.to_string(res2))
}
