Gullintanni Cheatsheet
======================

Once Gullintanni is configured and the merge bot is running, it will listen for
commands sent via comments posted on open merge requests. Gullintanni will only
respond to commands made by authorized reviewers on repositories that you have
defined in your pipeline configurations.

_**NOTE:** If the contents of a merge request branch changes upstream, it will
automatically be removed from the build queue and placed back in the "under
review" state._

Commands
--------

All commands **must mention** the provider account associated with the
repository's pipeline configuration. For example, if you connect Gullintanni to
GitHub via authorizing as the `@gulbot` user, your commands must mention that
user specifically.

### `r+`

> Approve a merge request and add it to the build queue.  
> The approval will apply to the latest commit in the merge request at the time
> of the approval.

### `r-`

> Cancel the approval of a merge request and remove it from the build queue.

### Examples

```
@gulbot r+
```

```
@gulbot r-
```