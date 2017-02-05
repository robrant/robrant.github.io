---
layout: post
title: "Adding authorisation to the lighthouse API"
date: 2016-04-06 15:30
categories: future
tags:
    - future enhancements
author: "Mark Norman Francis"
---

A very basic example of how to provide an API for lighthouse features was
added in [pull request #91][pr91]. As the PR (and the documentation added
later in [pull request #127][pr127]) notes, this API provides no 
authentication.

If authorisation was needed in the future, here are some broad strategies to
consider:

 1. Add a randomly generated token to the `Link` model upon creation, and 
    insist this is passed in an HTTP header with every request.

 1. Replace the current code and start using the Django [REST
    framework][rest]. We considered this for the early API work, but it seemed
    overkill at the time. If there was to be significant work adding to the
    lighthouse API in future, it might make sense to use it. The REST
    framework ships with good support for [many types of
    authentication][restauth].

 1. Choose one of the authentication types that the REST framework supports,
    but use it directly instead of via the framework.

The best strategy will really depend on why authentication is being added,
and what is really being authenticated (the app sending data, or the user
it is sending it on behalf of).


[pr91]:https://github.com/dstl/lighthouse/pull/91
[pr127]:https://github.com/dstl/lighthouse/pull/127
[rest]:http://www.django-rest-framework.org
[restauth]: http://www.django-rest-framework.org/api-guide/authentication/#http-signature-authentication