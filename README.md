# Ink

[![Build Status](https://travis-ci.org/ivx/ink.svg?branch=master)](https://travis-ci.org/ivx/ink)
[![Module Version](https://img.shields.io/hexpm/v/ink.svg)](https://hex.pm/packages/ink)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ink/)
[![Total Download](https://img.shields.io/hexpm/dt/ink.svg)](https://hex.pm/packages/ink)
[![License](https://img.shields.io/hexpm/l/ink.svg)](https://github.com/ivx/ink/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/ivx/ink.svg)](https://github.com/ivx/ink/commits/master)

Ink is a backend for the Elixir `Logger` with two main purposes:

- to log JSON documents instead of normal log lines
- to filter secret strings out of the log lines

## Installation

Just add `:ink` to your dependencies and run `mix deps.get`.

```elixir
def deps do
  [
    {:ink, "~> 1.0"}
  ]
end
```

## Usage

The only thing you have to do is drop some lines into your config.

```elixir
# this will add Ink as the only backend for Logger
config :logger,
  backends: [Ink]

# at least configure a name for your app
config :logger, Ink,
  name: "your app"
```

For more information on how to use `Ink`, take a look
at [the docs](https://hexdocs.pm/ink/Ink.html).

## Maintenance

- get dependencies with `mix deps.get`
- execute tests with `mix test`
- update dependencies with `mix deps.update --all`
- execute tests again `mix test`

## Copyright and License

Copyright (c) 2018 InVision AG

This library is licensed under the [MIT License](./LICENSE.md).
