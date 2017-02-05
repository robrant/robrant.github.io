---
layout: post
title: "Replacing the user model"
date: 2016-04-05 10:00
categories: django
author: "Mark Norman Francis"
---

Early in the development of lighthouse, a new `User` model was created to
represent users, in order to support the need to sign in without passwords.
Although this worked as a way of prototyping a passwordless solution, it
wasn't written in such a way as to integrate properly with Django.

Django has very good support for [adding details to your users][add] and for
[replacing the built-in user model entirely][sub] but it is quite a bit of
work to use.

The existing user model did allow users to login via the views provided, so
to some extent it was "integrated", but as a lot of the code was implemented
to be [as lightweight as possible][poc] (minimum viable users!) it meant that
the code would not support the built-in [admin interface][admin], nor be easily
integrated with the LDAP support libraries without a lot more work.

At this point we had approximately equal work to reimplement the code as to
implement the missing parts of the code. As the design and flow of the login
to lighthouse has settled, we felt that it was a good time to implement it as
an integrated custom user model. This work can be seen in 
[pull request #168 on lighthouse][pr].

The downside of replacing the `User` model entirely was that the database of
all running instances of lighthouse would have to be reset, losing any links
and users already created. Fortunately, this was minimal data, so approval for
resetting the database was granted.


[add]:https://docs.djangoproject.com/en/1.9/topics/auth/customizing/#extending-the-existing-user-model
[sub]:https://docs.djangoproject.com/en/1.9/topics/auth/customizing/#substituting-a-custom-user-model
[poc]:https://github.com/dstl/lighthouse/commit/2b1baa4bad6127f42c3befcd3238d46e86ba149b
[admin]:https://docs.djangoproject.com/en/1.9/ref/contrib/admin/
[pr]:https://github.com/dstl/lighthouse/pull/168
