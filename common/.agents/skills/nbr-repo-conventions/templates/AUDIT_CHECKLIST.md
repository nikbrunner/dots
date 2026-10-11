# Audit checklist

Each rule is a target state; classify every rule in a topic's block with `path:line` evidence.

## typescript

- [ ] No `any` appears in any form: parameters, return types, generics, or assertions; `unknown` appears only as a last resort. (typescript.md#type-safety)
- [ ] No `as` assertion silences the compiler; `as const`, `satisfies`, and an assertion at an untyped third-party boundary are fine. (typescript.md#anti-patterns)
- [ ] Exported functions declare their return type. (typescript.md#type-safety)
- [ ] No variable is initialized to `null` or `undefined` and assigned its real value later. (typescript.md#type-safety)
- [ ] Union types over a fixed set of values derive from an `as const` source (`(typeof keys)[number]`) instead of repeating the values. (typescript.md#type-derivation)
- [ ] Lookup objects keyed by a union use `Record<Union, ...>` or `as const satisfies Record<Union, ...>`, so a changed union breaks the build. (typescript.md#type-derivation)
- [ ] Where a Zod schema exists, its type is `z.infer<typeof schema>`, with no parallel hand-written type. (typescript.md#type-derivation)
- [ ] Object contracts use `interface`; unions and computed types use `type`. (typescript.md#type-derivation)
- [ ] Functions take at most 2 positional parameters; 3 or more go into one destructured object argument. (typescript.md#function-design)
- [ ] Named functions, including helpers inside components, are `function` declarations, not const arrows; arrows appear only as inline callbacks passed as props or arguments. (typescript.md#function-design)
- [ ] Logic uses functions and object literals, with creator functions (`createUser`) instead of classes and constructors. (typescript.md#code-style)
- [ ] No commented-out code remains. (typescript.md#code-style)
- [ ] Collection work creates new values: no in-place `sort`/`reverse` on shared data, `toSorted`/`toReversed` instead. (typescript.md#immutability)
- [ ] Booleans read as assertions (`isX`, `hasX`, `canX`); props are `onX`, their implementations `handleX`. (typescript.md#naming)

## react

- [ ] Styles are imported only by Dumb Components and Layout Components; Partials have no style file. (react.md#core-principles)
- [ ] Containers and route components carry no styling beyond small layout utility classes. (react.md#core-principles)
- [ ] Dumb Components receive data and callbacks as props and never call `useQuery`, fetch, or read a store. (react/component-patterns.md#anti-patterns)
- [ ] When the project has i18n, components receive localized text as props instead of hardcoding strings. (react.md#core-principles)
- [ ] Each role's root element carries its attribute: `data-component`, `data-partial`, `data-layout`, or `data-container`. (react/component-patterns.md#data-attributes)
- [ ] In route-based apps the route component is the container, with no `*Container` wrapper in between; standalone containers are named `*Container`. (react.md#routes-as-containers)
- [ ] Containers delegate non-rendering logic beyond about 10 lines to a hook named after its domain topic (`useUserProfile`). (react/hooks-as-logic-layer.md#when-to-extract-a-hook)
- [ ] No props are forwarded unused through 3 or more levels. (react/component-patterns.md#broad-vs-deep-split)
- [ ] No component is configured through a pile of boolean props where composing parts would do. (react.md#compose-dont-configure)
- [ ] `src/` follows technical separation: `components/`, `containers/`, `partials/`, `hooks/`, `api/`, `lib/`, `types/`. (react/folder-structure.md#default-technical-separation)
- [ ] `hooks/` holds UI utilities and shared event hooks only, with no TanStack Query and no server state. (react/folder-structure.md#hooks-vs-api)
- [ ] Files and folders are kebab-case and named after the component; a component with parts, styles, or tests has a folder (`button/button.tsx`, `button.module.css`) with an `index.ts` that only re-exports it, and a one-file component stays a file. (react/folder-structure.md#naming-conventions)
- [ ] Imports use `./` for siblings and the `#/` alias elsewhere, with no `../`. (react/folder-structure.md#imports)
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
- [ ] CVA variants map to CSS Module references, boolean axes use `false: null`, and a component accepting `className` merges it; a closed component omits it. (css.md#class-names)
- [ ] Components carry no outer margin; parents space children with `gap`. (css.md#authoring)
- [ ] No rule targets a generated CSS Module class name of another component, and no `!important` fights the cascade. (css.md#authoring)

## state

- [ ] Shareable view state (filters, pagination, sort, active tab) lives in router search params, not in `useState` or a store. (state.md#decision-flow)
- [ ] When TanStack Router is used, routes that read search params validate them with `validateSearch` and a schema. (state/url-state-patterns.md#simple-case-filters--pagination)
- [ ] Data from an API lives in TanStack Query and is never copied into a client store or `useState`. (state/state-separation.md#server-state-vs-client-state)
- [ ] A client store, when present, holds only state shared across unrelated components that URL, server, local, and Context state cannot hold, with no server data and no URL-shareable state. (state.md#decision-flow)
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
- [ ] When route loaders prefetch, `queryOptions`/`mutationOptions` factories live in per-entity files, hooks are thin wrappers around them, and loaders call `queryClient.query({ ...factory(), staleTime: "static" })`, with no `ensureQueryData` or `fetchQuery`. (tanstack/query-patterns.md#entity-file-the-reusable-layer)
- [ ] Route components read loader-prefetched data with `useSuspenseQuery`. (react.md#routes-as-containers)
- [ ] The fetch wrapper returns `unknown`, and every `queryFn`/`mutationFn` parses the response with the topic's schema. (tanstack.md#data-boundary)
- [ ] Failed requests surface as an `ApiError` with a machine-readable code. (tanstack.md#data-boundary)
- [ ] Query factories are named `get*` and mutation factories are bare verbs, with no topic prefix or `Options` suffix. (tanstack.md#data-boundary)
- [ ] The API object and `QueryClient` are in router context; loaders and route components reach the API through it. (tanstack.md#data-boundary)
- [ ] Hooks that compose several queries live in the `api/` topic folder, or next to their single consumer, never in `hooks/`. (tanstack/query-patterns.md#orchestration--topic-hooks)
- [ ] When TanStack Form is used, every `useStore(form.store, ...)` passes a selector, and no `useField` is used for reactivity. (tanstack/form-patterns.md#anti-patterns)
- [ ] When TanStack Form is used, reset buttons are `type="button"` calling `form.reset()`, never `type="reset"`. (tanstack/form-patterns.md#reset-prevent-native-html-reset)
- [ ] When TanStack Form is used, field values live in form state only, with no mirrored controlled `useState`. (tanstack/form-patterns.md#anti-patterns)
- [ ] When TanStack Form is used with SSR, client and server share one `formOptions`, the server validates with `createServerValidate`, and the client merges back with `mergeForm` and `useTransform`. (tanstack/form-ssr-patterns.md)

## validation

- [ ] Network responses, URL params, persisted browser data, and submitted input are parsed by a schema at entry; no typed generic stands in for validation. (validation.md#boundaries)
- [ ] Types for validated data come from `z.infer`, with no parallel hand-written type. (validation.md#schema-first-type-derived)
- [ ] Search schemas use `.catch()` for malformed values and `.default()` only for missing ones. (validation.md#search-params)
- [ ] `parse` is used where invalid data is a contract failure, `safeParse` where the caller shows a validation message. (validation.md#failure-handling)
- [ ] Locked fields use `readOnly` for final values and `disabled` for unavailable controls, with the reason shown. (validation.md#locked-fields)

## authentication

Applies when the app has authenticated routes.

- [ ] Public and authenticated routes sit under pathless `_public/` and `_app/` groups, and `_app/` is guarded before its children render. (authentication.md#route-groups)
- [ ] The `_app/` guard handles only the authentication 401 and rethrows everything else. (authentication.md#route-groups)
- [ ] Identity comes from one server-backed current-user query, never from local storage, decoded tokens, or route flags. (authentication.md#one-current-user-query)
- [ ] Credentials and access tokens are not held in React state. (authentication.md#one-current-user-query)

## testing

- [ ] Tests sit next to their source as `*.test.ts(x)`. (testing.md)
- [ ] Pure logic with decisions (parsing, permissions, reducers) has unit tests; hook decisions are tested as pure functions. (testing.md)
- [ ] No test only checks that props map onto markup. (testing.md)
- [ ] Data-layer tests stub `fetch` at the transport and run the real query client. (testing.md)

## assets

- [ ] Application images are imported from `src/assets/`; photographs are WebP with a long edge of 2000px or less. (assets.md)
- [ ] In-app icons and line art are inline SVG components using `currentColor`. (assets.md)

## tooling

- [ ] Each TanStack library in use has its devtools package where one exists, mounted only in development. (tooling.md)
- [ ] TypeScript is strict with `verbatimModuleSyntax`, and type-only imports use `import type`. (tooling.md#typescript-and-eslint)
- [ ] ESLint uses flat config with type-aware rules and bans `as` and non-null `!` outside tests; the only inline disables sit at untyped third-party boundaries with a reason. (tooling.md#typescript-and-eslint)
- [ ] No library is hand-rebuilt where the stack's owner of that layer (Form, Query, Router, Table) is available. (tooling.md)

## npm-project

Applies when the repo has a `package.json`.

- [ ] `"type": "module"`, a Node floor in `engines.node` or `.nvmrc`, and `private: true` only on unpublished packages. (npm-project.md#packagejson)
- [ ] Check scripts are `verify:*` and only read; `format` and `lint` are the writers. (npm-project.md#scripts)
- [ ] `verify:staged` and `verify:full` exist and the hooks call them. (npm-project.md#scripts)
- [ ] A lockfile is committed and no dependency uses `latest`. (npm-project.md#dependencies)
- [ ] The `#/` alias is wired through `package.json` `imports` and the TypeScript paths. (npm-project.md#packagejson)

## docs-structure

- [ ] `README.md` says what the project is, how to set it up, and its scripts; `docs/` holds one reader goal per page, with an index when there are several. (docs-structure.md#the-shape)
- [ ] Decisions live in the `docs/<topic>.md` page for their subject or in `docs/adr/`, and domain terms in `GLOSSARY.md` rather than a `CONTEXT.md`. (docs-structure.md#the-shape)
- [ ] Docs link to scripts, types, and config instead of copying their values, and state the current situation without history. (docs-structure.md#how-docs-are-written)
- [ ] No doc contradicts the code it describes. (docs-structure.md#staleness)

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
- [ ] No hook event is registered twice for the same purpose across the agent settings. (agent-tooling.md#agent-hooks)

## git

- [ ] One hook manager is active: Lefthook in a repo under the maintainer's control, otherwise the repo's established tool; no lint-staged or nano-staged next to Lefthook. (git.md#control)
- [ ] Hooks are installed: the Lefthook install or `git config --get core.hooksPath` points Git at the configured hooks, and the directory exists. (git.md#repository-config)
- [ ] `pull.rebase` is `true` and `merge.ff` is `only`, applied by a `git:config` script or the contributor setup. (git.md#repository-config)
- [ ] Hooks only check: no hook runs a writer (`--write`, `--fix`) or re-stages files (`stage_fixed`, `git add`), unless an existing autofix hook was kept by agreement. (git.md#check-never-write)
- [ ] Pre-commit runs `verify:staged` (or the repo's equivalent) and pre-push runs `verify:full`; CI runs the same full scope. (git.md#verify-scopes)
- [ ] Correctness checks block the commit; advisory checks such as docs drift warn and let it through. (git.md#verify-scopes)
- [ ] Hooks call existing scripts or tasks, and every command they name exists. (git.md#verify-scopes)
- [ ] A fresh clone installs the hooks through the project's setup, and the contributor instructions name it. (git.md#installation)

## workflow

Applies when the repo has a GitHub remote and any kit piece exists. Shell checks use read-only `git` and `gh`.

- [ ] `.agents/skills/repo-{commit,changelog,release}/SKILL.md` and `repo-changelog/references/curated-release.md` exist, and each `name` matches its directory. (workflow.md)
- [ ] Every relative link in the kit's skills and `docs/releases.md` resolves; a skill that lives only in the global directory (`humanizer`) is named, not linked. (workflow.md#project-skills)
- [ ] Every skill the kit names exists in `.agents/skills/` or `~/.claude/skills/`; the step that calls a missing one silently does nothing. (workflow.md#project-skills)
- [ ] No `{{` placeholder remains, and every command the skills run exists: Makefile targets, `package.json` scripts, `mise` tasks. (workflow.md#project-skills)
- [ ] The commit scopes in `repo-commit` match `git log` since the last tag. (workflow.md#commits)
- [ ] The commit skill's sentence on hooks matches what the hooks run. (git.md#verify-scopes)
- [ ] An end-to-end suite outside the CI-parity command is named in the commit skill, with when to run it and that a failure updates the suite in the same commit; a suite no skill runs rots unnoticed. (workflow.md#project-skills)
- [ ] No instruction file (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`) declares commit or changelog rules; a suffix rule lives in `repo-commit`. A grammar that contradicts Conventional Commits next to a release-please config is Broken. (workflow.md#commits)
- [ ] `release-please-config.json` has `include-component-in-tag: false`, no `skip-changelog`, and a `release-type` matching the ecosystem. (workflow.md#ownership)
- [ ] The commit skill's release-counting types match `changelog-sections`. (workflow.md#commits)
- [ ] The manifest version equals the latest `v*` tag, the formatter excludes the manifest, and no `bootstrap-sha`, `initial-version`, or `release-as` remains after the first release PR merged. (workflow.md#ownership)
- [ ] A workflow runs the CI-parity command on pushes to the default branch and on pull requests, which gates the release PR. (workflow.md#ownership)
- [ ] `release.yml` points at both `.github/` files and runs on the default branch; a publish job only attaches artifacts, no step edits the notes, and a release tool keeps existing notes. (workflow.md#ownership)
- [ ] `gh api /repos/<owner>/<repo>/actions/permissions/workflow` reports `can_approve_pull_request_reviews: true`. (workflow.md#ownership)
- [ ] Release headings use release-please's format, no `## [Unreleased]` block or `---`-only line remains, and the docs lint passes on `*` bullets next to older `-` ones. (workflow.md#changelog)
- [ ] The newest `CHANGELOG.md` heading is the manifest version; an open release PR (`gh pr list --label "autorelease: pending"`) has `### Highlights` on its branch and matching PR notes, and is not opened by internal-only commits. (workflow.md#changelog)
- [ ] Each released version's GitHub Release notes (`gh release view v<version>`) match its `CHANGELOG.md` section. (workflow.md#ownership)
- [ ] Every commit on the default branch since the last tag is a Conventional Commit; the finding lists the hashes release-please will skip. (workflow.md#commits)
- [ ] Ticket or issue keys sit in a trailing subject suffix, never a leading `[KEY]`. (workflow.md#commits)
- [ ] Each kit file matches its `nbr-repo-setup` template with the project's values filled in. A divergence is project-specific (keep), lag (offer the template update), or lead (propose carrying it back into the template). (workflow.md#project-skills)

## dependencies

Applies when a `repo-dep-upgrades` skill exists.

- [ ] `.agents/skills/repo-dep-upgrades/SKILL.md` exists, and its outdated, upgrade, and verification commands exist. (dependencies.md)
- [ ] Its commit prefix matches the repo's commit convention. (dependencies.md)
- [ ] When Dependabot or Renovate is configured, the skill covers its PRs. (dependencies.md)
