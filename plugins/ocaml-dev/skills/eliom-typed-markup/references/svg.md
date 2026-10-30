# Typed SVG with Eliom.Content.Svg

## Contents

- Embedding SVG in HTML
- Elements
- Attribute types
- Replacing and updating
- Event delegation with data attributes
- Complete example

## Embedding SVG in HTML

```ocaml
let open Eliom.Content in
Html.F.svg
  ~a:[Svg.F.a_viewBox (0., 0., 100., 40.); Svg.F.a_class ["chart"]]
  [ (* Svg.F children *) ]
```

The HTML `svg` element takes SVG attributes (`Svg.F.a_*`), not `Html.F.a_*`.

## Elements

Containers (`g`, `svg`, `defs`, `clipPath`, `text`, `tspan`) and shapes (`rect`, `circle`,
`ellipse`, `line`, `polyline`, `polygon`, `path`, `use`) take `~a:[...]` and a child list
(empty for shapes). `title` and `desc` are unary: `Svg.F.title (Svg.F.txt "tooltip")`. Text
content is `Svg.F.txt`.

## Attribute types

| Attribute | Type | Example |
|---|---|---|
| `a_x`, `a_y`, `a_width`, `a_height`, `a_rx`, `a_ry`, `a_r`, `a_cx`, `a_cy`, `a_x1`, `a_y2` | `Svg_types.Unit.length`, a float with an optional unit (`float * [`Px | `Percent | `Em | ...] option`) | `a_x (13., None)`, `a_width (50., Some `Percent)` |
| `a_x_list`, `a_y_list` (on `text`, `tspan`) | length list | `a_x_list [(10., None)]` |
| `a_transform` | `Svg_types.transform list` | `a_transform [`Translate (x, Some y); `Scale (k, None)]`; rotation `` `Rotate ((45., None), Some (cx, cy)) `` |
| `a_viewBox` | `float * float * float * float` | `a_viewBox (0., 0., w, h)` |
| `a_d` | string (path data, per the SVG specification) | `a_d "M 0 0 L 10 10 Z"` |
| `a_text_anchor` | variant | `a_text_anchor `Middle` |
| `a_fill`, `a_stroke` | paint | `a_fill (`Color ("#333", None))`, `a_fill `None` |
| `a_stroke_width` | length | `a_stroke_width (1.5, None)` |
| `a_class` | string list | `a_class ["bar"; "selected"]` |
| `a_user_data` | name and value | `a_user_data "id" (Int64.to_string id)` renders `data-id="..."` |
| `a_style` | avoid: use classes, or a typed attribute | |

## Replacing and updating

- Full redraw: keep the handle of a `D` root node and call `Eliom.Content.Svg.Manip.replaceChildren root
  [new_subtree]` (or `Html.Manip.replaceChildren` on the HTML `svg` element).
- Single attribute: keep the `D` handle and set that attribute on its DOM node,
  `(Svg.To_dom.of_element node)##setAttribute (Js.string "transform") (Js.string v)`, or
  toggle classes with `Manip.Class.add` / `Manip.Class.remove`.
- Emptying: `Manip.removeChildren root`.

## Event delegation with data attributes

Put `a_user_data "act" "select"` (and an id, `a_user_data "id" ...`) on the interactive
elements and bind one `Lwt_js_events.clicks` on the root; read the target's `data-act` and
`data-id` with `getAttribute` on the event target to dispatch. This keeps one handler per
drawing instead of one per shape.

## Complete example

```ocaml
let%shared bar ~x ~w ~label =
  let open Eliom.Content.Svg in
  F.g
    ~a:[F.a_class ["bar"]; F.a_user_data "label" label]
    [ F.rect
        ~a:[ F.a_x (x, None); F.a_y (0., None)
           ; F.a_width (w, None); F.a_height (20., None)
           ; F.a_rx (2., None) ]
        []
    ; F.text
        ~a:[ F.a_x_list [(x +. (w /. 2.), None)]; F.a_y_list [(14., None)]
           ; F.a_text_anchor `Middle ]
        [F.txt label]
    ; F.title (F.txt label) ]

let%shared chart bars =
  let open Eliom.Content in
  Html.F.svg
    ~a:[Svg.F.a_viewBox (0., 0., 300., 20.); Svg.F.a_class ["chart"]]
    (List.map (fun (x, w, label) -> bar ~x ~w ~label) bars)
```
