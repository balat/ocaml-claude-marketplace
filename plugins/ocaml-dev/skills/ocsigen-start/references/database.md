# Database schema management with Ocsigen Start and PG'OCaml

Two replayable SQL files, applied by `make db-update` on a new database as on an existing
one. This is the layout of the template since Ocsigen Start 9.0; the last section covers
projects generated with an earlier template.

## Contents

- Two replayable files
- The convention that keeps a file replayable
- Makefile targets
- Build order
- Projects generated before Ocsigen Start 9.0

## Two replayable files

- `ocsigen_start.sql`: the tables of Ocsigen Start (schema `ocsigen_start`: `users`,
  `emails`, `phones`, `activation`, `groups`, `user_groups`, `preregister`) and the
  triggers that keep `users.main_email` in sync with `emails`. Copied from the template,
  never edited. On an empty database it creates the tables; on an existing one it brings
  them up to date from any release since 0.99 (it merges groups that share a name); on an
  up-to-date one it changes nothing. It runs in one transaction and refuses to run as
  another role than the owner of the tables. After an upgrade of Ocsigen Start, replace it
  with the one of the new template (`$(opam var lib)/eliom/templates/os/ocsigen_start.sql`)
  and run `make db-update` again.
- `myapp.sql`: everything the application adds, including the columns it adds to the
  tables of Ocsigen Start (`ALTER TABLE ocsigen_start.users ADD COLUMN IF NOT EXISTS ...`).
  Same contract: one replayable file both creates the schema and migrates it, so there is no
  separate migration script to write.

## The convention that keeps a file replayable

```sql
\set ON_ERROR_STOP true
SET client_min_messages TO WARNING;

BEGIN;

CREATE SCHEMA IF NOT EXISTS myapp;

CREATE TABLE IF NOT EXISTS myapp.items (
  id         bigserial PRIMARY KEY,
  owner      bigint NOT NULL REFERENCES ocsigen_start.users (userid),
  created_at timestamptz NOT NULL DEFAULT now(),
  title      text NOT NULL
);

ALTER TABLE myapp.items ADD COLUMN IF NOT EXISTS notes text;

CREATE INDEX IF NOT EXISTS items_owner ON myapp.items (owner);

COMMIT;
```

Append later changes at the end, as guarded statements (`ADD COLUMN IF NOT EXISTS`,
`CREATE INDEX IF NOT EXISTS`, `CREATE OR REPLACE FUNCTION`); never rewrite an earlier
statement, since existing databases have already run it. Guard a data migration that is not
naturally idempotent with a `DO` block that checks the catalog or the data first; the
migrations at the end of `ocsigen_start.sql` are examples (a column type checked in
`pg_attribute`, a unique index checked in `pg_index`). The transaction makes a failed run a
no-op, and `ON_ERROR_STOP` makes `make` fail on it.

## Makefile targets

`Makefile.db` provides `db-init` (local PostgreSQL cluster), `db-create` (the database of
the project and the one of Ocsipersist), `db-update` (`ocsigen_start.sql` then `myapp.sql`,
that is `OS_PSQL_FILE` then `PSQL_FILE` from `Makefile.options`), `db-snapshot` (local
database only), `db-psql`, `db-drop` and `db-delete`.

New database: `make db-init db-create db-update`. After a change of `myapp.sql`, or after an
upgrade of Ocsigen Start: `make db-update`, with a backup first (`db-snapshot` for a local
database, `pg_dump` otherwise).

## Build order

`[%pgsql]` queries are type-checked against the live database. Run `make db-update` before
`make`, and in production apply the SQL files before deploying the new binary. A build error
about an unknown column or relation usually means the change has not been applied to the
database the build is using.

## Projects generated before Ocsigen Start 9.0

Their `myapp.sql` holds the tables of Ocsigen Start and of the application as plain
`CREATE TABLE` statements: `make db-schema` only works on an empty database, and the
`db-upgrade` target has been broken since 2024. Two ways forward:

- Move to the 9.0 layout: copy `ocsigen_start.sql` from the 9.0 template, move the
  statements of the application into a replayable `myapp.sql` written as above, replace
  `db-schema` by `db-update` (two `psql -q -d $(DB_NAME) -f` lines) and let `db-create`
  create `ocsipersist_myapp` too. `ocsigen_start.sql` brings the existing database up to
  date by itself.
- Keep `myapp.sql` untouched as the bootstrap and put the changes of the application in a
  replayable `update.sql`, applied by a `db-update` target
  (`psql -d $(DB_NAME) -f update.sql`). New database: `make db-create db-schema db-update`;
  existing one: `make db-update`. Check the project's `Makefile.db` first: some projects
  already chain `update.sql` into `db-schema`.
