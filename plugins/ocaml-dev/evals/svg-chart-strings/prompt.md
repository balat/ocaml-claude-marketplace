---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

In my Eliom application (client-side code, js_of_ocaml) I draw a flow diagram like this:

```ocaml
let%client render_flow container nodes =
  let buf = Buffer.create 1024 in
  Buffer.add_string buf "<svg viewBox=\"0 0 600 300\">";
  List.iter (fun (x, y, w, label) ->
    Buffer.add_string buf
      (Printf.sprintf "<rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"20\" data-id=\"%s\"/><text x=\"%d\" y=\"%d\">%s</text>"
         x y w (esc label) (x + 4) (y + 14) (esc label)))
    nodes;
  Buffer.add_string buf "</svg>";
  container##.innerHTML := Js.string (Buffer.contents buf)
```

`esc` is my own HTML-escaping function. Labels come from user data. A reviewer said this is
the wrong approach in Eliom. Rewrite it the way it should be done, keeping the `data-id`
attributes (I use them for click delegation) and the ability to redraw on every update.
