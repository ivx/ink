FROM hexpm/elixir:1.12.1-erlang-24.0.3-alpine-3.13.3

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
