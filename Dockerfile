FROM hexpm/elixir:1.10.3-erlang-22.3.4.2-ubuntu-focal-20200423 as builder
RUN mix local.rebar --force && \
    mix local.hex --force
WORKDIR /app
ENV MIX_ENV=prod
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod, deps.compile

FROM node:12.16.1 as frontend
WORKDIR /app/assets
COPY assets/package.json assets/package-lock.json /app/assets/
COPY --from=builder /app/deps /app/deps/
RUN npm ci --progress=false --no-audit --loglevel=error

COPY priv /app/priv
COPY assets /app/assets
RUN npm run deploy

FROM builder as releaser
ENV MIX_ENV=prod
COPY --from=frontend /app/priv/static /app/priv/static
COPY . /app/
RUN mix phx.digest
RUN mix release

FROM ubuntu:20.04 AS app
ENV LANG=C.UTF-8
RUN apt-get update && apt-get install -y openssl postgresql-client
RUN useradd --create-home --home-dir /app app
WORKDIR /app
USER app
COPY --from=releaser --chown=app:app /app/_build/prod/rel/chippy ./
COPY --from=releaser --chown=app:app /app/docker-entrypoint.sh .

CMD ["bin/chippy", "start"]
ENTRYPOINT ["./docker-entrypoint.sh"]
