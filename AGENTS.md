# RD_Transport repository instructions

## Design and language

- Use [docs/GDD.md](docs/GDD.md) as the source of truth for game design, scope, and implementation status. Update the
  relevant design section when a change alters player-facing rules.
- Write repository docs, code identifiers, and test names in English. Put player-facing translations in localization
  data. Reply in the user's language.
- Use concise English Git commit titles only, with no body, trailers, sign-offs, or attribution. Commit when requested.

## Project layout

- Use the Unity editor version in `ProjectSettings/ProjectVersion.txt`. Review dependency compatibility before changing
  it.
- Put new first-party assets in `Assets/_Project` and organize them by purpose: `Scenes`, `Prefabs`, `Art`, `Audio`,
  `ScriptableObjects`, `Settings`, `Localization`, `UI`, `Editor`, `Runtime`, and `Tests`. Create each folder as it
  becomes necessary.
- Organize `Runtime` into `Core`, `Application`, `Gameplay`, `Infrastructure`, `UI`, and `Bootstrap`. Use
  `RDTransport.<Layer>` namespaces and explicit asmdef references as assemblies are introduced.
- `Core` owns Unity-free simulation and rules. `Application` owns use cases, state transitions, and ports. `Gameplay`
  and `UI` adapt inputs and display the simulation. `Infrastructure` implements storage and engine integrations. Wire
  dependencies at `Bootstrap` through explicit composition. Dependencies flow toward `Core` and `Application`; keep
  views and infrastructure independent from each other.
- Put Unity test assemblies under `Tests/EditMode` and `Tests/PlayMode`. Preserve asset GUIDs and track `.meta` files,
  package manifests, lockfiles, and project settings.

## Shared UnityTemplates modules

- Follow Planet_IO's selected-source approach. Run
  `powershell -NoProfile -ExecutionPolicy Bypass -File Tools/Link-UnityTemplates.ps1` from the repository root before
  opening a fresh checkout on Windows. The script uses the sibling `UnityTemplates` repository by default and accepts
  `-TemplateProject` for a different source checkout.
- `Tools/UnityTemplates.revision` pins the source. The script creates a detached `.unitytemplates` worktree and links
  selected `Runtime` and `Editor` directories under `Assets/TemplateSources`. Track their folder metadata and keep
  checkout and junction contents ignored. Treat linked files as read-only from this project.
- The initial modules are `RD.Foundation`, `RD.Startup`, `RD.SceneFlow` (and its editor assembly), `RD.Settings`, and
  `RD.Save`. Use them for shared primitives, boot orchestration, scene loading, preferences, and snapshot storage when
  those features are implemented. Keep cargo, routing, the economy, and save schema and migrations in RD_Transport.
- Before implementing an engine-facing utility, consult UnityTemplates' `MODULES.md`, the module README, and the asmdefs
  at the pinned revision. Check transitive references and native Unity package requirements. Bring in only modules with
  an identified use. Keep gameplay integration in the project and reusable fixes in UnityTemplates.
- When updating the pin or module list, update the linker, matching ignore entries, and folder metadata as applicable.
  Close Unity before changing the checkout, verify the local worktree is clean, then detach it at the new pin or
  recreate it via Git. Validate links and compile in the editor version declared by RD_Transport. Keep demos and library
  tests outside the imported source tree.

## Implementation and verification

- Use tabs (width 4), Allman braces, explicit local types, and blank lines between logical blocks in C#. Keep UI event
  handlers thin and bind scene dependencies at startup.
- Keep simulation time explicit. Make simulation updates independent of render frame rate and use stable IDs and
  deterministic tie-breaking. Keep authored catalog assets separate from mutable save data.
- Cover routing, event ordering, cargo conservation, settlement idempotency, and reload behavior in focused EditMode
  tests. Use PlayMode tests for bootstrap, UI, or scene behavior where appropriate. Verify affected assemblies and
  changed scenes and report which checks ran.