# Sysevents

For tracking and visualising project events

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sysevents` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sysevents, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sysevents](https://hexdocs.pm/sysevents).

Some random nodes on migrating and creating the DB from [tutorial](https://codewords.recurse.com/issues/five/building-a-web-framework-from-scratch-in-elixir)

```
mix ecto.gen.migration create_events
```
Now go and edit the migration in the `priv` folder.

```
mix ecto.migrate --all
```

Inserting records into the database
```
iex(1)> Sysevents.Repo.start_link
{:ok, #PID<0.215.0>}
iex(2)>
nil
iex(3)> event = %Event{id: 0, event_id: "0123", parent_id: "321", type: "some_event"}
%Event{__meta__: #Ecto.Schema.Metadata<:built>, event_id: "0123", id: 0,
 parent_id: "321", type: "some_event"}
iex(4)> Sysevents.Repo.insert!(event)
%Event{__meta__: #Ecto.Schema.Metadata<:loaded>, event_id: "0123", id: 0,
 parent_id: "321", type: "some_event"}
iex(5)>
```


Sample sqlite console work after running the unit tests:
```
#[↑0]$gbn6192@MLGBLOCR04-0078:~/Documents/gitroot/sysevents>
sqlite3
SQLite version 3.8.10.2 2015-05-20 18:17:19
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .open sysevents.sqlite3
sqlite> .scheme events
Error: unknown command or invalid arguments:  "scheme". Enter ".help" for help
sqlite> .schema events
CREATE TABLE "events" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "event_id" TEXT, "parent_id" TEXT, "type" TEXT);
sqlite> select * from events;
0|0123|321|some_event
1|123|321|test_event
2|123|321|test_event
```
