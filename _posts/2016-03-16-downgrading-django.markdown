---
layout: post
title: "Downgrading django"
date: 2016-03-16 14:00
categories: django
author: "Mark Norman Francis"
---

To implement keyword and free text searching, we are using a django module
called [Haystack] which implements a backend-agnostic search interface. It
makes it easy to get started with search using a pure-Python library called
[Whoosh] and then upgrade to a backend such as [elasticsearch] later. Or even
to use different backends in development from production.

[Haystack]: http://haystacksearch.org
[Whoosh]: https://pypi.python.org/pypi/Whoosh
[elasticsearch]: https://www.elastic.co/products/elasticsearch

## A slight problem with Haystack

Currently, Haystack doesn't fully support Django 1.9. But this project started
with Django 1.9.1. There are branches of Haystack that fix most of the
outstanding problems, but they have yet to be officially released.

Therefore we decided to downgrade to Django 1.8.

## A slight problem with Django 1.8

After changing the `requirements.txt` file to use 1.8.11, almost every test
failed. It turned out we were using one feature introduced in Django 1.9.
Fortunately, this is a feature which is easily backported for our needs.
Once that was done, all of the tests passed again, except one (a subtle
change in how redirects were generated in 1.8 vs 1.9).
