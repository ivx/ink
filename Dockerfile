FROM hexpm/elixir:1.13.3-erlang-24.3.3-alpine-3.15.3

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
