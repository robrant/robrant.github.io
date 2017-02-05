---
layout: post
title:  "A problem with NFS and Vagrant"
date:   2016-01-29 17:05
categories: vagrant
author: "Michael Allen"
---

In setting up our vagrant VM for developing on I encountered an odd issue that
was causing us problems running our example app. It has since been fixed, caused
by NFS and some bad settings vagrant picked up from the laptop it was running on.

Follows is a short report of what the problem presented, how we explored what it
might have been and how it was fixed. It follows the idea of a [Post-mortem].
In case something similar happens in the future and we don't remember or aren't
here to help, then this might prove helpful.

## The situation

We had a simple VM, Centos7, defined by our Vagrantfile with a folder on the
host machine (my laptop) being shared via NFS.

In the VM I had manually installed Python3.5 using the [ius repo] and used it
to create a Virtualenv, a tool for keeping python projects clean, and install
Django into that virtualenv.

In the shared folder was a simple Django app which connects to a local SQLite
database and renders a simple "hello world" message. It was created using
`django-admin startproject lighthouse` so everything was the basic defaults.

## The problem

The issue presented as the basic Django app hanging when we ran it, using the
`./manage.py runserver 0.0.0.0:8000` command. The app should have started and
output:

    > ./manage.py runserver 0.0.0.0:8080
    Performing system checks...

    System check identified no issues (0 silenced).

    You have unapplied migrations; your app may not work properly until they are applied.
    Run 'python manage.py migrate' to apply them.

    Django version 1.9.1, using settings 'lighthouse.settings'
    Starting development server at http://0.0.0.0:8080/
    Quit the server with CONTROL-C.

Instead we would see it hang just after system checks:

    > ./manage.py runserver 0.0.0.0:8080
    Performing system checks...

    System check identified no issues (0 silenced).

## Investigations

On seeing this hang we, Michael and Rob, started looking at the possible reasons
why it would hang and running experiments to see if we could prove those ideas
wrong. 

### Maybe the virtualenv is the problem

We deactivated the virtualenv using `deactivate`, installed Django into the
system Python3.5 using `sudo pip3.5 install django`, and ran the app again.

Again it hang just after the system checks.

### Maybe Python 3.5 is the problem

We destroyed the VM with `vagrant destroy -f` and brought it back up again with
`vagrant up`. We then used the system Python2.7 to install Django using 
`sudo pip install django` and ran the app again.

Again it hang just after the system checks.

### Maybe Django is the problem

We shared an example Flask app (also written in Python) into the VM using the
same NFS config as the Django app, installed it's dependencies in the system
Python3.5 using `sudo pip3.5 install -r requirements.txt` and ran it.

This time it bound correctly and served HTML to our web browser. This posed a
problem since we should be able to expect a Django sample app created by Djangos
base template to work, otherwise the Django developers would have noticed.

### Maybe it's the laptop

I run Linux on a Thinkpad T450s. Most people on the team are using Macbook Pros.
Perhaps it's my laptop that's the problem. So we pulled my working code for the
VM and the app onto Robs Macbook and ran the app.

It worked fine.

### Try creating a Django app in the Linux machine

In defence of my laptop and OS I decided to prove that Linux can run the app
without Vagrant in the way. Checking out the Django app, creating a virtualenv,
installing the requirements and running the app.

It worked fine. Vindication, some quirk of Vagrant or the VM is to blame.

### Maybe it's SELinux

The Centos7 VM we were using had SELinux enabled, perhaps that was causing
problems (as it usually does). So we tried a few experiements around disabling
SELinux, such as moving the app into the vagrant users home directory. The theory
was that SELinux can do weird things in the `/<foo>` directories but anything in
your own user should be runnable.

We moved the files to `/home/vagrant` using `mv /opt/lighthouse ~`
and ran the app. It worked fine.

### If it's SELinux, lets disable it

Since it looks like SELinux is at fault we decided to disable it and try running
the app from `/opt/ligthouse` again. If it was only SELinux then the location of
the app shouldn't matter.

We disabled SELinux by using an [Ansible galaxy role which disabled SELinux].
After a reboot of the VM we ran the app again. This time it still didn't run,
hanging after the system checks again.

### Is it NFS

After some head scratching I realised that moving the folder location from `/opt`
to `~` didn't move the NFS share locally, it actually moved the files out of the
shared folder from the Host machine into a local folder in the VM. Meaning those
files were no longer being shared by NFS.

To test this we shared the folder by NFS to `~/lighthouse` and then copied the
files into `~/lighthouse2`. Now we have two copies of the app, one shared, one
not. If both work then the NFS isn't the issue.

We ran both apps and found that the NFS shared one hanged. Success, we know the
problem.

## The Issue

Now we know the problem but we don't know why. To find out we compared the NFS
settings between a Macbook Pro and the Thinkpad T450s.

Using the command `cat /proc/mounts | grep nfs` outputs the NFS shares and
settings on the VM:

* On Ubuntu: ```10.10.15.1:/home/michael/dev/lighthouse /opt/lighthouse nfs rw,relatime,vers=3,rsize=32768,wsize=32768 ...```
* On OSX: ```10.10.15.1:/Users/michael/dev/lighthouse /opt/lighthouse nfs rw,relatime,vers=3,rsize=8192,wsize=8192 ...```

The difference was the `rsize` and `wsize` values, on Ubuntu they were `32768`
and OSX they were `8192`.

With a bit of googling we found articles in the NFS docs about [setting rsize and
wsize to optimise transfer speeds NFS][nfs-docs], which explained that rsize and wsize are
the size of blocks that will be read and written over the NFS connection. If
these are too high perhaps they are flooding the connection when Django tries to
connect to the SQLite database, which requires a long-life connection.

To test this idea we ran two final experiments:

1. Move only the SQLite database outside of the NFS share and run the app, resulting
in it running fine. This proves that it's the DB connection over NFS causing the
issue.

2. Explicity set the rsize and wsize to the OSX values of `8192` and run the app.
Resulting in the app running fine, proving that it's the large block size that
causes NFS to hang on long-life connections.

## The Fix

The fix to all this is to explicitly set the `rsize` and `wsize` in our
Vagrantfile:

    config.vm.synced_folder ~/Projects/lighthouse, /opt/lighthouse, type: 'nfs',
        mount_options: ['rsize=8192', 'wsize=8192']

This fix was commited in [Infrastructure commit #22b7244] and merged in
[Infrastructure pull request #3].

## Unexplained results

One thing that the fix results in is that the version of the NFS protocol used
has changed from v3 to v4. Why this happens we have no idea.

Also why did Vagrant decide to use a different `rsize` and `wsize` for Ubuntu
and OSX? Not a clue.

[ius repo]: https://ius.io/
[Post-mortem]: https://en.wikipedia.org/wiki/Postmortem_documentation
[Ansible galaxy role which disabled SELinux]: https://galaxy.ansible.com/flmmartins/disable-selinux/
[Infrastructure commit #22b7244]: https://github.com/livestax/dstl-infrastructure/commit/22b72446ff273f2363961b649fdcbfb0307c51b9
[Infrastructure pull request #3]: https://github.com/livestax/dstl-infrastructure/pull/3
[nfs-docs]: http://nfs.sourceforge.net/nfs-howto/ar01s05.html
