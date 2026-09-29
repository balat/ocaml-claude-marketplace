# Registration modules of Eliom.Registration

The handler passed to `M.register ~service` receives the GET parameters, then the POST
parameters, and returns a promise whose type depends on the module `M`.

| Module | Handler returns | Use |
|---|---|---|
| `Html` | a typed page, `Html_types.html Eliom.Content.Html.elt` | pages built with TyXML |
| `Html_text` | a string | HTML produced by another tool; no validity checking |
| `Flow` | a list of typed flow elements | a fragment of a page, for inclusion by a client program or another service |
| `Action` | `unit` | a side effect (login, logout, update); the current page is then generated again, unless registered with `~options:`NoReload` |
| `Redirection` | `Redirection service` | an HTTP redirection to another service; the status code is an option of `register` (`` `Found``, `` `SeeOther``, `` `MovedPermanently``, ...) |
| `File` | a file path | serving a file from disk |
| `String` | content and content type | any byte string |
| `Ocaml` | an OCaml value | values sent to a client program (the low-level interface under remote calls) |
| `Any` | a `kind` value obtained from another module's `send` | the handler decides what to send, for example a page or a redirection depending on the request |
| `App` (functor) | a typed page | pages of a client-server application: the client program and its data are added automatically |
| `Customize` (functor) | as the module it wraps | defining a registration module with custom post-processing |

Common options of `register`: `?scope` (register the service for one session or client
process only), `?code`, `?content_type`, `?headers`, `?charset`, `?secure_session`.
`set_exn_handler` installs a site-wide exception handler for all modules.
