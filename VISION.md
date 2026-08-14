# Nokomon: Game Vision

## Status

This document captures the initial shared vision for **Nokomon**. It defines the
game's current creative and technical direction while leaving detailed balance,
content, and production decisions open for prototyping.

## High concept

Nokomon is a top-down creature-collecting RPG set around **1900**, during its
world's Industrial Revolution. Rapid human expansion is disrupting ancient
creature habitats and migration routes. Players explore interconnected regions,
befriend creatures by understanding them, build a party for tactical turn-based
battles, and develop a close bond with a noncombat familiar.

The player's decisions affect both settlements and ecosystems. Progress should
regularly ask what humanity owes the living world when human welfare and
creature welfare cannot both be protected without sacrifice.

## Player experience

Nokomon should create four recurring feelings:

- **Discovery:** What lives here, and what is hidden beyond the next landmark?
- **Understanding:** How does this creature behave, and what does it need?
- **Attachment:** This named and customized creature has become part of my story.
- **Responsibility:** Who benefits from my decision, and who bears its cost?

The presentation should have the immediacy and readability associated with
top-down `.io` games: responsive movement, clean silhouettes, visible creatures,
minimal friction, and short interactions. This does not imply that the initial
game is massively multiplayer.

Nokomon is a **pixel art game**. Environments, characters, creatures, battle
scenes, effects, and interface art should share a deliberate pixel-art visual
language with crisp edges and consistent pixel density. Animation should favor
clear poses and expressive key frames over excessive detail. Exact sprite
resolution, tile size, and animation frame counts remain prototype decisions.

The world uses a predominantly earthy color palette. Forests are built from
many dark, layered greens, with lighter foliage and natural highlights used to
preserve readable paths, creatures, and interaction points. Towns lean into
warm oranges and varied browns through soil, timber, stone, roofs, and lamplight.
Other regions may introduce their own accents, but should remain grounded in
natural, earthy colors so the world feels cohesive.

Human clothing, architecture, tools, transport, and infrastructure reflect the
turn-of-the-century industrial setting. Railways, steam power, factories, mines,
mills, and expanding towns can improve human lives while consuming land and
resources or dividing habitats. Technology should feel grounded in this era;
modern electronics and futuristic machinery do not belong in the setting.

## Design pillars

### Creatures are living beings, not equipment

The world contains biological, spiritual, and mythological creatures. There are
no robots or mechanical creature species. Humans may use grounded technology,
but Nokomon should remain a world of living ecosystems rather than manufactured
monsters.

Collecting centers on learning about creatures. Recruitment may involve battle,
but can also require observation, assistance, food, environmental restoration,
or satisfying a creature-specific social behavior. Rare creatures should be
memorable to discover rather than merely having low random capture odds.

### Bonds are personal

Players can give individual creatures and their familiar custom names. A
creature's species name remains visible in encyclopedic contexts, while its
given name is used by the party interface, clinics, dialogue, and battles.

Creatures and the familiar can wear cosmetic accessories such as hats, ribbons,
scarves, flowers, glasses, badges, and collars. Cosmetics express personality
and do not modify combat statistics.

### Choices carry visible consequences

Human needs must be legitimate, and creature-friendly choices must carry real
costs. The game should avoid reducing this tension to a single good-versus-evil
meter.

Consequences should be represented through specific world states such as:

- Settlement welfare and available services
- Habitat health and creature populations
- Migration patterns and access to resources
- Relationships with communities and conservation-minded groups
- The familiar's behavior and understanding of the world

Choices should visibly change settlements, routes, ecosystems, dialogue, and
later conflicts.

Example dilemmas include restoring a migration route through farmland, diverting
water between a drought-stricken town and an aquatic habitat, and protecting a
dangerous guardian creature whose territory supplies a community's livelihood.

## Exploration

The world is a compact collection of interconnected regions rather than an
enormous procedural map. Creatures appear visibly in habitats and exhibit
behavior appropriate to their species, the environment, weather, and time.

