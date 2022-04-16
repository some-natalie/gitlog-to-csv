# gitlog-to-csv

Creates a CSV file of some `git log` data, useful for exporting to audit reports and other "chain of custody" type reports.

## Inputs and Outputs

Input the repository and branch name you want the history of.  It'll default to the current repository and the "main" branch if not set.

It'll output a CSV file, zipped and uploaded as an artifact on that workflow run.  Artifact storage has a limited timeframe, so you may need to download it and move it into another business system (either automatically or manually) depending on your needs.

## Usage

Create a new workflow (or add it to an existing workflow) in `~/.github/workflows` and add the following to a step:

```yml
steps:
  - name: Upload a CSV code audit log to this workflow
    uses: some-natalie/gitlog-to-csv@v1
```

## An important note on GPG commit signing

Per the [git documentation](https://git-scm.com/docs/git-log#_pretty_formats), the "status codes" in the "commit signature status" field is included below.

| Code | Meaning |
| --- | --- |
| G | Good (valid) signature |
| B | Bad signature |
| U | Good signature with unknown validity |
| X | Good signature that has expired |
| Y | Good signature made by an expired key |
| R | Good signature made by a revoked key |
| E | Signature cannot be checked (e.g. missing key) |
| N | No signature |

:information_source:  The runner that you use to execute this Action will need to be set up with your key management server.  This may mean you'll need to chat with your key management / identity management folks to get things set up on a private key server.

## GitHub Enterprise version compatibility

Naturally, this works without any hitch on GitHub.com.  As a composite Action that calls other Actions, you'll need to be on at least GitHub Enterprise Server or GitHub AE version 3.3 to use this if you're not in GitHub.com.
