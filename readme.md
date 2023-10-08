![img](./project-logo.png)

This is an Ruby on Rails application that demonstrates how to get up and running with [ReadySet](https://github.com/readysettech/readyset). You could use it as the base of your new project or as a guide to Dockerize your own Rails app running with ReadySet.

> Convention over configuration

We&rsquo;ll be using some tools from [Evil Martians](https://evilmartians.com/) to make this installation a more maintainable and extendable experience.

# Table of Contents

1.  [Getting Started](#org776e7d0)
    1.  [Prerequisites](#orgdf82dde)
        1.  [Docker](#orgd915805)
        2.  [Dip (Docker interaction program)](#org98bcd17)
    2.  [Clone the repository](#orga74e390)
    3.  [Add the environmental variables](#orgd4d747a)
    4.  [Build and run the docker compose services](#orgb90e50b)
    5.  [Setup the database](#org05f9fa7)
2.  [Caching](#orga362622)
    1.  [Check if ReadySet is, well, Ready](#org7c01add)
    2.  [Caching queries](#orgd24d4ad)
3.  [Customization](#org04233d2)
4.  [Contribution](#org47fa2c6)
5.  [Additional Resources](#org4535192)
6.  [About](#org6c184bf)
7.  [Future improvements](#orgfb719e8)


<a id="org776e7d0"></a>

# Getting Started

Follow these steps to get the application running on Docker, including a working example of a dictionary. At the end, we will also show you how to cache queries to ReadySet.


<a id="orgdf82dde"></a>

## Prerequisites


<a id="orgd915805"></a>

### Docker

Ensure that you have [Docker](https://docs.docker.com/get-docker/) installed, including Docker Compose v2 support.

    docker compose version

This should return something like `Docker Compose version v2.xx.0`. If not, follow the Docker documentation to install it.


<a id="org98bcd17"></a>

### Dip (Docker interaction program)

Install [bibendi/dip](https://github.com/bibendi/dip) (sponsored by Evil Martians). It greatly simplifies how we&rsquo;ll be interacting with all the different parts of this dockerized application.

    gem install dip


<a id="orga74e390"></a>

## Clone the repository

    git clone https://github.com/helpotters/prepared.git
    cd prepared


<a id="orgd4d747a"></a>

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


<a id="orgb90e50b"></a>

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


<a id="org05f9fa7"></a>

## Setup the database

Create the database:

    dip rails db:create

Perform the migrations for `Word` and `Defintions`:

    dip rails db:migrate

And now we&rsquo;ll seed the database with example data (around 120K+ words from the English dictionary). This should only take around 1 minute.

    dip rails db:seed


<a id="orga362622"></a>

# Caching

Using ReadySet, we&rsquo;ll cache our *queries* not our data.

> Imagine creating a smaller, more efficient grocery store where 80% of shoppers can easily find what they need. If the smaller store doesn&rsquo;t have a particular item, they&rsquo;ll find it at the main store by walking the same, but now longer, path.

Now, let&rsquo;s see how we can cache our most common queries.


<a id="org7c01add"></a>

## Check if ReadySet is, well, Ready

One of our Docker services is one called **cache**. This is the ReadySet caching layer, which is listening to our **postgres** server.

Let&rsquo;s check on the `cache` container&rsquo;s snapshotting progress.

    dip rails cache:check_status

Ideally, it&rsquo;ll say `"Completed"`. That will confirm that ReadySet is ready to cache queries. If not, we&rsquo;ll have to wait until it&rsquo;s done.


<a id="orgd24d4ad"></a>

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


<a id="org04233d2"></a>

# Customization

-   Relevant files/config to make it easy for a user to modify the application to their own needs.


<a id="org47fa2c6"></a>

# Contribution


<a id="org4535192"></a>

# Additional Resources


<a id="org6c184bf"></a>

# About


<a id="orgfb719e8"></a>

# Future improvements

-   Metrics currently don&rsquo;t showcase the improvements.

