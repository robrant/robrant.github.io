---
layout: post
title:  "Use the django web framework"
date:   2016-01-18 14:00
categories: decisions
tags:
    - current decision
author: "Mark Norman Francis"
---

## Context

After deciding [not to continue with the original code base][restart], we had to pick how
to build the new version of lighthouse.

Python was already a given, so the choices were microframeworks (eg bottle,
flask), a larger framework such as django, or writing our own WSGI system from
scratch.

[restart]: /2016/01/create-new-code

## Decision

Given the short time frame, using a more fully featured framework seemed wise,
in order to concentrate our efforts on solving the problem at hand. Django has
excellent support for building websites and APIs and has a mature LDAP plugin
available.

## Status

We are building the lighthouse code base in django.

## Consequences

Not all of the team is familiar with django, so despite its excellent
reference documentation initial development is likely to be slower.