To befriend a Nokomon, the player first finds it in the world. How an encounter
begins depends on the creature's behavior: some Nokomon run away when the player
approaches, some curiously approach the player, and some stalk and attack the
player. When an aggressive Nokomon attacks, its attack starts an encounter.
Reaching or meeting a Nokomon may lead to battle or ask the player to meet
non-battle conditions such as observing, helping, feeding, or responding to its
social behavior. Successfully resolving those conditions befriends the Nokomon.

Creature treats can be offered during an encounter and are consumed from the
satchel. Food is not a universal capture item: curious creatures may accept it
readily, while wary or aggressive creatures may first need the player to read
their behavior, demonstrate restraint, or reduce the immediate danger. Treats
never restore battle HP and befriending resolves the encounter without treating
the creature as defeated.

The central exploration loop is:

1. Prepare in a settlement.
2. Enter a region and observe its ecosystem.
3. Discover creatures, landmarks, and local conflicts.
4. Approach or respond to a creature to begin its encounter.
5. Befriend or battle creatures and resolve expedition objectives.
6. Unlock new familiar adaptations and routes.
7. Return to a settlement to heal, learn, customize the party, and see the
   consequences of recent choices.

### The familiar

The player has a named familiar that travels alongside them but does not occupy
a party slot and never participates in ordinary battles.

As the player explores, studies creatures, and restores parts of the world, the
familiar permanently learns adaptations such as:

- Swimming through deep water
- Gliding across gaps
- Burrowing into tunnels or uncovering buried objects
- Tracking creatures by scent or other signs
- Revealing spirits and hidden paths
- Moving natural obstacles
- Illuminating dark places
- Communicating with ancient creatures

Adaptations do not need to be equipped. Once discovered, they remain available
and make exploration increasingly fluid. They should manifest through expressive
changes in the familiar's behavior or appearance while preserving its core
identity.

The familiar is also central to the story. Its growing ability to absorb and
express creature adaptations may challenge how both human communities and the
player understand the boundary between people and creatures.

## Creatures and affinities

Creatures have affinities encompassing natural elements and supernatural or
conceptual forces. The system must be expandable without changing the underlying
battle code.

The current affinities are:

- Fire
- Water
- Earth
- Air
- Plant
- Ice
- Ghost
- Mystic
- Poison
- Bug
- Beast
- Electric
- Fungus
- Dragon

The affinity previously called Nature has been renamed **Plant**. Shadow and
future possibilities such as Light, Storm, Dream, Sound, or Void may be
explored later.

Affinity relationships should follow understandable physical, ecological, or
mythological logic. An advantageous attacking affinity deals **2x damage**. A
defending affinity's resistance causes it to take **half damage**. These rules
can overlap: a matchup can be shaped by the attacker's advantage, the defender's
resistance, or both. Any interaction not listed below is neutral.

| Affinity | Its moves deal 2x damage to | It takes half damage from |
| --- | --- | --- |
| Water | Fire, Earth, Ghost, Bug | Fire, Bug, Fungus |
| Fire | Plant, Ice, Bug, Beast | Plant, Ice, Mystic, Electric |
| Earth | Mystic, Poison, Electric | Mystic, Poison, Electric, Air |
| Air | Water, Fire | Fire, Bug, Beast |
| Ghost | Plant, Beast, Dragon, Ghost | Poison, Beast, Fungus |
| Plant | Water, Earth | Electric, Water, Air |
| Ice | Water, Earth, Air, Bug, Fungus, Dragon, Plant | Ice |
| Mystic | Ghost, Dragon, Mystic | Dragon, Ice, Bug, Fungus |
| Poison | Plant, Water, Ice, Mystic | Ice, Fungus, Air |
| Bug | Plant, Mystic, Air | Mystic, Poison, Beast |
| Beast | Mystic | Bug, Ghost |
| Electric | Air, Dragon | Air, Fire |
| Fungus | Plant, Bug, Ghost | Bug, Fungus, Ghost, Air |
| Dragon | Water, Fire, Earth, Beast, Dragon | Fire, Bug, Ghost |

For example, Water extinguishes Fire and erodes Earth. Earth resists Air because
wind cannot readily move stone. Advantages should matter without deciding a
battle by themselves.

### Shadow and Void

