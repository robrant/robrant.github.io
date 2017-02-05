---
layout: post
title:  "Code reuse conclusion"
date:   2016-01-15 10:00
categories: questions
author: "Mark Norman Francis"
---

There was a question of continuing to use the existing lighthouse codebase, or
starting again from scratch. We created some criteria (see [deciding on code
reuse](/2016/01/deciding-on-code-reuse) for more detail) that represents what
we consider to be “good” and modern development practices. Using these we felt
we could dispassionately answer the question without it being just a gut
reaction (doubly important as most developers have a natural bent towards
starting from scratch).

The theoretical advantage to continuing with existing code is that a lot of
work is already done for you. But there is a knock-on effect in terms of a
slow ramp-up in speed as developers have to get to grips with existing code,
so there should be documentation and architectural explanation.

The theoretical advantage in starting afresh is that you have no legacy
problems to deal with and therefore the team will go faster as they will
understand the code better by having written it. But there is a knock-on
effect in possibly having a duplication of effort creating features that have
already been developed in the old code, meaning that perceived velocity will
be lower as initial “new” features are not actually new.


## Answers to questions

### Maintainability

The code as it stands is not particularly troublesome, but there is little in
the way of documentation and tests, meaning we would have to spend as much
time standing it up and running continuous integration as when starting from
scratch.

### Complexity

The code (taken in isolation of the setup and architecture) makes much sense
to us, but it is not easy to get started working on (lack of documentation)
and could be better laid out and more obvious.

### History and context

Not having the full history of the code further impedes our ability to
understand why the code is the way it is or how to approach developing it
further. The code itself is commented, but not necessarily in a helpful manner
and there is little external documentation.

### Coverage

The code doesn’t cover many of the features that have been discussed and
prioritised, and those it does would not be difficult to replicate.

### Architecture

There is little explanation of the expected architecture of the code, or the
decisions made that lead to the current design.

### Technology

The choice of language, frameworks and supporting technologies for the
existing code seems fine at this early point.

### Opening up the source

Whilst we could openly publish the existing code, as it stands it is not in
great shape to do so, whereas starting from scratch knowing it would be opened
would be better.

### Demonstration of agile

There is definitely some value in taking the code and showing how we could
transform it to be better, but there is also value in showing how we would
start a project.


## Conclusion

The negatives of continuing with the existing prototype code seem to us to
outweigh the positives of starting again from scratch by quite a margin. The
strongest concerns are the lack of documentation in and around the existing
code and the lack of history — these are all things best done during not
after-the-fact.

The positives of starting again in terms of demonstrating the value in all of
the artifacts **around** the code, not just in the code itself, plus in
showing how the team would approach starting from nothing definitely outweighs
the extra time spent recreating features already in the existing codebase.

Therefore we recommend starting from scratch.
