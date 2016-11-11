Gullintanni
===========

A Git merge bot, written in [Elixir][], that ensures your master branch builds
cleanly.

[![Build Status]][@TravisCI]
[![Coverage Status]][@Coveralls]

[Elixir]: http://elixir-lang.org/
[Build Status]: https://travis-ci.org/gullintanni/gullintanni.svg?branch=master
[@TravisCI]: https://travis-ci.org/gullintanni/gullintanni
[Coverage Status]: https://coveralls.io/repos/github/gullintanni/gullintanni/badge.svg?branch=master
[@Coveralls]: https://coveralls.io/github/gullintanni/gullintanni?branch=master

Overview
--------

> _**The Not Rocket Science Rule Of Software Engineering**_  
> _Automatically maintain a repository of code that always passes all the tests._  
> -- Graydon Hoare ([summarizing Ben Elliston][not rocket science])

[not rocket science]: http://graydon.livejournal.com/186550.html
  'technicalities: "not rocket science" (the story of monotone and bors)'

Gullintanni is a means for satisfying the above rule, and acts as an
intermediary between your Git hosting provider and your Continuous Integration
workers.

### The Problem

When the build is broken on the master branch, _all_ developers are blocked
from safely basing their work on master until it has been fixed. This also
unnecessarily increases the communication burden between collaborators until
the issue is resolved. Testing unrelated code becomes unreliable, so merging
changes can become delayed across the board. As teams scale up in size, that
can mean a substantial loss of time and productivity.

Even with comprehensive test suites, most Git workflows don't do enough to
prevent broken commits from getting merged. The classic example would be two
open merge requests:

1. a merge request that renames a function and all of its invocations
2. a merge request that uses the original function name

When tested against the master branch individually, they can both pass the test
suite; but as soon as they're both merged, the function call in the second
merge request will be broken.

The "protected branch" feature of GitHub can solve the above problem by forcing
all merge requests to be up-to-date with the master branch (and pass all tests)
before merging. But, there are some downsides:

* It becomes a laborious process to merge in updates from the master branch,
  especially if it's a highly-active project.
* Each time you merge in changes, you have to wait for the test suite to pass
  and hope that no additional changes were pushed to master in the mean time.
* Once you've got the green light to merge, it must be manually executed,
  despite being a trivial process.
* Not everyone wants to use GitHub, and the idea of a protected branch is not
  ubiquitous across Git hosting providers.

Luckily, those downsides can be addressed with a little bit of automation...

### The Solution

Gullintanni has a couple of key features:

1. it maintains a project-wide build queue to coordinate the testing and
   merging of multiple merge requests
2. it eliminates the need to ever manually merge branches (assuming there are
   no syntactic-level conflicts)

Once a proposed code change looks ready to merge, a user will post a comment
directing Gullintanni to approve the merge request and add it into the build
queue. For each approved merge request, the bot will create a _copy_ of the
master branch with the proposed code change on top of it, and then run the
tests. If the build passes, the master branch can be automatically
fast-forwarded to the state in the temporary branch, and then the next merge
request in the build queue will go through the same process.

The forced serialization of testing means that every merge request will be
tested against an up-to-date master branch, and that the master branch's tests
will always pass. Aside from the initial approval of a merge request, this
process can happen without a need for manual intervention.

### Caveats

The safety that Gullintanni provides is only as good as the test suite that you
run. While using a merge bot will prevent a lot of issues in your repository's
release branches, you can never fully prevent transient bugs from making their
way into the codebase.

One potential downside to Gullintanni's workflow is the serialization of
testing; if your test suite takes a long time to complete, say an hour, then
you're limited to merging in just 24 changes per a day. I don't expect that to
be a realistic concern for for most projects, but it _is_ worth mentioning. To
address this limiting factor, there are plans to safely parallelize builds in
the future through [automatic rollups][].

[automatic rollups]: https://github.com/gullintanni/gullintanni/issues/3

Usage
-----

### Command the Bot

Once Gullintanni is configured and the merge bot is running, it will listen for
commands sent via comments posted on open merge requests. Gullintanni will only
respond to commands made by authorized reviewers on repositories that you have
defined in your pipeline configurations.

Read the [cheatsheet][] document for a detailed breakdown of the supported
commands and how to interpret the build queue status.

[cheatsheet]: https://github.com/gullintanni/gullintanni/blob/master/pages/Cheatsheet.md

Contributing
------------

Gullintanni welcomes contributions from everyone. If you're thinking of helping
out, please read the [guidelines for contributing][contributing] to the project.

[contributing]: https://github.com/gullintanni/gullintanni/blob/master/CONTRIBUTING.md

Inspiration
-----------

* [bors][]: The original merge bot.
* [Homu][]: More efficient than bors by being stateful and responding to events
  vs polling; also introduced new ideas such as the `try` and `rollup`
  commands.
* [Highfive][]: Clever communication with new collaborators and automatic
  pairing of merge requests with potential reviewers.
* [Zuul][]: Best-of-breed parallel testing to reduce serialization of merges
  via their [Project Gating][] strategy.
* [Aelita][]: A rewrite of Homu in [Rust][], but still in its infancy.
* [Rultor][], [Git DMZ Flow][] ...and so on.

[bors]: https://github.com/graydon/bors
[Homu]: https://github.com/servo/homu
[Highfive]: https://github.com/servo/highfive
[Zuul]: https://github.com/openstack-infra/zuul
[Project Gating]: http://docs.openstack.org/infra/zuul/gating.html
[Aelita]: https://github.com/AelitaBot/aelita
[Rust]: https://www.rust-lang.org/
[Rultor]: https://github.com/yegor256/rultor
[Git DMZ Flow]: https://gist.github.com/djspiewak/9f2f91085607a4859a66

Gullintanni is unequivocally standing on the shoulders of giants. Those giants
all have their own idiosyncrasies that could be improved upon, as well as
individual strengths that are not commonly shared. Many of them are
tightly-coupled to a specific project's ecosystem, and lack flexibility in
external integrations. So, the origin of this project is not _entirely_ due to
an affliction of [NIH Syndrome][].

[NIH Syndrome]: https://en.wikipedia.org/wiki/Not_invented_here
  "Not Invented Here"

Professionally, I've had the responsibility of creating and maintaining
complicated CI infrastructure for a number of large projects. Over the course
of years, I have seen strange edge cases and failures which have helped me to
form strong opinions on how to develop projects safely and efficiently. On an
operational-level, I appreciate when tools are well documented, tested
thoroughly, and easy to run. I'm hoping my hard-won lessons are reflected by
Gullintanni.

License
-------

Gullintanni is provided under the terms of the
[ISC License](https://en.wikipedia.org/wiki/ISC_license).

Copyright &copy; 2016, [Aaron Bull Schaefer](mailto:aaron@elasticdog.com).
