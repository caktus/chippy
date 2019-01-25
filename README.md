# Chippy

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

Chippy is deployed to Caktus' [Dokku](http://dokku.viewdocs.io/dokku/) infrastructure. This document assumes that
you have are familiar with Caktus' [Dokku Developer Docs](https://caktus.github.io/developer-documentation/dokku.html)
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

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
