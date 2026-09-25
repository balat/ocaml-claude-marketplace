---
type: llm
weight: 1
---

A successful response:
- replaces the string-built markup with typed SVG nodes from `Eliom.Content.Svg` (`F.rect`,
  `F.text`, `F.g`, ...) embedded via `Eliom.Content.Html.F.svg` or a `D` root, with typed
  attributes (`a_x (float, None)`, `a_viewBox (0., 0., 600., 300.)`, `a_x_list` for text);
- uses `a_user_data "id" ...` for the `data-id` attributes;
- replaces `innerHTML :=` by `Manip.replaceChildren` (or `removeChildren` + `appendChild`)
  on a `D` node for redraws;
- drops the hand-written `esc` function and says why: TyXML escapes text and attributes,
  string markup is an XSS vector and defeats compile-time validity checking.
