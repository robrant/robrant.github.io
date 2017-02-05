---
layout: post
title: "Search might not use Whoosh long term"
date: 2016-03-16 14:30
categories: future
tags:
    - future problems
author: "Mark Norman Francis"
---

As stated in [downgrading Django], we are using [Whoosh] as the backend for
searching by keyword. This enables us to build the feature easily and quickly.
However, Whoosh may not be a good long-term choice.

[downgrading Django]: /2016/03/downgrading-django
[Whoosh]: https://pypi.python.org/pypi/Whoosh

## Good enough for "now"

To get started with search, Whoosh is a good choice: it is pure-Python, which
means it has no external dependencies, so there are no services to setup, 
configure and maintain. It is also quite extendible, having support for more
advanced search features such as stemming, faceting, correction suggestions
and more.

And with a small enough set of data, Whoosh is more than capable of returning
search results in an unnoticable amount of time.

## When, maybe, to replace it

Whoosh will struggle to respond quickly once the number of indexed items is
large. However, we expect that to be on the order of tens of thousands of
items, which shouldn't be a problem for lighthouse for quite a while.

If it ever does become a problem, replacing the search backend in lighthouse
with a service (like elasticsearch or solr) would be the solution. This is
made easier by the app [using Haystack] as the intermediary.

[using Haystack]: /2016/03/downgrading-django
