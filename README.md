# Locution

Simple Rails and Postgres application. Extremely simple. The goal w/this project is to document how to get up and running w/[ReadySet](https://github.com/readysettech/readyset) in a Rails environment.

A few things to note, nevertheless:

 1. Use the provided `docker-compose.yml` file to fire up Postgres. This can be done w/`docker compose up -d`. If you want to stop Postgres, use `docker compose stop`. 
 <% require 'pry'; binding.pry %>
2. The way things are configured assumes ReadySet is running on port 5433 -- see the `database.yml` file. If you do NOT have ReadySet running, simply change this port to 5432 (Postgres direct).  See the `etc`
 directory for a `readyset-compose.yml` file.  
 3. You'll need to run a database migration to set up the database. `bin/rails db:migrate`
 4. There's a Ruby script in the `etc` directory dubbed `seed_database.rb` that will pump quite a lot of words and corresponding definitions into Postgres. 
 

Helpful links

* [Rails command line](https://guides.rubyonrails.org/command_line.html)
* [Setting up Postgres w/Docker](https://geshan.com.np/blog/2021/12/docker-postgres/)
* [Postgres docker image](https://hub.docker.com/_/postgres)
* Rails uses a Ruby gem to connect to Postgres and this gem requires native code. To fix PG lib errors on OSX, see [SO](https://stackoverflow.com/questions/6209797/cant-find-the-postgresql-client-library-libpq)
* Pagination done via [kaminari](https://betterprogramming.pub/pagination-in-rails-b3a9ba25b3c3)
* Having trouble installing Ruby 3.2.x on OSX? Using Homebrew too? Ensure you have [OpenSSL installed and try running](https://github.com/rvm/rvm/issues/5261) `rvm install 3.2.x --with-openssl-dir=/opt/homebrew/opt/openssl@1.1`

## Generic setup regardless of database

Once you've configured a database -- locally via Docker or via RDS (either Postgres or Aurora Postgres), you'll need to create a `.env` file with the following keys:

```
POSTGRES_USER='some_user'
POSTGRES_PASSWORD='some_password'
POSTGRES_HOST='a_url'
POSTGRES_DB='locution'
POSTGRES_TEST_DB='locution'
READY_SET_HOST='another_url'
```

You'll see that the `database.yml` is seeking the values of these keys to configure things. You'll first need to run a migration to set up the database structure: `bin/rails db:migrate`. 

Go to `http://localhost:3000/words/` and you should see a simple blank page with a link to create a new word. If you've gotten this far, then things are working. If you'd like to seed the database with a dictionary's worth of words you can run the following command from the root of this project:

```
psql postgresql://user:password@database_url:5432/database < etc/all-words-data-only-export.sql
```

Depending on your database and the network between you and it, this might take awhile. Like hours. 

## Postgres docker setup

First time: `docker compose up -d` and then use `start` and to stop, use `docker compose stop` and to start over (remove things) use `down`. 

## Connecting to Postgres

Simply run `psql postgresql://postgres:locution@127.0.0.1:5432/locution` and if you want to connect directly to ReadySet, replace `5432` w/`5433`

ReadySet running on port 5433. Allow full materialization set to false by default. If you want to test w/it on, `--allow-full-materialization`

## ReadySet

If you run ReadySet w/the provided `readyset-compose.yml` file, you'll have access to a Grafana dashboard. This'll be helpful later on and you can go to `http://localhost:4000/` to see a few things; namely, what queries are cached and which are proxied (i.e. are passed directly to Postgres). With full materialization disabled, only a few queries are cache-able. They are:

```
SELECT "definitions".* FROM "definitions" WHERE ("definitions"."word_id" = $1)
SELECT "words".* FROM "words" WHERE ("words"."id" = $1)
SELECT "words".* FROM "words" WHERE ("words"."id" = $1) ORDER BY "words"."id" ASC
```

This is a simple application and it turns out that almost all functionality of using dictionary refers to these queries. Because full materialization is off by default, you'll see a few queries that load _everything_ such as `SELECT "words".* FROM "words" ORDER BY "words"."id" ASC` or even `SELECT count(*) FROM "words"` that are marked as `unsupported`. 

## Prometheus metrics

There's a `metrics/` endpoint associated with this application that emits Prometheus style metrics. You can find a corresponding `prometheus.yml` file in the `etc/` directory that configures Prometheus. To run Prometheus, type:

```
 docker run -p 9090:9090 -v ./etc/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

Note, the configuration assumes that Rails is running in a non-containerized environment; hence, you'll note that Prometheus is configured to hit `host.docker.internal:3000/metrics`. 
