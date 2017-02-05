---
layout: post
title:  "How to make a Lighthouse Project Journal"
date:   2016-01-29 16:15
categories: jekyll
author: "Daniel Hough"
---

Welcome to the Lighthouse Project Journal. I set it up because Norm had the idea
to find a place where we could–as a team–capture the decisions we make and why
we make them, the milestones we reach, and the things we learn. The audience
consists of our future selves, but also all of the other immediate project
stakeholders and future developers of the Lighthouse application.

Since I have half an hour to kill on a Friday evening, I'll spend a little
time documenting how I put this blog up onto the web.

## Jekyll

What is Jekyll? It's a static site generator, which means that it takes a bunch
of source files (normally formatted as [markdown]), then it takes a load of
lovely HTML layouts with template placeholders in them, and the two of them are
weaved together into a new website, whose beauty is greater than the sum of its
parts.

I already had Jekyll installed because I generate my own website using it. To
create a new site I simply entered

    $ jekyll new dstl-lighthouse-project-journal

It generated my source files. So far, I've barely lifted a finger.In the
meantime, Roo went onto GitHub to make a private repo for us to store the blog
source in and then headed to Heroku to set up an instance for us to deploy to.
Thanks Roo!

## Heroku

Heroku is great for getting simple apps up and running quickly. Web apps don't
come much more simple than a flat, static website like the one Jekyll generates,
so we could've put it anywhere. The benefit of Heroku is that it'll happily deal
with running scripts before and after various parts of the checkout and deploy
process.

To get Heroku to serve our site, we need to create a [Rack] server, but there's
a little more to it than that, which is what I learned from [this blog post by Andy Croll].
He wrote something called a _Build Pack_ to instruct Heroku how to build and
serve up a Jekyll site.

Since Roo had already set up the Heroku instance, though, I couldn't follow
Andy's advice to simply create it at the same time as specifying the `--buildpack`
option on the command line. Instead I needed to apply a build pack to an existing
Heroku app.

    heroku buildpacks:set https://github.com/andycroll/heroku-buildpack-jekyll.git --app lighthouse-project-journal

One of the few instruction code of Andy's that I did follow to the letter was
creation of the `config.ru` file, which looked like

    require 'rack/jekyll'

    run Rack::Jekyll.new


Roo also set up Heroku to deploy whenever the private git repo on
GitHub gets any commits to the `master` branch, so that's a nice time-saving
bonus for us.

## Locking it down

In the world of HTTP, one of the most basic ways to secure a website
is (creatively named) "Basic authentication". Basically [sic], you specify a
username in plain text and a password in plain text. It's only as secure as your
server, or wherever else this information is secured. Since we're using a
private GitHub repository and a Heroku instance (whose server-side code is not
served up), we decided that this was sufficient for our purposes.

With Rack, the tool we're using to serve this thing up, it's quite easy to
specify a username and password. I excitedly opened up our old friend `config.ru`
and typed up the incantations. Soon, config.ru looked like this:

    require 'rack/jekyll'

    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      [username, password] == ['keeper', 'lighthouses are great']
    end

    run Rack::Jekyll.new

Water-tight!

Once that was done, I navigated to http://lighthouse-project-journal.herokuapp.com/
to check my work. Lo and behold, it was a success. Then, since I had half an hour
to kill before the end of the week, it seemed only right to break the seal on this
blog and write the first post.

Thanks for reading.

–Dan Hough, Developer

## Quote of the week

> We're moving at the pace of the web
– Roo Reynolds

[markdown]:https://daringfireball.net/projects/markdown/
[Rack]:http://rack.github.io/
[this blog post by Andy Croll]:http://andycroll.com/ruby/serving-a-jekyll-blog-using-heroku/