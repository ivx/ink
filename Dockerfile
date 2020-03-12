FROM elixir:1.10.2-alpine

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /code
COPY . /code

RUN mix deps.get

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["test"]
