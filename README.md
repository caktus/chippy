# Chippy

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

Chippy is deployed to Caktus' Kubernetes cluster.

We use [invoke-kubesae](https://github.com/caktus/invoke-kubesae) for deployment, so
you'll need a Python virtualenv. Install the requirements:

```
pip install -U -r requirements.txt
```

To build the image:

```
inv image.build
```

The env vars needed by the docker image are:

* HOSTNAME=chippy-staging.caktus-built.com
* PORT=4000
* DATABASE_URL=postgres://username:password@db_host:5432/chippy
* LIVE_VIEW_SIGNING_SALT=supersecret
* SECRET_KEY_BASE=supersecret
* MIGRATE=on


FIXME: The following part of this section is currently true, but will be removed once the migration to
kubernetes is complete.

Chippy is deployed to Caktus' [Dokku](http://dokku.viewdocs.io/dokku/) infrastructure. This document assumes that
you are familiar with Caktus' [Dokku Developer Docs](https://caktus.github.io/developer-documentation/dokku.html)
and have an account on the Dokku server.

Create a new app:

```
   $ ssh dokku apps:create {{ project_name }}
   Creating {{ project_name }}... done
```

Create and link the database:

```
    $ ssh dokku postgres:create {{ project_name }}-database
    ...
    $ ssh dokku postgres:link {{ project_name }}-database {{ project_name }}
    ...
```

Set required environment variables:

```
    $ ssh dokku config:set {{ project_name }} HOSTNAME={{ project_name }}.caktustest.net
    $ ssh dokku config:set {{ project_name }} SECRET_KEY_BASE=<64char string>
```

Configure SSL via the Let's Encrypt Plugin:

```
    $ ssh dokku config:set --no-restart {{ project_name }} DOKKU_LETSENCRYPT_EMAIL=your@email.tld
    $ ssh dokku letsencrypt {{ project_name }}
    $ ssh dokku letsencrypt:cron-job --add {{ project_name }}
```

Configure the Git repository and deploy!

```
    $ git remote add dokku dokku:chippy
    $ git push dokku master
```

If you want to deploy a branch:

```
    $ git push dokku <branch-name>:master
```

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Local dev setup

The steps above should get you running. You can also make local configurations which won't go into
version control. As an example, if you want the app to connect to Postgresql via unix domain
sockets, add this to `config/dev.secret.exs`:

```
import Config

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
