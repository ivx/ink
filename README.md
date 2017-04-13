# Ink

[![Build Status](https://travis-ci.org/ivx/ink.svg?branch=master)](https://travis-ci.org/ivx/ink)

Ink is a backend for the Elixir `Logger` with two main purposes:

- to log JSON documents instead of normal log lines
- to filter secret strings out of the log lines

## Installation

Just add `:ink` to your dependencies and `mix deps.get`.

```elixir
def deps do
  [{:ink, "~> 0.7"}]
end
```

## Usage

The only thing you have to do is drop some lines into your config.

```elixir
# this will add Ink as the only backend for Logger
config :logger,
  backends: [Ink]

config :logger, Ink,
  # remove secret strings from you logs
  filtered_strings: ["password", System.get_env("SECRET")]

# this is optional but recommended if you don't want secrets in your log files
# it will prevent crash and supervisor reports from being printed to the terminal
config :sasl, sasl_error_logger: false
```

Since JSON logs are hard to read when they are not parsed by i.e. LogStash, we
recommend you only use Ink in your production environment. But you can put the
same config in `dev.exs` for testing, of course.