If both affinities are eventually used, their identities should remain distinct:

- **Shadow** represents hidden life: darkness, fear, secrecy, illusion,
  nightmares, and ambush.
- **Void** represents absence: silence, erasure, emptiness, spatial distortion,
  and forces that may not belong to the natural world.

In short, Shadow hides what exists; Void removes it. Shadow can be a regular
affinity, while Void should be reserved for rare, late-game creatures or story
events and may interact unusually with the standard chart. Void should be omitted
if the narrative does not give it a clear purpose.

Initial creatures should generally have one affinity. The data model may allow
multiple affinities so the mechanic can be explored later without a rewrite.

**Ampust** is a confirmed dual-affinity **Ghost/Bug** Nokomon inspired by a
locust and Anubis. Its initial player-authored sprite is stored with the game;
detailed ecology, techniques, and recruitment behavior remain open for further
development.

## Battles

Battles are turn-based. The player carries a party of up to six creatures, with
one creature active at a time. When a battle begins during an encounter, the
player sends out one Nokomon from the party to fight the opposing Nokomon.

During an encounter, the interface shows the opposing Nokomon's name, level,
remaining health, and any status inflictions currently affecting it. This
information remains visible so the player can make informed tactical choices.

The battle interface should have the immediate readability and large,
controller-friendly commands of a modern handheld creature-battling RPG while
maintaining an original Nokomon identity. Its dominant palette is forest green,
emerald, mint, deep teal, and cream, with restrained accent colors for status
and selection feedback. The battlefield occupies most of the screen, combatant
information remains clearly separated, and the primary turn commands are large
and usable with mouse, controller, or touch input. The preproduction layout
reference is [`design/mockups/battle-ui-green-concept.png`](design/mockups/battle-ui-green-concept.png);
it communicates layout and palette only, not the final pixel-art rendering
style, and the placeholder creatures shown there are not established species.

Each creature equips four moves:

1. General technique
2. General technique
3. General technique
4. **Instinct**: a non-damaging tactical move

Instincts may protect the user, raise or lower statistics, recover health,
cleanse a condition, prepare a counter, manipulate action priority, or support a
future switch. A creature may learn multiple Instincts while equipping only one.

On a turn, a player can use a move, switch the active creature, or attempt to
withdraw when the encounter allows it. Priority and speed determine resolution.
Switching is strategically important, and some techniques may anticipate or
punish predictable switches.

Battles are fully turn-based; enemy attacks resolve from creature statistics,
techniques, affinities, status effects, and tactical choices rather than a
real-time dodge phase. The interface may use a high-contrast, characterful
dialogue box with terse narration, but the battle layout and mechanics remain
those of a party-based creature battler. There is no bullet-hell phase.

Most wild and routine encounters should use fewer than six opposing creatures.
Full-party battles are reserved for rivals, major characters, and important
story encounters so ordinary play remains brisk.

### Experience

Encounters award EXP for either defeating an opposing Nokomon in battle or
successfully befriending it. A Nokomon levels up after earning enough EXP. For
most Nokomon, the EXP required for the next level begins at a species-specific
value from **420 to 800 EXP**. After each level gained, the requirement for the
following level increases by **250 EXP**. The exact EXP awarded by encounters
and how it is distributed remain balance decisions.

Some Nokomon evolve after reaching a defined level threshold. Nokomon also
learn new moves at defined level thresholds. Evolution thresholds and level-up
move lists are authored per species rather than embedded in progression code.

### Recovery and endurance

Nokomon has no potions or other consumable healing items. Recovery comes from:

- Healing and regeneration moves used by creatures
- Defensive and cleansing abilities
- Clinics and doctors in towns
- Resting at safe locations or appropriate natural sanctuaries

Clinics provide routine healing and reinforce the role of settlements in an
expedition. Healing creatures remain strategically valuable both during and
between difficult encounters. Routes should be designed around this recovery
model rather than balanced around an inventory of consumables.

## Customization

Cosmetic accessories use visual attachment points such as the head, face, neck,
back, or tail. The first implementation should concentrate on polished head and
neck accessories before expanding to more difficult body shapes.

