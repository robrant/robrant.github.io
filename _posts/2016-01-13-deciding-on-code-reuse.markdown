---
layout: post
title:  "Deciding whether to continue with the alpha code"
date:   2016-01-15 10:00
categories: questions
author: "Mark Norman Francis"
---

At the start of the project, we had some alpha prototype code. We had to make
a decision on whether to continue using the existing prototype code, or to
start again from scratch.

Theoretically, the advantage to continuing with existing code is that some
work is already done for you. But that work may actually hinder progress if
it turns out that early decisions were incorrect or that it is solving the 
wrong thing.

In the excellent book on software practices [The Mythical Man Month][mmm],
Fred Brooks says:

>   Where a new system concept or new technology is used, one has to build a
>   system to throw away, for even the best planning is not so omniscient as
>   to get it right the first time. Hence plan to throw one away; you will,
>   anyhow.

Although this statement is much more directed at classic [waterfall] projects
than those using [agile] practices, there is still wisdom here. When you are
first solving a problem, you don't necessarily understand what is needed in
order to design a good solution. This is why the UK Government's [Service
Design Manual] says:

>   Following demonstration of your alpha, you may choose to discard the code
>   and start fresh in the beta. If, however, your code is effective you may
>   continue to iterate against your prototype.

The real question is how do you know if the code is effective? This was doubly
hard in our case as we didn't build the alpha, so any evaluation wasn't based
on our experience. We didn't want to just give in to [Not Invented Here]
syndrome, but actually evaluate the software as objectively as possible.

Our solution was to come up with a set of signals for a good quality codebase,
and to evaluate the current code against these.

*   **Code quality** — Does the code give us confidence that we will be able to build upon it easily?
    *   **Maintainability**
        *   Does the code look easy to build upon?
        *   Is the setup well documented?
        *   Is it well tested?
        *   Is it integrated with CI/CD?
        *   Are new features easily shipped?
        *   Are any code dependencies troublesome?
    *   **Complexity**
        *   Does the code make sense?
        *   Is it easy to get started making changes?
        *   Is the code well laid out?
    *   **History and context**
        *   Is the commit history well crafted?
        *   Is the code well commented?
        *   Is there any documentation of the code outside of itself?
*   **Coverage**
    *   How much of the required solution is covered by existing code?
    *   How much extraneous code is there?
*   **Architecture**
    *   Is the code solving the problem in a good way?
    *   Is the design and architecture well documented?
*   **Technology**
    *   Is the choice of programming language(s) suitable for the team(s)?
    *   Is the choice of programming language framework(s) helping or
        hindering progress?
    *   Is the choice of supporting technologies (eg database, caching layer)
        helping or hindering progress?


[mmm]: https://en.wikipedia.org/wiki/The_Mythical_Man-Month
[waterfall]: https://en.wikipedia.org/wiki/Waterfall_model
[agile]: https://en.wikipedia.org/wiki/Agile_software_development
[Service Design Manual]: https://www.gov.uk/service-manual/phases/alpha.html
[Not Invented Here]: https://en.wikipedia.org/wiki/Not_invented_here#In_computing
