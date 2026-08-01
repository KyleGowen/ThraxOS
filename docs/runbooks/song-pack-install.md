# Song-pack installation runbook

1. Match recommendations to owner-confirmed taste, difficulty, style, and session goals.
2. Verify the source page and direct archive URL. Prefer established community indexes and original publisher links.
3. Report pack metadata and obtain approval before downloading until the owner grants broader authority.
4. Download into `staging/` or another owner-approved staging directory, not directly into `Songs`.
5. Record archive size and checksum; use Windows security scanning when available.
6. List archive entries and reject absolute paths, drive-qualified paths, `..` traversal, executables, scripts, or unexpected installers.
7. Extract into a unique staging directory. Verify the expected `pack/song/simfile+audio` layout and identify duplicate pack or song names.
8. Propose the exact destination under the approved song root and obtain installation approval.
9. Move or copy atomically without overwriting an existing pack.
10. Ask ITGMania to reload songs or restart only with approval, verify recognition, and record the installed pack and source.

Songs remain outside Git and outside both backup repositories.
