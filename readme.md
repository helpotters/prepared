![img](./project-logo.png)

This is an Ruby on Rails application that demonstrates how to get up and running with [ReadySet](https://github.com/readysettech/readyset). You could use it as the base of your new project or as a guide to Dockerize your own Rails app running with ReadySet.

> Convention over configuration

We&rsquo;ll be using some tools from [Evil Martians](https://evilmartians.com/) to make this installation a more maintainable and extendable experience.

# Table of Contents

1.  [Getting Started](#org671e9fc)
    1.  [Prerequisites](#org314fe84)
        1.  [Docker](#orgf62f624)
        2.  [Dip (Docker interaction program)](#orgffe4cb8)
    2.  [Clone the repository](#orgf75f687)
    3.  [Add the environmental variables](#orgc35d90a)
    4.  [Build and run the docker compose services](#org546707f)
    5.  [Setup the database](#orgecb5ab7)
2.  [Caching](#org19e82d5)
    1.  [Check if ReadySet is, well, Ready](#org652a04d)
    2.  [Caching queries](#org6daf539)
3.  [Customization](#org57a9cfb)
4.  [Contribution](#orgeb0ac7a)
5.  [Additional Resources](#org4fc5dee)
6.  [About](#org4ed9e4b)
7.  [Future improvements](#org75811c0)


<a id="org671e9fc"></a>

# Getting Started

Follow these steps to get the application running on Docker, including a working example of a dictionary. At the end, we will also show you how to cache queries to ReadySet.


<a id="org314fe84"></a>

## Prerequisites


<a id="orgf62f624"></a>

### Docker

Ensure that you have [Docker](https://docs.docker.com/get-docker/) installed, including Docker Compose v2 support.

    docker compose version

This should return something like `Docker Compose version v2.xx.0`. If not, follow the Docker documentation to install it.


<a id="orgffe4cb8"></a>

### Dip (Docker interaction program)

Install [bibendi/dip](https://github.com/bibendi/dip) (sponsored by Evil Martians). It greatly simplifies how we&rsquo;ll be interacting with all the different parts of this dockerized application.

    gem install dip


<a id="orgf75f687"></a>

## Clone the repository

    git clone https://github.com/helpotters/prepared.git
    cd prepared


<a id="orgc35d90a"></a>

## Add the environmental variables

In `./.dockerdev`, let&rsquo;s make a `.env` file to pass the environmental variables. Make sure add `.env` to your `.gitignore` file at the root of the project.

    touch ./.dockerdev/.env

And inside that file, let&rsquo;s add the following default values.

    DATABASE_URL=postgres://postgres:postgres@postgres:5432
    DB_NAME=prepared_development
    DB_USER=postgres
    DB_PASSWORD=postgres
    
    READYSET_URL="postgres://postgres:postgres@cache:5433/${DB_NAME}"
    # ReadySet
    UPSTREAM_DB_URL="${DATABASE_URL}/${DB_NAME}"


<a id="org546707f"></a>

## Build and run the docker compose services

Downloading the Docker images may take a while depending on your internet connection speed and hardware.

Instead of using the normal Docker cli tool, we&rsquo;ll be using `dip`:

    dip up --build

Then install the gems.

    dip bundle

Then we&rsquo;ll have all the services run.

    dip up -d

> You can also use `dip down` to shut down the containers. Check dip.yml for all of the available commands.

And now you have a Rails app and environment! Visit `http://127.0.0.1:3000` to see the index page. Now let&rsquo;s seed the database so we have some words to lookup.


<a id="orgecb5ab7"></a>

## Setup the database

Create the database:

    dip rails db:create

Perform the migrations for `Word` and `Defintions`:

    dip rails db:migrate

And now we&rsquo;ll seed the database with example data (around 120K+ words from the English dictionary). This should only take around 1 minute.

    dip rails db:seed


<a id="org19e82d5"></a>

# Caching

Using ReadySet, we&rsquo;ll cache our *queries* not our data.

> Using an analogy, it&rsquo;s like making a second smaller library where 80% of visitors will find what they want. To have it organized, we&rsquo;ll need to still use the same &rsquo;model&rsquo; of how they would find the books in the main library. If the efficient library doesn&rsquo;t have it, a librarian will be find a book for a guest using the *same* method of access.

So, let&rsquo;s start caching.


<a id="org652a04d"></a>

## Check if ReadySet is, well, Ready

One of our Docker services is one called **cache**. This is the ReadySet caching layer, which is listening to our **postgres** server.

Let&rsquo;s check on the `cache` container&rsquo;s snapshotting progress.

    dip rails cache:check_status

Ideally, it&rsquo;ll say `"Completed"`. That will confirm that ReadySet is ready to cache queries. If not, we&rsquo;ll have to wait until it&rsquo;s done.


<a id="org6daf539"></a>

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


<a id="org57a9cfb"></a>

# Customization

-   Relevant files/config to make it easy for a user to modify the application to their own needs.


<a id="orgeb0ac7a"></a>

# Contribution


<a id="org4fc5dee"></a>

# Additional Resources


<a id="org4ed9e4b"></a>

# About


<a id="org75811c0"></a>

# Future improvements

-   Metrics currently don&rsquo;t showcase the improvements.

