# Ink

[![Build Status](https://travis-ci.org/ivx/ink.svg?branch=master)](https://travis-ci.org/ivx/ink)
[![Inline docs](http://inch-ci.org/github/ivx/ink.svg)](http://inch-ci.org/github/ivx/ink)

Ink is a backend for the Elixir `Logger` with two main purposes:

- to log JSON documents instead of normal log lines
- to filter secret strings out of the log lines

## Installation

Just add `:ink` to your dependencies and run `mix deps.get`.

```elixir
def deps do
  [{:ink, "~> 1.0"}]
end
```

## Usage

The only thing you have to do is drop some lines into your config.

```elixir
# this will add Ink as the only backend for Logger
config :logger,
  backends: [Ink]
```

For more information on how to use `Ink`, take a look
at [the docs](https://hexdocs.pm/ink/Ink.html).

## Maintenance

- get dependencies with `mix deps.get`
- execute tests with `mix test`
- update dependencies with `mix deps.update --all`
- execute tests again `mix test`
