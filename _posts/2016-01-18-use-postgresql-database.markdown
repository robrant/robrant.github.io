---
layout: post
title:  "Use the postgresql database"
date:   2016-01-18 14:15
categories: decisions
tags:
    - current decision
author: "Mark Norman Francis"
---

## Context

As lighthouse will be storing data, we need to decide what system to keep it
in.

Various options exist, from relational databases such as PostgreSQL and MySQL,
to more document oriented systems like mongo and couchdb.

## Decision

Having [decided to use django][dj], it seemed wise to pick a backing store
that django was already integrated with. That, plus the relational nature of
the data to be stored.

By default django supports PostgreSQL, MySQL, SQLite and Oracle. Oracle is 
not an option, and SQLite is generally only suitable for apps with few users,
mostly read-only data, or in embedded systems. 

We chose PostgreSQL over MySQL, mostly because it has excellent support in
django, and is a mature and well-respected database engine.

## Status

We are using Postgres.

## Consequences

Creation of, and changes to data models will be need to be done via the django
migrations framework.

We will need to invest some time in creating a backup and restore mechanism
for the database as dstl is light on operational staff.

[dj]: /2016/01/use-django-web-framework
