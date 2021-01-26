FROM hexpm/elixir:1.11.3-erlang-23.2.3-alpine-3.12.1

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
