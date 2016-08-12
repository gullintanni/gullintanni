Gullintanni
===========

A Git merge bot, written in [Elixir][], that ensures your master branch builds
cleanly.

[![Build Status](https://travis-ci.org/gullintanni/gullintanni.svg?branch=master)](https://travis-ci.org/gullintanni/gullintanni)

> Generated [ExDoc][] API Reference documentation can be found at
> <https://gullintanni.github.io/gullintanni/api-reference.html>

[Elixir]: http://elixir-lang.org/
[ExDoc]: https://github.com/elixir-lang/ex_doc

Overview
--------

> _**The Not Rocket Science Rule Of Software Engineering**_  
> _Automatically maintain a repository of code that always passes all the tests._  
> -- Graydon Hoare ([summarizing Ben Elliston])

[summarizing Ben Elliston]: http://graydon.livejournal.com/186550.html 'technicalities: "not rocket science" (the story of monotone and bors)'

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

Professionally, I've had the responsibility of creating and maintaining
complicated CI infrastructure for a number of large projects. Over the course
of years, I have seen strange edge cases and failures which have helped me to
form strong opinions on how to develop projects safely and efficiently. On an
operational-level, I appreciate when tools are well documented, tested
thoroughly, and easy to run. I'm hoping my hard-won lessons are reflected by
Gullintanni.

[NIH Syndrome]: https://en.wikipedia.org/wiki/Not_invented_here "Not Invented Here"

License
-------

Gullintanni is provided under the terms of the
[ISC License](https://en.wikipedia.org/wiki/ISC_license).

Copyright &copy; 2016, [Aaron Bull Schaefer](mailto:aaron@elasticdog.com).
