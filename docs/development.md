# Development harness
Start every task with AGENTS.md and scripts/context.ps1 -Task <feature>.
Required specs, task-to-file mapping and edge cases live in docs/specs/.
Run scripts/verify.ps1 for architecture guards, formatting, analysis and tests.
Use -UseJitAnalyzer in this sandbox if the standard analyzer aborts.
Use -Build to include a Windows Release build.
Record actual evidence and outstanding manual checks in docs/validation.md.

Generated work/, build/ and dist/ are not authoritative source. Do not read scratch backups to infer current behavior.
