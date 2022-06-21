FROM hexpm/elixir:1.13.4-erlang-24.3.4-alpine-3.16.0

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