Creature animations provide offsets for supported attachment points so an
accessory can follow the creature without requiring a unique combined sprite
sheet for every creature-accessory pairing.

## Inventory interface

The inventory should use the broad, controller-friendly structure of a modern
console creature-collecting RPG while maintaining an original Nokomon identity.
A slim pocket selector sits at the left, a large scrollable item list occupies
the center, and a generous detail panel at the right shows the selected item's
art, description, and available action. Selection, quantity, and controller or
touch prompts must remain readable at a glance.

Its visual language is grounded turn-of-the-century steampunk: aged brass,
dark iron, worn leather, parchment, walnut, and restrained gauge or rivet
details, supported by the world's forest-green and deep-teal accents. Mechanical
decoration must remain secondary to clarity, and should avoid futuristic
electronics or excessive ornamental gears. The preproduction layout reference
is [`design/mockups/inventory-ui-steampunk-concept.png`](design/mockups/inventory-ui-steampunk-concept.png);
its item names and art are illustrative rather than established content.

Inventory pockets may cover exploration tools, key items, creature treats,
cosmetics, and gathered materials. The interface must not imply potions or other
usable healing consumables, since recovery remains the role of creatures,
clinics, rest, and suitable sanctuaries.

## Narrative foundation

Ancient migration routes are collapsing as railways, factories, mines, farms,
and growing settlements reshape the land. The player becomes involved with
people working to understand or restore the routes and discovers that the
disruption is tied to broader changes in the relationship between civilization
and creatures.

Different communities propose competing responses: preservation, adaptation,
relocation, management, exploitation, or control. The player's choices determine
which settlements thrive, which habitats survive, and whether coexistence is
possible without one side bearing all of the cost.

The tone should carry the weight of prioritizing humanity or creatures. It can
still contain warmth, humor, wonder, and companionship, but consequences should
not be erased by an obviously perfect solution.

## Technical direction

Nokomon will use **Godot 4 with GDScript** and a two-dimensional top-down
presentation. The project should use the Compatibility renderer and test web
exports from the beginning.

The initial game is single-player. Future trading or turn-based battles should
remain possible by keeping deterministic combat rules and game data separate
from user interface, animation, and local save state. Multiplayer infrastructure
is not part of the initial scope.

### Data-driven content

Adding creatures is one of the project's core creative activities. New creatures
should usually be created from data and art without writing gameplay code.

A creature definition should be able to reference:

- Identity, species text, affinity, habitat tags, and rarity
- Base statistics, EXP requirements, and growth
- Evolution thresholds and evolved species
- Learnable techniques, Instincts, and their level thresholds
- Passive traits and battle behavior
- Overworld behavior and recruitment conditions
- Familiar adaptation contributions
- Sprites, portraits, animations, sounds, and cosmetic attachment points

Affinities, moves, traits, status effects, recruitment conditions, and
adaptations should also be reusable data resources. Unique scripts remain
possible for exceptional creatures but should not be the default workflow.

A later editor tool may provide creature creation, ID validation, sprite
previews, stat-curve previews, affinity checks, and immediate test battles.

## First playable prototype

The first vertical slice should be small enough to test the complete experience:

- One settlement with a working clinic
- One nearby biome
- Approximately six battle-capable creatures
- A representative subset of the initial affinities
- A party of up to six, with one active creature at a time
- Four-move battles, including Instincts and creature-based healing
- One meaningful non-battle recruitment encounter
- The named familiar and one permanently unlocked adaptation
- Creature naming and a small set of head or neck cosmetics
- One rival battle and one guardian encounter
- One decision that visibly affects both the settlement and its ecosystem
- Desktop and browser builds

The prototype's primary question is whether exploring, understanding, befriending,
customizing, and battling creatures forms a satisfying loop. Content scale and
multiplayer should wait until that answer is clear.

## Open design questions

- What information about enemy intent is shown during battle?
- What is the familiar's origin and personality?
- How demanding should expeditions be without consumable recovery items?
- What sprite resolution, tile size, and animation budget best preserve
  readability across desktop and browser displays?
- How are major world-state consequences communicated and saved?
