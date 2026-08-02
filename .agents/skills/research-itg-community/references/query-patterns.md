# Query patterns

Build a small query matrix instead of relying on one long query. Substitute only relevant terms.

## Core terms

- Exact: `"<error or phrase>"`, `"<pack name>"`, `"<chart title>"`, `"<product model>"`
- Entity plus issue: `<entity> <symptom or claim>`
- Version: `<entity> <version or generation> <claim>`
- Author: `"<handle>" <pack or topic>`
- Time: `<entity> before:<year>`, `<entity> after:<year>`, or explicit year terms where supported
- Artifact: `<entity> manual`, `release notes`, `firmware`, `repository`, `photo`, `video`, `measurement`, `review`
- Counterevidence: `<entity> problem`, `failure`, `incorrect`, `doesn't work`, `regression`, `warning`, `avoid`

## Domain searches

Use `site:<domain>` with the exact entity first, then remove quotes and add aliases. Useful categories include:

- Reddit communities and individual posts;
- rhythm-game forums and pack indexes;
- official manufacturer, project, and tournament sites;
- GitHub repositories, issues, discussions, releases, and commit history;
- personal blogs, chart-author pages, video descriptions, and public web archives.

Do not assume a current community name existed historically. Search predecessor names, moved domains, old software names, and common abbreviations.

## Alias expansion

Generate only plausible variants:

- ITG / In The Groove / ITGmania / ITGMania;
- SM / StepMania / Simply Love / project or theme version;
- SMX / StepManiaX / platform / stage / generation number;
- song, chart, simfile, file, pack, mix, compilation;
- stepartist, charter, author, pack maintainer, organizer;
- usernames with and without punctuation, spacing, or legacy handles.

## Historical recovery

When a page is missing:

1. Search its exact title, distinctive sentence, filename, or old URL.
2. Search other pages linking to it.
3. Look for official mirrors, repository history, quoted excerpts, and public web-archive captures.
4. Identify whether a recovered copy is complete and when it was captured.
5. Cite the archive and, when useful, the dead original URL; do not describe the archived copy as live.

## Pack and simfile source discovery

Separate discovery from validation with a small query set:

- Catalog record: `"<pack or song>" itgpacks OR ITGDb OR StepManiaOnline OR Zenius`
- Release trail: `"<pack or song>" release author simfile download`
- Reddit: `site:reddit.com/r/Stepmania "<pack or song>" pad`
- Forums: `site:zenius-i-vanisher.com/v5.2/thread "<pack or song>"` and `site:stepmania.com/forums/song-packs "<pack>"`
- Competitive use: `site:groovestats.com "<pack or song>"` and `ITL OR ECFA OR Stamina RPG`
- Counterevidence: `"<pack>" sync OR broken OR crash OR keyboard OR incompatible OR reupload`

For a source-recommendation question, test current activity separately from content quality. A frequently updated catalog can still mix pad and keyboard content; a well-curated guide can be too static to serve as a release feed.

Treat gameplay videos and playlists as previews. Use them to inspect music and visible chart patterns, then trace the exact chart revision to a publisher page or catalog before recommending a download.

## Search log

For difficult or negative-result research, retain a compact list of:

- major query families;
- domains or communities checked;
- date range and versions considered;
- inaccessible or deleted sources;
- unresolved aliases or terminology.

Do not burden the final answer with every query unless the user asks; summarize coverage and meaningful gaps.
