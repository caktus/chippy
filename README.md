# Chippy

## License

This application is released under the BSD License. See the
[LICENSE](https://github.com/caktus/ansible-role-k8s-web-cluster/blob/master/LICENSE)
file for more details.

Development sponsored by [Caktus Consulting Group, LLC](http://www.caktusgroup.com/services>).

## Quickstart

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

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

## Deployment

### Automatic CI/CD

Chippy is automatically deployed to Caktus' Kubernetes cluster using CircleCI.

Every push to ``develop`` is automatically deployed to staging, and every push to
``master`` is automatically deployed to production.

### Manual deployment

We use [invoke-kubesae](https://github.com/caktus/invoke-kubesae) for deployment, so
you'll need a Python virtualenv. Install the requirements:

```
pip install -U -r requirements.txt
```

Get an AWS account on the Caktus AWS subaccount and create a profile named chippy.
You'll need to fill in your access key ID and your secret key:

```
aws --profile chippy configure
...
```

[Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Login to the docker registry and configure kubectl:

```
inv aws.docker-login
inv aws.configure-eks-kubeconfig
```

To deploy the current working directory to staging:

```
inv staging image deploy
```

## Setting up a new namespace on the cluster

These are the main steps used to create the staging namespace in the Caktus cluster (and
then repeated to create the production namespace). We'll need to do some of them again
for any other environment we'd like to add.

### Set up the python requirements

* We'll use some python tools to help us with the deployment, so create a Python3
  virtualenv and install the requirements:

```
pip install -U -r requirements.txt
```

### Get AWS access

* Get access to Caktus Cluster subaccount, which will give you an AWS access key ID and
  an AWS secret key. Use those to create an AWS profile named "chippy":

```
aws --profile chippy configure
```

* Make sure that your profile is set to that profile whenever you're doing
  deployment-related work:

```
export AWS_PROFILE=chippy
```

### Set up docker registry

* These steps only need to be done once. We'll use the same repository for staging and
  production images:

```
aws ecr create-repository --repository-name chippy
```

* Set `repository` in tasks.py to the repository URI.

* Test it out:

```
inv aws.docker-login
inv image.push
```

* Check to be sure the image was pushed:

```
aws ecr list-images --repository-name chippy
```

### Get access to cluster

```
inv aws.configure-eks-kubeconfig
```

### Create a DB on the existing RDS instance

* Get the RDS params you'll need:

```
aws rds describe-db-instances
```

* From that output, get `MasterUsername`, `DBName`, and `Endpoint.Address`.
* Get the `MasterPassword` from the LastPass entry.
* Choose or generate a `ChippyDbPassword` that you'll use for chippy. Save that somewhere so that you
  can encrypt it later in the process.

* Then create the DB with the proper permissions:

```
$ inv pod.debian
root@debian:/# apt update && apt install postgresql-client -y
root@debian:/# psql postgres://{MasterUsername}:{MasterPassword}@{Endpoint.Address}:5432/{DBName}
=> CREATE DATABASE chippy_staging;
=> CREATE ROLE chippy_staging WITH LOGIN NOSUPERUSER INHERIT CREATEDB NOCREATEROLE NOREPLICATION PASSWORD '<ChippyDbPassword>';
=> GRANT CONNECT ON DATABASE chippy_staging TO chippy_staging;
=> GRANT ALL PRIVILEGES ON DATABASE chippy_staging TO chippy_staging;
```

### Set up deploy directory structure

* Most of this section only needs to be done once. If you are adding a new environment,
  then copy the `host_vars/staging.yaml` file to then env name that you are creating and
  update the values in it. Then add the new environment to `inventory`.

* Copy the deploy directory from an existing Caktus k8s project.

* It should look something like this:

  ```
  chippy/deploy:
    ansible.cfg
    deploy.yaml
    echo-vault-pass.sh
    group_vars/
      k8s.yaml
    host_vars/
      staging.yaml
    inventory
    requirements.yaml
  ```

### Point your desired domain at the load balancer

* Find the load balancer URL:

  ```
  kubectl get svc -n ingress-nginx
  ```

* Copy the EXTERNAL-IP, which is the load balancer URL.

* Go to Cloudflare and create a CNAME from your desired subdomain pointing to that URL.

### Set up vault password

* These instructions only need to be done once. We use the same vault password for
  staging and production.

* Generate a long password and save it to AWS with this command:

  ```
  aws secretsmanager create-secret --name chippy-ansible-vault-password --secret-string <long-secret>
  ```

* Record the ARN that is returned, you'll need that for setting up CI later

### Create the k8s service account and get the secret API key

* Follow the instructions in [the Django k8s
  repo](https://github.com/caktus/ansible-role-django-k8s) to create the service account
  that will do the deploys, and get the API key for that account.

* This involves running the deploy once, which will output instructions to encrypt and add
  `k8s_auth_api_key` to your `host_vars/<env>.yaml` file

* Use this command to encrypt that value and any other value in `host_vars/<env>.yaml`
  that needs encrypting:

  ```
  cd deploy
  ansible-vault encrypt_string <secret>

  ```

* Finally, do the deploy again, and it should work.

### Setting up Circle CI deployment

This has already been done, and should not need to be done again for this repo. The same
IAM user that we created can do both staging and production deploys.

* Use the [k8s web cluster role to create a limited IAM
  user](https://github.com/caktus/ansible-role-k8s-web-cluster#adding-a-limited-aws-iam-user-for-ci-deploys)

* Create an AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY pair in the AWS console.

* Enter those values, and AWS_REGION="us-east-1" into the [Circle CI environment
  variables console](https://app.circleci.com/settings/project/github/caktus/chippy/environment-variables)

* Those AWS creds are not stored anywhere else, and they are not retrievable from the
  CircleCI interface. The only way to "view" the secret access key would be to
  regenerate a new pair.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
