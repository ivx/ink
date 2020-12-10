FROM hexpm/elixir:1.11.2-erlang-23.1.5-alpine-3.12.1

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
