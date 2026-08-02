# Add a song-library integrity and hygiene report

Status: proposed by owner on 2026-08-01.

Difficulty: 2/5. Expected impact: 5/5.

## Goal

Create a read-only report for the canonical and roaming song roots that detects exact and probable duplicate packs or songs, missing referenced assets, malformed simfiles, unsafe or unexpected file types, stale cache entries, and inconsistent `Pack.ini` metadata. The report should distinguish a harmless title collision from identical content and must never delete, move, rename, rewrite, or quarantine anything without a separate approved action.

## Preliminary research

- A StepMania/ITGMania user reported that the song-wheel delete command removed a song only for the current session and that it returned later. This is firsthand evidence of confusing library lifecycle behavior, not proof of the exact underlying cause: <https://www.reddit.com/r/Stepmania/comments/1gq4ee3/>.
- The SMRequests tooling documents that StepMania does not automatically remove associated cache records after songs or packs are deleted and recommends rebuilding behavior when its catalog scraper is used: <https://github-wiki-see.page/m/MrTwinkles47/Stepmania-Stream-Tools-MrTwinkles/wiki/Scripts-Usage>.
- Thraximundar already has a known duplicate of `80s Greatest Hits Volume 1` across its canonical and roaming song roots. It is cataloged separately and remains protected from deletion.

The community evidence supports a conservative inventory and cache-drift detector. It does not justify an automatic cleanup utility.

## Proposed first version

1. Inventory both song roots and identify pack, song, simfile, audio, image, video, and metadata relationships.
2. Hash only where needed: first use normalized paths, names, sizes, and simfile metadata to narrow candidates, then hash finalists.
3. Parse `#MUSIC`, artwork references, chart metadata, and `Pack.ini` without modifying cache or song data.
4. Report exact duplicates, probable duplicates, broken references, orphaned assets, unexpected executable or script payloads, and cache-only entries separately.
5. Export a dated Markdown or JSON artifact small enough for review; do not store a bulky full-library manifest in repository memory.

## Safety and acceptance criteria

- Default operation is read-only and safe while ITGMania is running, unless testing proves particular files are not stable to inspect during writes.
- No title-only collision may be labeled a duplicate without corroborating metadata or content hashes.
- Cache is rebuildable; songs, profiles, and scores are not. Any future repair must be separately proposed with an exact rollback path.
- Validate against the known 80s duplicate, deliberately distinct same-title songs, missing optional artwork, and a synthetic malformed pack before trusting results.

## Open questions

- Which absent assets are errors versus valid optional omissions in `.sm` and `.ssc` files?
- Can ITGMania's active cache schema be parsed reliably across releases, or should the first version only compare song roots against cache filenames?
- Should Defender scanning remain part of pack installation only, or become an optional integrity-report phase?
