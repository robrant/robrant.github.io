---
layout: post
title: "The usage stats should not be stored in PostgreSQL long term"
date: 2016-03-14 11:00
categories: future
tags:
    - future problems
author: "Mark Norman Francis"
---

The usage stats on tools are being stored in PostgreSQL. Longer term, this
will probably have to be reimplemented.

## Background

They landed in [PR #62][pr-62], and were implemented in django as a new table
that implements a "through" model for a many-to-many relationship. It sets up
a relationship between a `Link` and a `User` in a separate table that can
contain extra information about the relationship (we are also storing the
timestamp of when the usage started).

[pr-62]: https://github.com/dstl/lighthouse/pull/62

## Good enough for "now"

For prototyping, this is fine. For a small-scale production instance, this
is also fine. PostgreSQL can store millions of records in a table on fairly
average hardware and still perform well.

However, at some point when there are thousands of entries per day, querying
the table to present the stats will start to slow down. The queries done
against the DB are sometimes simple table scans, but sometimes more complex.

When the queries start to regularly take seconds to calculate, it will be time
to improve the code.

## Improvements

Adding [caching] around the presentation of stats on popular pages will
alleviate some of the pain where those calculations are taking time, but it
does not mitigate that the calculations take time initially, which leaves us
susceptible to [thundering herd problems][thp].

Some, or all, of the usage reports could be pre-calculated asychronously on a
regular basis and cached, and those values used instead of hitting the
database (and we could even get clever and do this on a read-only standby
server).

A better implementation, when storing the data in PostgreSQL becomes more
problematic, would be to use [a storage system more suited to time series
data][timedb]. But that would be a not insignificant amount of work, and as such
didn't seem worth doing during the initial build.

[caching]: https://docs.djangoproject.com/en/1.9/topics/cache/#template-fragment-caching
[thp]: https://en.wikipedia.org/wiki/Thundering_herd_problem
[timedb]: https://en.wikipedia.org/wiki/Time_series_database#Example_TSDB_Systems
