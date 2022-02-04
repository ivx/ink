FROM hexpm/elixir:1.13.2-erlang-24.2.1-alpine-3.15.0

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
