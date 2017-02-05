---
layout: post
title: "Pre-populating the categories list"
date: 2016-04-18 10:00
categories: django
author: "Dan Hough"
---

One way that tools within the Lighthouse system are organised is by applying a
list of "Categories" to each of them. If you're familiar with the concept of
"tags" which became popular with blogs in the 2000s, this is familiar territory:
they're easy to apply and are simply a word or collection of words separated by
commas, and each item can have as many categories as you like.

The user interface for adding categories used by the the general Lighthouse
user is straightforward. On the new or edit tool page, the tool can be applied
with existing categories using checkboxes, or new ones using a text input.

However, some of our user research uncovered a need for pre-existing categories
which are bound to be useful in a new instance of Lighthouse. For example, OSINT
analysts sometimes use free online tools in their jobs, whereas some paid-for
tools are sometimes better but should be used sparingly. So, they wanted a
way to filter tools based on this attribute. Someone suggested a "Free" filter
and a "Paid" filter for analysts to use from day one. The simplest way to
achieve this is to add some pre-existing categories through the Django admin
interface, which can then be used to filter tools either with or without a
search term.

Simply go to `/admin/` (e.g. for preview it's http://www.lighthouse.pw/admin/)
and enter the username and password of a Django superuser for your environment.

![](/files/2016-04-18-admin-categories.png)

When you see the admin UI, select "Tags" under "Taggit" and you'll be taken to a
page which normally lists existing categories. There probably won't be any.

![](/files/2016-04-18-admin-categories-list.png)

Click the "Add Tag" button at the top-right of the screen, which will take you
to the page `/admin/taggit/tag/`. Enter the name of your new category, with a
leading uppercase character, like, "Free" and it should automatically create the
slug, a URL-friendly version of your category. Click save, and you'll be done.
Repeat this process for as many as you like.

![](/files/2016-04-18-admin-categories-add.png)

The categories you created will now apepar in the Lighthouse new tool, edit tool
and tool list pages.

And there you go: you can now pre-populate the system with common tags.
Apart from saving time, this is a great way to encourage users to use certain
terminology and prevent duplication of categories.

### Why not build some categories into the system?

Lighthouse is meant to be deployed into different environments, for use by
different teams whose requirements will not always align. In the case of
categories, it would have been inappropriate to have "Free" and "Paid"
categories for most of the closed-source analysts' teams, so the obvious
solution would've been to create environment-specific migration scripts. These
are dangerous, because they introduce dependencies into the system which do
nothing in many cases, and could cause further conditional dependencies down the
line in development, essentially doubling the amount of work needed to develop
some migrations. It also creates a lot of uncertainty and ambiguity for anybody
reading the code. With that in mind, and since creating new categories is a
pretty trivial thing to do for anybody who has superuser access, it seemed like
a sensible thing not to add to the codebase.

### How do categories work internally?

Lighthouse uses a Django plugin called "Taggit" to manage these categories. It
creates two tables: a `Categories` table and a `Link_Categories` table, where the
latter is used to link together the Links (what tools are known as internally)
table and the `Categories` table. The Python interface provided by Taggit is
really simple, and takes comma-separated strings like "geo, mapping, social" to
indicate which categories should be created.
