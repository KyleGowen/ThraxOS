# ITGMania configuration change runbook

1. Identify whether the active file is under the install root or roaming user root.
2. Confirm the target profile and exact desired behavior.
3. Ensure ITGMania is not running or writing the target file.
4. Confirm a recent healthy backup and establish a reversible local copy for the exact file.
5. Parse and record the current relevant keys; avoid unrelated normalization.
6. Apply the smallest change.
7. Parse the resulting file and compare only intended keys.
8. Launch and test only with approval when the change affects gameplay, audio, video, input, sync, or networking.
9. Update memory with the decision, target, validation, and rollback location. Never record secrets.

For an application upgrade, add release-note review, installer verification, content/config diff, and a resync plan. Never perform an unattended in-place upgrade before these gates pass.
