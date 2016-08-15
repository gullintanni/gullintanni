Gullintanni Cheatsheet
======================

Gullintanni will listen for commands sent via comments posted on open merge
requests. Gullintanni will only respond to commands made by authorized
reviewers on repositories that you have defined in your pipeline
configurations.

Commands
--------

All commands **must mention** the provider account associated with the
repository's pipeline configuration. For example, if you connect Gullintanni to
a GitHub repository via authorizing as the `@gulbot` user, your commands must
mention that user specifically.

| Command | Description |
| ------- | ----------- |
| `r+`    | Approve a merge request and add it to the build queue.\* |
| `r-`    | Cancel the approval of a merge request and remove it from the build queue. |

_**Notes**_

* _An approval will apply to the latest commit in the merge request branch at
  the time of the approval._

### Examples

```
@gulbot r+
```

```
@gulbot r-
```

Build States
------------

### Under Review

This is the default build state for all open merge requests in a repository. It
simply means that the merge request has yet to meet the required number of
approvals in order to be tested.

If the contents of a merge request branch changes upstream, it will
automatically be removed from the build queue and placed back in the "under
review" state.
