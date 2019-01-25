# Chippy

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Local dev setup

The steps above should get you running. You can also make local configurations which won't go into
version control. As an example, if you want the app to connect to Postgresql via unix domain
sockets, add this to `config/dev.secret.exs`:

```
use Mix.Config

config :chippy, Chippy.Repo,
  socket_dir: "/var/run/postgresql",
  username: "vkurup",
  password: "",
  database: "chippy_dev",
```

To run the Phoenix server, while also having a command line to inspect stuff:

```
iex -S mix phx.server
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
