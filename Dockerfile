FROM hexpm/elixir:1.14.1-erlang-25.1.1-alpine-3.16.2

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
