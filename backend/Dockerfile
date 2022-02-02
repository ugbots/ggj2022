FROM elixir:latest

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix do compile
RUN mix ecto.migrate

CMD mix phx.server
