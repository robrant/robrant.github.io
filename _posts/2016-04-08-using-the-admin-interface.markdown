---
layout: post
title: "Using the admin interface"
date: 2016-04-13 15:00
categories: django
author: "Mark Norman Francis"
---

<div class='image aside'>
  <img src='/images/admin.png'>
  The admin interface homepage.
</div>

As a lighthouse administrator, your starting point should be `/admin/` on the
lighthouse host. Logging in there will present a list of all of the types of
content (data models) that the application uses. Clicking on the name of each
type will take you to the list of all instances in the database. Clicking on
one of the items in the list will take you to a representation of that item's
database row.

For example, clicking on "Links" will take you to the list of all tools
currently registered with lighthouse (the tools are called 'links' in the
code, so the admin interface uses that name). Clicking on the link
"lighthouse" will take you to the lighthouse app's entry in lighthouse (this
is automatically created, but should be edited to show who really is the owner
to be contacted).

Each type of content can be edited or deleted, and new ones added from this
interface.

To find users and tools easier, use the search box rather than clicking
through multiple pages of links.

## Removing users

<div class='image'>
  <img src='/images/delete.png'>
  Deleting a user that owns tools.
</div>

If the user owns one or more tools, their ownership blocks you from deleting
them straight away. First, you should change each tool to be owned by someone
else. Click through to the tool, then change the owner in the drop-down, and
click `Save`.

## Removing other items

<div class='image'>
  <img src='/images/confirm.png'>
  Deleting a team that has users in.
</div>

There is a confirmation step when removing things such as tools where other
database objects are related to them (usage stats, etc.), but these items
will just be deleted in a cascade if you confirm the deletion.
