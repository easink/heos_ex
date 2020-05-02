# Heos

Simple Elixir Heos library.

For now it only supports some API functions.

## Installation

```elixir
def deps do
  [
    {:heos, "~> 0.1.0", github: "easink/heos_ex"}
  ]
end
```

## Usage

    {:ok, conn} = Heos.Supervisor.start_link(host: "192.168.0.1")
    Heos.connect(conn)
    Heos.subscribe()
    Heos.Commands.Player.get_players(conn)


## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/heos](https://hexdocs.pm/heos).

## Copyright 2020 Andreas Rydbrink.

Heos source code is released under Apache 2 License.

Check LICENSE file for more information.

