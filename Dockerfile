FROM hexpm/elixir:1.11.4-erlang-23.2.7-alpine-3.13.2

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
