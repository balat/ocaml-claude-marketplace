---
name: ocsigen-start
description: "Building on the Ocsigen Start template and library: users, groups and sessions, Os.Current_user and authorization checks (allow, deny, predicate), session-start client caches, Os.Notif server push, Os.Msg, Ocsigen Toolkit widgets (Ot.Spinner, Ot.Popup, Ot.Drawer, Ot.Carousel, Ot.Nodeready), PG'OCaml [%pgsql] queries and idempotent schema updates, ocsigen-i18n, SASS with BEM and ot-/os- prefixes, Makefile targets (make test.byte, db-schema, db-update, css). Use in a project generated from the Ocsigen Start template or when code uses Os., Ot., [%pgsql] or i18n."
---

# Ocsigen Start applications

Ocsigen Start (`Os`, <https://ocsigen.org/ocsigen-start>) provides users, sessions, groups,
notifications, email and a project template with a demo of each feature and of the Ocsigen
Toolkit widgets (`Ot`, <https://ocsigen.org/ocsigen-toolkit>). A new application starts with
`eliom-distillery -name myapp -template os` (`os.pgocaml` with Eliom 12 and earlier). Keep
the template's structure; the `demo_*.eliom` files are working examples of each feature and
can be removed once read. Module names are those of Eliom 13; earlier
releases use `Os_session`, `Ot_spinner` (mapping in the `eliom-client-server` skill).

## Template structure

`myapp.eliom` (the `App` module), `myapp_services`, `myapp_handlers`, `myapp_page` (page
wrappers), `myapp_container` (layout), `myapp_drawer`, `myapp_config`, `myapp_language`,
`myapp_settings`, `myapp_mobile`, `*_db.ml` (database access), `sass/`, `static/`,
`assets/` (images, translation files), `mobile/` (Cordova), `myapp.sql` (Ocsigen Start
schema), `Makefile.options` (project settings, committed) and `Makefile.local` (machine
settings, kept out of git). Feature files follow the layout described in
`eliom-architecture`.

## Users, sessions, authorization

- Users are rows of `ocsigen_start.users`, groups rows of `ocsigen_start.groups`
  (`Os.User`, `Os.Group`). Model roles as groups.
- The template calls the connected user's id `myid` and other users' ids `userid`; keep that
  convention. Never send `myid` from the client: the server obtains it with
  `Os.Current_user.get_current_userid ()` inside a connected handler or RPC.
- Wrap page handlers with `Os.Page.connected_page` (rejects anonymous users) or
  `Os.Page.Opt.connected_page` (passes `myid_o : Os.Types.User.id option`). Both take
  `?allow` and `?deny` group lists, a `?predicate` and a `?fallback`. Wrap server functions
  with `Os.Session.connected_rpc` or `Os.Session.Opt.connected_rpc`, which take `?allow`,
  `?deny` and `?deny_fun`.
- `?allow`, `?deny` and `?predicate` are real authorization checks when the page is rendered
  on the server. On client-side navigation the same checks run in the browser and a modified
  client can bypass them. Treat their client-side outcome as user experience (do not show a
  restricted page to a non-member) and put the boundary in each privileged RPC, which
  re-checks membership on the server at every call.
- Per-session data the client reads on every render (group memberships, preferences, feature
  flags, attributes of the page chrome): push it once at session start rather than calling
  an RPC per render, which fires on every transition and adds up to visible latency.

  ```ocaml
  let%client memberships : Os.Types.Group.t list ref = ref []

  let%server () =
    Os.Session.on_start_connected_process (fun myid ->
      let%lwt gs = Myapp_db.groups_of myid in
      ignore [%client (memberships := ~%gs : unit)];
      Lwt.return_unit)
  ```

  The client variant of a check then reads the reference synchronously; the server variant
  can still query the database. A stale value after a mid-session change is acceptable for
  UX gating only; authorization stays on the per-RPC server check.
- Scopes that survive login and logout: `Os.Session.user_indep_session_scope` and
  `user_indep_process_scope`.

## Notifications, messages, email

- Server to client push: `module Notif = Os.Notif.Make_Simple (struct type key = ... type notification = ... end)`.
  On the server, `Notif.listen key` subscribes the current client process and
  `Notif.notify key notification` pushes to every subscriber. `Notif.client_ev ()` builds,
  on the server, a downward React event of `key * notification`; inject it into client code
  with `~%` (typically from `Os.Session.on_start_process`) and map it there like any
  `React.E.t`. Demo: `demo_notif.eliom`.
- Feedback to the user: `Os.Msg.msg ~level:`Err "..."`, callable from client or server code.
- Email: `Os.Email`. Mobile push: `Os.Fcm_notif`.

## Widgets and forms

Look in Ocsigen Toolkit before writing a component: spinners, popups, drawers, carousels,
calendar and pickers, pull-to-refresh, page transitions, tooltips, and more.
`references/toolkit-widgets.md` lists the modules with their purpose and the demo file that
shows each. When a widget lacks something generic, improve the toolkit rather than patching
locally (see `ocsigen-contributing`). Forms: `demo_forms.eliom` shows typed forms with the
toolkit inputs.

## Database (PG'OCaml)

- Queries live in `*_db.ml` files and use the PG'OCaml ppx:
  `[%pgsql dbh "SELECT lastname FROM ocsigen_start.users WHERE userid = $userid"]`.
  They are type-checked at build time against the live database, so the database must be
  running and migrated before building.
- Wrap queries in `full_transaction_block` (from `Os.Db`, which the template's db files open).
- Never modify the `ocsigen_start.*` tables: they must stay upgradable. Add tables and
  reference `ocsigen_start.users.userid`.
- Recommended schema management, which fits the build-time checking of `[%pgsql]`: one
  idempotent `update.sql` replayed on every database.
  `references/database.md` gives the layout, the guards and the Makefile targets.

## Internationalisation

- No user-facing string literal in `.eliom` files. With ocsigen-i18n, `[%i18n key]` yields
  TyXML nodes and `[%i18n S.key]` a string. Keys and translations live in
  `assets/myapp_i18n.tsv`, one column per language; group keys by feature or page.
- Translations follow each language's typography (for example the non-breaking space French
  puts before `:`, `;`, `?` and `!`, or German capitalisation of nouns). Demo:
  `demo_i18n.eliom`.

## Styling

- Stylesheets are SASS in `sass/`, compiled by `make css`. No inline styles in `.eliom`
  files.
- Prefix project classes with the project short name; `ot-` and `os-` are reserved for
  Ocsigen Toolkit and Ocsigen Start. Pick one class-naming convention and keep it across the
  project; BEM combines well with these prefixes.
- Recommended for applications that also target mobile: a mobile-first stylesheet (relative
  units, media queries), consistent spacing through CSS variables, strict alignment within
  the page.

## Build and run

- `make test.byte` (or `make test.opt`) builds both tiers and runs the server locally with
  the client program just built. Building with `make opt` and then launching the server by
  hand easily serves a stale client program.
- `make css` compiles SASS; `make db-init`, `db-create`, `db-schema` create a local
  PostgreSQL instance and load the schema (`Makefile.db`); `make mobile-all` builds the
  Cordova apps.
- Machine-specific settings (ports, paths, credentials) go in `Makefile.local`, never in
  `Makefile.options`.
