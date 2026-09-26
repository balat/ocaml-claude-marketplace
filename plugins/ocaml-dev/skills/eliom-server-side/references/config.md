# Running Ocsigen Server and Eliom sites

## Contents

- Packages and directories
- Ocsigen Server as a library (static executable)
- Ocsigen Server as an executable with a configuration file
- Timeouts and limits

## Packages and directories

```
opam install ocsigenserver eliom ocsipersist-sqlite-config
mkdir -p local/var/log/mysite local/var/data/mysite local/var/run local/var/www/mysite
```

`logdir` receives the server logs, `datadir` the persistent data (ocsipersist, persistent
Eliom references), `command_pipe` the named pipe used to send commands to a running server,
and the static directory is served by `staticmod`.

## Ocsigen Server as a library

`bin/dune`:

```
(executable
 (public_name mysite)
 (name main)
 (libraries
  ocsigenserver
  ocsigenserver.ext.staticmod
  ocsipersist-sqlite
  eliom.server))
```

`bin/main.ml` defines and registers the services, then starts the server:

```ocaml
let () =
  Ocsigen.Server.start
    ~command_pipe:"local/var/run/mysite-cmd"
    ~logdir:"local/var/log/mysite"
    ~datadir:"local/var/data/mysite"
    [ Ocsigen.Server.host
        [ Staticmod.run ~dir:"local/var/www/mysite" ()
        ; Eliom.App.run () ] ]
```

`dune exec mysite` builds and runs it; the default port is 8080. This is what the
`app.exe` distillery template sets up.

## Ocsigen Server as an executable with a configuration file

Build the site as a library (`(libraries eliom.server)` in `lib/dune`, `dune build`), then
describe it in `mysite.conf`:

```xml
<ocsigen>
  <server>
    <port>8080</port>
    <logdir>local/var/log/mysite</logdir>
    <datadir>local/var/data/mysite</datadir>
    <charset>utf-8</charset>
    <commandpipe>local/var/run/mysite-cmd</commandpipe>
    <extension findlib-package="ocsigenserver.ext.staticmod"/>
    <extension findlib-package="ocsipersist-sqlite-config"/>
    <extension findlib-package="eliom.server"/>
    <host hostfilter="*">
      <static dir="local/var/www/mysite" />
      <eliommodule module="_build/default/lib/mysite.cma" />
      <eliom/>
    </host>
  </server>
</ocsigen>
```

Run `ocsigenserver -c mysite.conf`. Several `<eliommodule>` can be loaded into one host;
extensions such as `deflatemod`, `redirectmod`, `revproxy`, `accesscontrol` and
`authbasic` are declared the same way and configured inside `<host>`. This is what the
`app.lib` distillery template sets up.

## Timeouts and limits

Session and state timeouts are set either for all sites inside
`<extension findlib-package="eliom.server"/>` or for one site inside `<eliom/>`, for
example `<volatiletimeout value="3600"/>` (seconds; `infinity` for none), with optional
`level="session"` or `level="clientprocess"` attributes. They can also be set from code with
`Eliom.State.set_global_volatile_timeout` and related functions; by default the
configuration file wins unless `~override_configfile:true` is passed. The same section
holds the limits on the number of sessions per group and of temporary services per
session, which protect the server from unbounded growth.
