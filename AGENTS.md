# AGENTS.md

## Project

This repository contains **Nokomon**, a top-down creature-collecting RPG. Read
[`VISION.md`](VISION.md) before making design or implementation decisions. Treat
that document as the current product canon and update it when the user settles a
new direction.

The project is in preproduction. Prefer small, reviewable decisions and playable
prototypes over speculative systems or large amounts of content.

## Working with the user

- Collaborate on the game as a creative and technical partner. Explain important
  tradeoffs in plain language.
- Preserve decisions the user has already made. Do not silently substitute a
  more conventional creature-collector mechanic.
- When a design detail is undecided, distinguish proposals from settled canon.
- Make reasonable, reversible assumptions to maintain momentum. Ask before a
  choice would materially redefine the game or create substantial scope.
- Keep `VISION.md` concise and internally consistent as the design evolves.
- Work directly on `main` and push completed changes to `origin/main`, as the
  user has requested. Do not create feature branches or pull requests unless the
  user asks for them.
- Commit only files relevant to the current task. Preserve unrelated user work.

## Settled game constraints

Do not contradict these constraints unless the user explicitly changes them:

- Godot 4 and GDScript, with a 2D top-down presentation.
- Browser play is a meaningful target. Use the Compatibility renderer and test
  web exports early.
- The initial game is single-player. Keep future trading or turn-based
  multiplayer architecturally possible without building it now.
- The world contains biological, spiritual, and mythological creatures, not
  robots or manufactured creature species.
- A party contains up to six creatures, with one active at a time in turn-based
  battles.
- Each creature equips three general techniques and one non-damaging Instinct.
- There are no potions or usable healing consumables. Healing comes from
  creatures, doctors and clinics, rest, or suitable sanctuaries.
- Creatures and the familiar can receive custom names.
- Creatures and the familiar can wear stat-neutral cosmetics such as hats.
- The familiar is separate from the battle party and does not participate in
  ordinary battles.
- Familiar adaptations are permanently unlocked through exploration and
  discovery; they are not equipped as a loadout.
- Affinities include natural elements and may expand into supernatural or
  conceptual types such as Ghost and Mystic.
- Confirmed effectiveness relationships include Water over Fire, Water over
  Earth through erosion, and Earth over Air because wind cannot readily move
  stone.
- The narrative must give real weight to prioritizing humanity or creatures.
  Avoid a simplistic morality meter or painless universal solution.

## Design principles

- Make collecting about observing and understanding creatures, not only random
  encounters or low capture probabilities.
- Make every creature feel like a living part of an ecosystem.
- Let affinity relationships follow understandable physical, ecological, or
  mythological logic.
- Keep affinity advantages meaningful without making them automatic wins.
- Give healing creatures a genuine strategic role.
- Make moral consequences specific and visible in settlements, habitats,
  migration patterns, dialogue, and available services.
- Keep common encounters brisk; reserve full six-creature battles for important
  opponents.
- Favor a compact, interconnected world over an oversized procedural one.
- Cosmetics should express attachment and personality, never combat power.
- Prefer readable `.io`-style immediacy without assuming MMO scope.

## Technical principles

- Keep simulation and rules separate from presentation. Battle calculations
  should not depend on UI nodes, animation timing, or local input.
- Make content data-driven. Creatures, affinities, moves, Instincts, traits,
  status effects, recruitment conditions, cosmetics, and familiar adaptations
  should normally be authorable without changing gameplay code.
- Use typed GDScript and custom `Resource` classes for authored game data unless
  a demonstrated requirement favors another format.
- Use stable internal IDs for content. Display names and player-given names must
  remain separate from IDs.
- Design save data for migration: include a schema version and avoid serializing
  scene-tree implementation details.
- Keep deterministic battle state serializable so future replays, tests, and
  networked turns remain possible.
- Treat browser limitations as first-class. Avoid relying on C#, native-only
  extensions, filesystem assumptions, or threaded behavior for core gameplay.
- Build reusable behavior from composition and data before adding
  creature-specific scripts. Unique code is acceptable for genuinely unique
  encounters.
- Cosmetics should use named attachment points with per-animation offsets. Begin
  with polished head and neck slots before expanding.

## Quality bar

For implementation work:

- Run the most relevant automated checks available.
- Add focused tests for deterministic rules such as affinity effectiveness,
  damage, switching, healing, progression, and serialization.
- Test a web export whenever changes touch rendering, input, persistence, audio,
  loading, or networking assumptions.
- Keep warnings and errors out of committed Godot output where practical.
- Document manual verification when an interaction cannot yet be automated.
- Do not add dependencies or plugins merely for convenience; explain their
  lasting value and browser implications first.

## Near-term target

Prioritize the vertical slice described in `VISION.md`: one settlement and
clinic, one biome, roughly six creatures, representative affinities, the core
battle loop, creature-based healing, one non-battle recruitment, the familiar
and one permanent adaptation, naming, a small cosmetic set, a rival, a guardian,
and one choice affecting both people and an ecosystem.

The purpose of this slice is to validate whether exploration, understanding,
befriending, customization, and battle form a satisfying loop. Do not expand the
content count or begin multiplayer before that loop is demonstrated.
