FROM hexpm/elixir:1.12.3-erlang-24.1.2-alpine-3.14.2

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
