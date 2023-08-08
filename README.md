# gitlog-to-csv Action

Creates a CSV file of some `git log` data, useful for exporting to audit reports and other "chain of custody" type reports.  It can optionally create diffs to show line-by-line and file-by-file what changed at each commit and by whom, as well as if each commit was signed with a GPG certificate.

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/some-natalie/gitlog-to-csv/badge)](https://securityscorecards.dev/viewer/?uri=github.com/some-natalie/gitlog-to-csv)

## Inputs and Outputs

Inputs

- Repository name (defaults to the current repository)
- Branch name (defaults to "main")
- Whether the GPG commit signing info should be included (defaults to "false")
- GitHub PAT token to use (defaults to the included `github.token`, only needed if the repository name isn't the current one)
- Whether to also generate diff files for each commit and include them in the zip archive (defaults to "false")

It'll output a CSV file, zipped and uploaded as an artifact on that workflow run.  If the diff file option is also set to true, it'll include all of those diffs in the zip file as well.  Artifact storage has a limited timeframe, so you may need to download it and move it into another business system (either automatically or manually) depending on your needs.  Here's what it'll return:

| Header | Description |
| --- | --- |
| url | URL within GitHub to view the detailed diff of this commit |
| commit id | Short SHA of the commit |
| author | Commit author |
| commit signature status | GPG commit signature status ([docs](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)) |
| name of signer | Name on the GPG key |
| key used to sign | GPG key used to sign |
| date | Date on the commit |
| comment | Comment (short, not full) on the commit |
| changed files | Number of files changed in this commit |
| lines added | Number of lines added in this commit |
| lines deleted | Number of lines deleted in this commit |

## Usage

Create a new workflow (or add it to an existing workflow) in `~/.github/workflows` and add the following to a step:

```yml
steps:
  - name: Upload a CSV code audit log to this workflow
    uses: some-natalie/gitlog-to-csv@v1
```

There's also an [example](.github/workflows/release.yml) using this Action in this repo.

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

:information_source:  The runner that you use to execute this Action might need to be set up with your key management server.  This may mean you'll need to chat with your key management / identity management folks to get things set up on a private key server.

## GitHub Enterprise version compatibility

Naturally, this works without any hitch on GitHub.com.  As a composite Action that calls other Actions, you'll need to be on at least GitHub Enterprise Server or GitHub AE version 3.3 to use this if you're not in GitHub.com.

:information_source:  This references the tag `v3` of [`actions/checkout`](https://github.com/actions/checkout) and [`actions/upload-artifact`](https://github.com/actions/upload-artifact), which is (currently) beyond the version shipped bundled in GHES and GHAE.  Your enterprise administrator might need to [update](https://docs.github.com/en/enterprise-server@latest/admin/github-actions/managing-access-to-actions-from-githubcom/using-the-latest-version-of-the-official-bundled-actions) the bundled actions.  Alternatively, you can copy this repository to your GHES or GHAE instance and downgrade the versions of these dependencies in that process.

## Using it without GitHub Actions

:question:  Not using or can't use GitHub Actions?  Not a problem - the core logic of this report is a plain [bash script](https://github.com/some-natalie/gitlog-to-csv/blob/main/action.yml#L40-L81) that you can plug into your CI system of choice or run _ad hoc_.  To run on an arbitrary machine, you'll need the following:

- BASH, of course
- GNU `awk` and `sed`
- Git
- GPG set up and appropriate certificates installed _if_ you want to verify commit signing - sorry this one is kinda vague, but what this looks like will vary widely based on your company's configuration.

## But why, though?

Yes, all of this information is available in `git` because this information is the very _nature_ of version control - but sometimes we all need a checklist or report to give to someone who doesn't want to hang out in a version control system.  The goal here is to make everyone's life just a tiny bit easier, one `sed` command at a time. :heart:
