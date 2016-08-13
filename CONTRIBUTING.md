Contributing to Gullintanni
===========================

Gullintanni welcomes contributions from everyone. Here are the guidelines if
you're thinking of helping out.

Where to Start
--------------

Contributions to Gullintanni should be made in the form of GitHub [pull
requests][]. Each PR will be reviewed by a core contributor (someone with
permission to approve patches) and either merged, or given feedback for changes
that would be required. All merging is handled via [`@gulbot`][gulbot], our own
Gullintanni bot instance. _All contributions should follow this format, even
those from core contributors._

The project uses the GitHub [issue tracker][] to organize all known bugs,
feature requests, community questions, etc. Some issues are easier than others,
and we try to apply the [_**Effort: Low**_][effort-low] label to those issues.

If you'd like to work on an issue, please leave a comment so we can assign the
issue to you. This is to prevent duplicated efforts from contributors on the
same issue. We're glad to mentor contributors as well, so if you'd like some
guidance or clarification, just ask!

[pull requests]: https://help.github.com/articles/using-pull-requests/
[gulbot]: https://github.com/gulbot
[issue tracker]: https://github.com/gullintanni/gullintanni/issues
[effort-low]: https://github.com/gullintanni/gullintanni/labels/Effort%3A%20Low

Development
-----------

Gullintanni follows the ["Fork & Pull"][] model of development, so once you
have [installed Elixir][], you should fork this repository and then create
a local clone of your fork.

You can then download the application dependencies and run the tests via the
following commands:

    $ mix deps.get
    $ mix test

...add the `--trace` option to the test command to run with detailed reporting.

To explore the project in Elixir's interactive shell, run the following
command:

    $ iex -S mix

["Fork & Pull"]: https://help.github.com/articles/fork-a-repo/
[installed Elixir]: http://elixir-lang.org/install.html

### Documentation

Generated [ExDoc][] API reference documentation can be found at
<https://gullintanni.github.io/gullintanni/api-reference.html>

[ExDoc]: https://github.com/elixir-lang/ex_doc

Reporting Issues
----------------

Follow these steps for filing useful bug reports:

1. Figure out how to reproduce the bug.
2. Make sure your software is up-to-date to see whether the bug has already
   been fixed.
3. Check if the bug has already been reported in the [issue tracker][].
4. Finally, [open a new issue][] and provide detailed information regarding the bug and your
   environment.

Your report should minimally include:

  * the precise steps to reproduce the bug
  * the expected results and actual results
  * the versions of software you're running

If you have multiple issues, please file separate bug reports.

[open a new issue]: https://github.com/gullintanni/gullintanni/issues/new

### Issue Labels

Here is the full list of labels that Gullintanni uses and what they stand for:

> _**Effort: Low**_  
> An issue that should require a relatively low amount of effort to resolve.
> A great choice for a new contributor looking to get their feet wet!
>
> _**Effort: High**_  
> An issue that will take a decent amount of work, but is likely to have
> a bigger impact on the project.
- - -
> _**Priority: Low**_  
> An issue that would be nice to resolve at some point, but is not critical.
>
> _**Priority: High**_  
>  An issue that should be resolved as quickly as possible.
- - -
> _**Type: Bug**_  
> An issue describing unexpected or malicious behavior.
>
> _**Type: Enhancement**_  
> An issue containing a feature request or a suggestion for improvement.
>
> _**Type: Question**_  
> An issue that needs answering but does not require code changes.
- - -
> _**~ Duplicate**_  
> An issue that was closed because it was a duplicate of another
> previously-reported issue.
>
> _**~ Invalid**_  
> An issue that was closed because it could not be reproduced.
>
> _**~ Won't Fix**_  
> An issue that was closed because the proposed change was not in line with the
> goals of the project.

Conventions
-----------

### Git Workflow

Please **do not rewrite history** (rebase/amend/etc.) once you've filed a pull
request. At that point, the code on your branch should be considered public,
and rewriting history will inhibit collaboration. Read the [Branches section
of _Git DMZ Flow_][no-rebase] if you want a more detailed explanation.

[no-rebase]: https://gist.github.com/djspiewak/9f2f91085607a4859a66#branches

### Coding Style

Gullintanni tries to follow the current conventions use by the Elixir community
at large. Most style choices should be easy enough to pick up from looking at
the code, but there are a couple of good style guides out there that you can
use as a reference (each with slightly differing advice):

* <https://github.com/levionessa/elixir_style_guide>
* <https://github.com/rrrene/elixir-style-guide>

...that said, don't get too hung up on style. If there's a major style issue
with your code, we'll suggest some fixes to make before approving your pull
request. If there's a minor style issue, it's likely that we'll merge your code
as-is and someone might clean it up later.

We do include an [.editorconfig file][] in order to facilitate basic formating
consistency. See the [EditorConfig][] website for details and to check if your
preferred text editor is supported.

[.editorconfig file]: https://github.com/gullintanni/gullintanni/blob/master/.editorconfig
[EditorConfig]: http://editorconfig.org/
