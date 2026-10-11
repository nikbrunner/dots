# Audit checklist

Each rule is a target state; classify every rule in a topic's block with `path:line` evidence.

## typescript

- [ ] No `any` appears in any form: parameters, return types, generics, or assertions; `unknown` appears only as a last resort. (typescript.md#type-safety)
- [ ] No `as` assertion silences the compiler; `as const` and `satisfies` are fine. (typescript.md#anti-patterns)
- [ ] No variable is initialized to `null` or `undefined` and assigned its real value later. (typescript.md#type-safety)
- [ ] Union types over a fixed set of values derive from an `as const` source (`(typeof keys)[number]`) instead of repeating the values. (typescript.md#type-derivation)
- [ ] Lookup objects keyed by a union use `Record<Union, ...>` or `as const satisfies Record<Union, ...>`, so a changed union breaks the build. (typescript.md#type-derivation)
- [ ] Where a Zod schema exists, its type is `z.infer<typeof schema>`, with no parallel hand-written type. (typescript.md#type-derivation)
- [ ] Object contracts use `interface`; unions and computed types use `type`. (typescript.md#type-derivation)
- [ ] Functions take at most 2 positional parameters; 3 or more go into one destructured object argument. (typescript.md#function-design)
- [ ] Named functions, including helpers inside components, are `function` declarations, not const arrows; arrows appear only as inline callbacks passed as props or arguments. (typescript.md#function-design)
- [ ] Logic uses functions and object literals, with creator functions (`createUser`) instead of classes and constructors. (typescript.md#code-style)
- [ ] No commented-out code remains. (typescript.md#code-style)

## react

- [ ] Styles are imported only by Dumb Components and Layout Components; Partials have no style file. (react.md#core-principles)
- [ ] Containers and route components carry no styling beyond small layout utility classes. (react.md#core-principles)
- [ ] Dumb Components receive data and callbacks as props and never call `useQuery`, fetch, or read a store. (react/component-patterns.md#anti-patterns)
- [ ] When the project has i18n, components receive localized text as props instead of hardcoding strings. (react.md#core-principles)
- [ ] Each role's root element carries its attribute: `data-component`, `data-partial`, `data-layout`, or `data-container`. (react/component-patterns.md#data-attributes)
- [ ] In route-based apps the route component is the container, with no `*Container` wrapper in between; standalone containers are named `*Container`. (react.md#routes-as-containers)
- [ ] Containers delegate non-rendering logic beyond about 10 lines to a hook named after its domain topic (`useUserProfile`). (react/hooks-as-logic-layer.md#when-to-extract-a-hook)
- [ ] No props are forwarded unused through 3 or more levels. (react/component-patterns.md#broad-vs-deep-split)
- [ ] `src/` follows technical separation: `components/`, `containers/`, `partials/`, `hooks/`, `api/`, `lib/`, `types/`. (react/folder-structure.md#default-technical-separation)
- [ ] `hooks/` holds UI utilities and shared event hooks only, with no TanStack Query and no server state. (react/folder-structure.md#hooks-vs-api)
- [ ] Component folders and files are kebab-case and named after the component (`button/button.tsx`, `button.module.css`, `button.stories.tsx`), with an `index.ts` that only re-exports the named component. (react/folder-structure.md#naming-conventions)
- [ ] Directory name casing is consistent across the project. (react/folder-structure.md#naming-conventions)
- [ ] A hook used by one component sits in that component's folder; no non-route files sit in route directories. (react/folder-structure.md#co-located-hooks)
- [ ] Every `useEffect` passes a named function expression, and its cleanup is a named function for the inverse action. (react/hooks-as-logic-layer.md#named-effects)
- [ ] No `useEffect` matches one of the 13 cataloged anti-patterns; the listed legitimate uses are not findings. (react/no-use-effect-patterns.md)

## css

- [ ] Each component's style file sits next to it with the same base name (`button.module.css` beside `button.tsx`). (css.md#co-located-file-convention)
- [ ] Components with more than trivial styling use CSS Modules; global CSS holds only resets, font imports, and custom property definitions. (css/css-modules.md#when-to-use)
- [ ] The project uses one style file naming scheme throughout, either `.module.css` or `.css` configured as modules. (css/css-modules.md#file-naming)
- [ ] No runtime CSS-in-JS library is a dependency. (css.md#principles)
- [ ] Styles belong to components, not containers. (css.md#principles)
- [ ] Components with defined variants declare them with `cva()` and type their props with `VariantProps`. (css/utility-patterns.md#cva--class-variance-authority)
- [ ] Class merging uses `cx()` from `class-variance-authority`, with no separate `clsx` or `classnames` dependency. (css/utility-patterns.md#cx--class-merging)

## state

- [ ] Shareable view state (filters, pagination, sort, active tab) lives in router search params, not in `useState` or a store. (state.md#decision-flow)
- [ ] When TanStack Router is used, routes that read search params validate them with `validateSearch` and a schema. (state/url-state-patterns.md#simple-case-filters--pagination)
- [ ] Data from an API lives in TanStack Query and is never copied into a client store or `useState`. (state/state-separation.md#server-state-vs-client-state)
- [ ] A client store, when present, holds only state shared across unrelated components, with no server data and no URL-shareable state. (state.md#the-categories)
- [ ] State scoped to a subtree that resets when the user leaves lives in a React Context provider, without manual reset logic. (state/state-separation.md#react-context-as-scoped-state)
- [ ] State used by a single component is `useState` in that component, not a store entry. (state.md#decision-flow)
- [ ] A search param read by several components is wrapped in one hook (`useCategory`) built on `useSearch({ strict: false })`. (state/url-state-patterns.md#encapsulating-in-a-hook)
- [ ] The URL carries no sensitive data and no high-frequency values. (state/url-state-patterns.md#when-not-to-use-this-pattern)

## tanstack

- [ ] Only the fetch wrapper calls `fetch`, one wrapper per backend, each owning base URL, auth headers, content type, and error normalization. (tanstack/query-fetch-wrapper.md)
- [ ] When TanStack Query is used, query code lives under `src/api/` grouped by topic, not under a `features/` folder. (tanstack/query-patterns.md#complexity-2-one-folder-per-topic)
- [ ] When TanStack Query is used, every query and mutation key starts with its topic string. (tanstack/query-patterns.md#automatic-invalidation-via-mutationcache)
- [ ] When TanStack Query is used, the `QueryClient` sets up a `MutationCache` `onSuccess` that invalidates by the mutation key's topic. (tanstack/query-patterns.md#automatic-invalidation-via-mutationcache)
- [ ] Custom query hooks return `{ query, ...derived }` and never spread or rest-destructure the query result. (tanstack/query-patterns.md#render-optimization-dont-spread-do-memoize)
- [ ] Arrays and objects derived from `query.data` inside hooks are wrapped in `useMemo`. (tanstack/query-patterns.md#render-optimization-dont-spread-do-memoize)
- [ ] Query hooks that accept options type them as `Omit<..., "queryKey" | "queryFn">` and pass them through. (tanstack.md#key-patterns)
- [ ] When route loaders prefetch, `queryOptions`/`mutationOptions` factories live in per-entity files, hooks are thin wrappers around them, and loaders call `ensureQueryData(factory())`. (tanstack/query-patterns.md#entity-file-the-reusable-layer)
- [ ] Route components read loader-prefetched data with `useSuspenseQuery`. (react.md#routes-as-containers)
- [ ] Hooks that compose several queries live in the `api/` topic folder, or next to their single consumer, never in `hooks/`. (tanstack/query-patterns.md#orchestration--topic-hooks)
- [ ] When TanStack Form is used, every `useStore(form.store, ...)` passes a selector, and no `useField` is used for reactivity. (tanstack/form-patterns.md#anti-patterns)
- [ ] When TanStack Form is used, reset buttons are `type="button"` calling `form.reset()`, never `type="reset"`. (tanstack/form-patterns.md#reset-prevent-native-html-reset)
- [ ] When TanStack Form is used, field values live in form state only, with no mirrored controlled `useState`. (tanstack/form-patterns.md#anti-patterns)
- [ ] When TanStack Form is used with SSR, client and server share one `formOptions`, the server validates with `createServerValidate`, and the client merges back with `mergeForm` and `useTransform`. (tanstack/form-ssr-patterns.md)

## agent-tooling

- [ ] `AGENTS.md` exists at the repo root and is the canonical instruction file; any `CLAUDE.md` is only a symlink to it. (agent-tooling.md#layout)
- [ ] Project skills live in `.agents/skills/<name>/SKILL.md`, and each `name` matches its directory. (agent-tooling.md#layout)
- [ ] `.claude/skills` is a relative symlink to `../.agents/skills`. (agent-tooling.md#layout)
- [ ] Agent-specific config sits only in that agent's directory (`.claude/`, `.pi/`). (agent-tooling.md#layout)
- [ ] `AGENTS.md` stays around 50 lines and holds no line the decision test removes: dev commands, runtime versions, path aliases, lint or test setup, architecture already in `docs/`. (agent-tooling.md#agentsmd)
- [ ] Every instruction sits in its home: always-on context in `AGENTS.md`, task-specific workflow or knowledge in a skill, scriptable rules in a hook or extension. (agent-tooling.md#where-an-instruction-belongs)
- [ ] No two skills, or a skill and `AGENTS.md`, state the same thing. (agent-tooling.md#health)
- [ ] Skills and enforcement name only files, commands, and tools that exist in the repo. (agent-tooling.md#health)
- [ ] A skill only the human starts sets `disable-model-invocation: true`. (agent-tooling.md#where-an-instruction-belongs)
- [ ] Fast checks exist for the agent to run: a typecheck or lint command, and Git hooks on pre-commit and pre-push. (agent-tooling.md#feedback-loops)

## hooks

- [ ] One hook manager is active: Lefthook in a repo under the maintainer's control, otherwise the repo's established tool. (hooks.md#control)
- [ ] Hooks are installed: `git config --get core.hooksPath` or the Lefthook install points Git at the configured hooks. (hooks.md#installation)
- [ ] Pre-commit runs fast checks scoped to staged files, read-only unless an existing autofix hook was kept by agreement. (hooks.md#stages)
- [ ] Pre-push runs the CI-parity command. (hooks.md#stages)
- [ ] Hooks call existing scripts or tasks, and every command they name exists. (hooks.md#stages)
- [ ] A fresh clone installs the hooks through the project's setup, and the contributor instructions name it. (hooks.md#installation)

## workflow

Applies when the repo has a GitHub remote and any kit piece exists. Shell checks use read-only `git` and `gh`.

- [ ] `.agents/skills/repo-{commit,changelog,release}/SKILL.md` and `repo-changelog/references/curated-release.md` exist, and each `name` matches its directory. (workflow.md)
- [ ] Every relative link in the kit's skills and `docs/releases.md` resolves; a skill that lives only in the global directory (`humanizer`) is named, not linked. (workflow.md#project-skills)
- [ ] Every skill the kit names exists in `.agents/skills/` or `~/.claude/skills/`; the step that calls a missing one silently does nothing. (workflow.md#project-skills)
- [ ] No `{{` placeholder remains, and every command the skills run exists: Makefile targets, `package.json` scripts, `mise` tasks. (workflow.md#project-skills)
- [ ] The commit scopes in `repo-commit` match `git log` since the last tag. (workflow.md#commits)
- [ ] The commit skill's sentence on hooks matches what the hooks run. (hooks.md#stages)
- [ ] An end-to-end suite outside the CI-parity command is named in the commit skill, with when to run it and that a failure updates the suite in the same commit; a suite no skill runs rots unnoticed. (workflow.md#project-skills)
- [ ] `AGENTS.md` holds no commit or changelog rules; a commit suffix rule lives in `repo-commit`. (workflow.md#commits)
- [ ] `release-please-config.json` has `include-component-in-tag: false`, no `skip-changelog`, and a `release-type` matching the ecosystem. (workflow.md#ownership)
- [ ] The commit skill's release-counting types match `changelog-sections`. (workflow.md#commits)
- [ ] The manifest version equals the latest `v*` tag, the formatter excludes the manifest, and no `bootstrap-sha`, `initial-version`, or `release-as` remains after the first release PR merged. (workflow.md#ownership)
- [ ] A workflow runs the CI-parity command on pushes to the default branch and on pull requests, which gates the release PR. (workflow.md#ownership)
- [ ] `release.yml` points at both `.github/` files and runs on the default branch; a publish job only attaches artifacts, no step edits the notes, and a release tool keeps existing notes. (workflow.md#ownership)
- [ ] `gh api /repos/<owner>/<repo>/actions/permissions/workflow` reports `can_approve_pull_request_reviews: true`. (workflow.md#ownership)
- [ ] Release headings use release-please's format, no `## [Unreleased]` block or `---`-only line remains, and the docs lint passes on `*` bullets next to older `-` ones. (workflow.md#changelog)
- [ ] The newest `CHANGELOG.md` heading is the manifest version; an open release PR (`gh pr list --label "autorelease: pending"`) has `### Highlights` on its branch and matching PR notes, and is not opened by internal-only commits. (workflow.md#changelog)
- [ ] Each released version's GitHub Release notes (`gh release view v<version>`) match its `CHANGELOG.md` section. (workflow.md#ownership)
- [ ] Every commit on the default branch since the last tag is a Conventional Commit. (workflow.md#commits)
- [ ] Each kit file matches its `nbr-repo-setup` template with the project's values filled in. A divergence is project-specific (keep), lag (offer the template update), or lead (propose carrying it back into the template). (workflow.md#project-skills)

## dependencies

Applies when a `repo-dep-upgrades` skill exists.

- [ ] `.agents/skills/repo-dep-upgrades/SKILL.md` exists, and its outdated, upgrade, and verification commands exist. (dependencies.md)
- [ ] Its commit prefix matches the repo's commit convention. (dependencies.md)
- [ ] When Dependabot or Renovate is configured, the skill covers its PRs. (dependencies.md)
