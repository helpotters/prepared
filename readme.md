![img](./project-logo.png)

This is an Ruby on Rails application that demonstrates how to get up and running with [ReadySet](https://github.com/readysettech/readyset). You could use it as the base of your new project or as a guide to Dockerize your own Rails app running with ReadySet.

This application follows the Rails motto of &ldquo;Convention over Configuration&rdquo; to simplify the experience of using a fully-dockerized Rails app in addition to the ReadySet caching layer.

    
# Table of Contents

1.  [Getting Started](#org7b86bdd)
    1.  [Prerequisites](#orgd015a94)
        1.  [Docker](#orga328469)
        2.  [Dip (Docker interaction program)](#org61139e2)
    2.  [Clone the repository](#org5c9e74d)
    3.  [Add the environmental variables](#org9d75114)
    4.  [Build and run the docker compose services](#orgf89384e)
    5.  [Setup the database](#org60e0478)
2.  [Caching](#orgf63cf94)
    1.  [Check on initialization progress](#org32200dd)
    2.  [Caching queries](#orgc3951d8)
3.  [Customization](#orgb3fbc95)
4.  [Contribution](#org9d19d79)
5.  [Additional Resources](#org0447fce)
6.  [About](#orgdabb203)
7.  [Future improvements](#orga3f9e82)


<a id="org7b86bdd"></a>

# Getting Started

Follow these steps to get the application running on Docker, including a working example of a dictionary. At the end, we will also show you how to cache queries to ReadySet.


<a id="orgd015a94"></a>

## Prerequisites


<a id="orga328469"></a>

### Docker

Ensure that you have [Docker](https://docs.docker.com/get-docker/) installed, including Docker Compose v2 support.

    docker compose version

This should return something like `Docker Compose version v2.xx.0`.


<a id="org61139e2"></a>

### Dip (Docker interaction program)

Install [bibendi/dip](https://github.com/bibendi/dip) (sponsored by Evil Martians). It greatly simplifies how we&rsquo;ll be interacting with all the different parts of this dockerized application. Convention over Configuration!

    gem install dip


<a id="org5c9e74d"></a>

## Clone the repository

    git clone https://github.com/helpotters/prepared.git
    cd prepared


<a id="org9d75114"></a>

## Add the environmental variables

In `./.dockerdev`, let&rsquo;s make a `.env` file to pass the environmental variables. It is best to ignore it in your version control system.

    touch ./.dockerdev/.env

And inside that file, let&rsquo;s add the following default values.


<a id="orgf89384e"></a>

## Build and run the docker compose services

Downloading the Docker images may take a while depending on your internet connection speed and hardware.

Instead of using the normal Docker cli tool, we&rsquo;ll be using `dip`:

    dip up --build

Then install the gems.

    dip bundle # defined in dip.yml

Then we&rsquo;ll have all the services run.

    dip up -d # the -d flag allows it to run the background

> You can also use `dip down` to shut down the containers. Check dip.yml for all of the available commands.

And now you have a Rails app and environment! Visit `http://127.0.0.1:3000` to see the index page. Now let&rsquo;s seed the database so we have some words to lookup.


<a id="org60e0478"></a>

## Setup the database

Create the database:

    dip rails db:create

Perform the migrations for `Word` and `Defintions`:

    dip rails db:migrate

And now we&rsquo;ll seed the database with example data (around 120K+ words from the English dictionary). This should only take around 1 minute.

    dip rails db:seed


<a id="orgf63cf94"></a>

# Caching

ReadySet provides performances to postgres via a SQL caching layer. It does by turning the execution plans of submitted queries into a *representation* of what the database *was* going to perform.

It&rsquo;ll store the relevant data in memory, and requests will pass through that representation until it finds its data. If it doesn&rsquo;t, it&rsquo;ll just pass through to the database.


<a id="org32200dd"></a>

## Check on initialization progress

One of our Docker services is one called **cache**. This is the ReadySet caching layer, which is listening to our **postgres** server.

Let&rsquo;s check on the `cache` container&rsquo;s snapshotting progress.

    dip rails cache:check_status

Ideally, it&rsquo;ll say `"Completed"`. That will confirm that ReadySet is ready to cache queries.


<a id="orgc3951d8"></a>

## Caching queries

The following queries are the ones we&rsquo;re running in our application.

    SELECT "definitions".* FROM "definitions" WHERE ("definitions"."word_id" = $1)
    SELECT "words".* FROM "words" WHERE ("words"."id" = $1)
    SELECT "words".* FROM "words" WHERE ("words"."id" = $1) ORDER BY "words"."id" ASC

Let&rsquo;s cache those queries using this easy command.

    dip rails cache:submit_queries

And we can view the caches with the following:

    dip rails cache:views_caches

> This would the part where we would look at the &ldquo;confirmation&rdquo; of Noria working.


<a id="orgb3fbc95"></a>

# Customization

-   Relevant files/config to make it easy for a user to modify the application to their own needs.


<a id="org9d19d79"></a>

# Contribution


<a id="org0447fce"></a>

# Additional Resources


<a id="orgdabb203"></a>

# About


<a id="orga3f9e82"></a>

# Future improvements

-   Metrics currently don&rsquo;t showcase the improvements.

