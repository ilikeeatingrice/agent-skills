# agent-skills

My working set of agent skills, vendored and patched. Installs as `.claude/skills/`
and `.codex/skills/` twins into a target repo, or at user level.

These are **modified copies**, not pristine upstream. The patches are listed below —
read them before assuming a skill behaves the way its upstream docs say.

## Install

```sh
./install.sh                     # user level: ~/.claude/skills + ~/.codex/skills
./install.sh /path/to/repo       # project level: <repo>/.claude/skills + .codex/skills
./install.sh . tdd brainstorming # only the named skills
```

Twins are written byte-identical. Re-running overwrites in place.

## The set

**Orchestration and process** — `brainstorming` · `writing-plans` · `executing-plans` ·
`subagent-driven-development` · `dispatching-parallel-agents` · `using-git-worktrees` ·
`verification-before-completion`

**Debugging and review** — `systematic-debugging` · `receiving-code-review` ·
`doubt-driven-development`

**Engineering** — `tdd` · `frontend-ui-engineering` · `observability-and-instrumentation` ·
`deprecation-and-migration` · `codebase-design` · `domain-modeling` ·
`improve-codebase-architecture`

**Working with the agent** — `research` · `handoff` · `writing-for-agents` · `grilling`

Pairs with [overseer-skill](https://github.com/ilikeeatingrice/overseer-skill), which
supplies the dispatch routing these assume.

## Attribution

All three upstreams are MIT licensed. Their license texts are preserved in
[`LICENSES/`](LICENSES/).

| Skills | Upstream | Author |
|---|---|---|
| `brainstorming`, `writing-plans`, `executing-plans`, `verification-before-completion`, `systematic-debugging`, `receiving-code-review`, `subagent-driven-development`, `dispatching-parallel-agents`, `using-git-worktrees` | [obra/superpowers](https://github.com/obra/superpowers) | Jesse Vincent |
| `frontend-ui-engineering`, `deprecation-and-migration`, `observability-and-instrumentation`, `doubt-driven-development` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | Addy Osmani |
| `tdd`, `research`, `handoff`, `writing-for-agents`, `codebase-design`, `domain-modeling`, `grilling`, `improve-codebase-architecture` | [mattpocock/skills](https://github.com/mattpocock/skills) | Matt Pocock |

## Patches applied

Vendoring changes how skills resolve each other, and some upstream steps assume a
workflow I don't use. What I changed and why:

- **`superpowers:` prefixes stripped throughout.** Vendored skills resolve by bare
  directory name; a prefixed reference resolves to nothing. Restore the prefixes if you
  install superpowers as a plugin instead.
- **`executing-plans` step 3** no longer calls `finishing-a-development-branch`. It runs
  the target repo's own pre-PR checklist and gates, and requires
  `verification-before-completion` before any pass claim. The upstream step fights a
  repo that already has a pre-push gate.
- **`subagent-driven-development`** — its five `finishing-a-development-branch`
  references repointed the same way. The reviewer prompt it depends on
  (`requesting-code-review/code-reviewer.md`) is vendored into the skill directory, so
  the skill stands alone.
- **`systematic-debugging`** points at `tdd` (Matt's) rather than the superpowers TDD
  skill, since only one TDD skill is installed.
- **`brainstorming`** ships without its `scripts/` visual-companion server (~25KB of
  Node). Visual questions route to a browser-automation skill instead.
- **addyosmani reference checklists** (`accessibility-checklist.md`,
  `observability-checklist.md`, `orchestration-patterns.md`) are inlined into each
  skill's own `references/`. A per-skill upstream install drops the repo-level
  `references/` directory, leaving those links dangling
  ([addyosmani/agent-skills#361](https://github.com/addyosmani/agent-skills/issues/361)).

## Notes

- **Not installed on purpose:** `using-superpowers` and `using-agent-skills` — the
  bootstrap meta-skills that make their frameworks all-or-nothing. Omitting them is what
  makes this a set rather than a framework.
- Skills whose upstream duplicates something the harness already provides
  (`code-review-and-quality`, `code-simplification`, `requesting-code-review`,
  `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`) are
  deliberately absent — repo-specific gates beat generic advice.
- `handoff` sets `disable-model-invocation: true`, so it is manual-only (`/handoff`) and
  will not appear in auto-discovery listings.
