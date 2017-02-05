---
layout: post
title: "Creating an admin user"
date: 2016-04-20 15:00
categories: django
author: "Dan Hough"
---

Did you read the ["Using the admin interface"](/2016/04/using-the-admin-interface/)
post and think, "that's great, but how do I log into the admin interface"? If
so read on: this journal entry is for you.

**Step one:** `ssh` onto the server you're serving Lighthouse from.

**Step two:** `cd` into the main Lighthouse project directory

**Step three:** activate the virtual environment using `source
./bin/virtualenv.sh`

**Step four:** Use Django Management to create a "superuser" like so:

```
python manage.py createsuperuser
```

You will be asked for a username and password, and then for the same password
again. Make sure you choose something memorable yet secure.

Once this has been completed, you will have the information needed to log into
the admin interface at `/admin/` and follow [the guide to using the admin
interface](/2016/04/using-the-admin-interface/) and [prepopulating categories](/2016/04/prepopulating-categories/).
