FROM hexpm/elixir:1.11.1-erlang-23.1.1-alpine-3.12.0

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
