---
layout: post
title: "Strategies for single sign-on"
date: 2016-04-25 14:00
categories: django future
author: "Mark Norman Francis"
---

Although some time was spent investigating single sign-on at the end of the
time digi2al worked on lighthouse, the feature was never completed. This is
a summary of what we learned and what might come next.


## nginx proxying

The outcome would look like:

* user requests an application URL
* the reverse proxy nginx serving lighthouse sees they are not yet
  authenticated and redirects them to an auth server
* user logs in to the central server
* server redirects them back to lighthouse
* nginx proxies the request to the application including the auth details
* user is logged into the application (if applicable) automatically
* nginx sends lighthouse tracking data for the user/application

As an approach, this is most desirable because lighthouse
(and all other web applications deployed by dstl) would need minimal to no
modifications to support having users and tracking usage through the 
lighthouse API.

There is [a branch on GitHub][pr] that will log a user in automatically
based upon the environment variable `REMOTE_USER` which could be easily 
adapted to support request headers from an nginx reverse proxy.

A couple of approaches found via some light googling:

* YouTube talk from nginxconf <https://www.youtube.com/watch?v=bjk8vTtp0as>
* <http://chairnerd.seatgeek.com/oauth-support-for-nginx-with-lua/>
* <https://developers.shopware.com/blog/2015/03/02/sso-with-nginx-authrequest-module/>
* <https://www.stavros.io/posts/writing-an-nginx-authentication-module-in-lua/>
* <https://github.com/Kloadut/SSOwat>
* <https://github.com/maanas/sso>

[pr]: https://github.com/dstl/lighthouse/pull/199


## authorising within django

A few attempts were made to integrate the lighthouse application with a test
[keycloak] server. We had two problems implementing this:

1.  Most python/django modules that implement OAuth and/or SAML for SSO
    authentication are, or rely on modules that are, written and tested for
    python 2, and lighthouse is deployed using python 3.

    It wouldn't be an impossible task to refit the app for python 2, but it
    isn't a quick, trivial, change.

1.  Keycloak's documentation is very light (read: basically missing) on how to
    use it programmatically; most of the talks, posts and documentation assume
    being able to drop in their Java modules or throwing some JavaScript into
    a web page.

If this was the approach taken by dstl, it would be worth first building an
empty django app using python 2, and integrating that before trying to amend
lighthouse (like our [LDAP integration test][ldap]).

This would serve both to prove the concept works (and have less chance of
possible implementation conflicts with lighthouse code) and as a guide to
other developers on how to add keycloak auth to their app.

[keycloak]: http://keycloak.jboss.org
[ldap]: https://github.com/dstl/active-directory-django-test

Some modules that may (or may not) be useful:

* <https://github.com/knaperek/djangosaml2>
* <https://github.com/onelogin/python-saml> and 
  <https://developers.onelogin.com/saml/python>
* <https://github.com/fangli/django-saml2-auth>
* <https://github.com/evonove/django-oauth-toolkit>
* <https://launchpad.net/django-openid-auth>
* <https://github.com/omab/python-social-auth>
* <https://django-oauth-toolkit.readthedocs.org/>
