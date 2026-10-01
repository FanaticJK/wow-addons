# Addon Modernization Log

Tracks which addon folders in this workspace have been audited, fixed and modernized.
Target client for everything here: **WotLK 3.3.5a (`## Interface: 30300`)**.

The cross-addon summary of the pass (bug fixes, UI, performance, migration, testing) is in
[MODERNIZATION_REPORT.md](MODERNIZATION_REPORT.md). This file is the per-addon tracker.

> **Resuming work?** Read [Where things stand](#where-things-stand) and
> [How to verify](#how-to-verify) first. Everything below the Status table is already done —
> start from [What is left](#what-is-left), not from scratch.

## Status

| Folder | Author | Version (before → after) | Status | Notes |
|---|---|---|---|---|
| `Bagnon` | Tuller | 2.12.6 → 2.13.0 | Done (needs in-game test) | Core bag/bank/keyring windows |
| `Bagnon_Config` | Tuller | (none) | Done (needs in-game test) | Load-on-demand options panels |
| `Bagnon_Forever` | Tuller | 1.1.2 → 1.2.0 | Done (needs in-game test) | Offline character data (BagnonDB) |
| `Bagnon_GuildBank` | Tuller | 1.0.0 → 1.1.0 | Done (needs in-game test) | Guild bank window |
| `Bagnon_Tooltips` | Tuller | (none) | Done (needs in-game test) | "Who has what" item tooltips |
| `BankStack` | Kemayo | v17 → v17.1 | Done (needs in-game test) | Sorting / stacking |
| `Carbonite` | Carbon Based Creations | 3.34 (unchanged, see below) | Done, static only (needs in-game test) | Map / quest / guide. Minified vendor code |
| `CarboniteItems` | Carbon Based Creations | 1.00 | Done, static only | Load-on-demand item data, no changes needed |
| `CarboniteNodes` | Carbon Based Creations | 1.00 | Done, static only | Load-on-demand gather nodes, no changes needed |
| `CarboniteTransfer` | Carbon Based Creations | 1.01 | Done, static only | Warehouse transfer stub, no changes needed |
| `!Swatter` | Norganna's AddOns | 5.8.4723 | Done, static only (needs in-game test) | Error catcher (Auctioneer support lib). Real gsub-pattern bug fixed |
| `AckisRecipeList` | Ackis/Torhal et al. | 1.0-2817 | Done, static only | Recipe scanner. One benign pattern escape cleaned |
| `AckisRecipeList_QuickScan` | Torhal | 3.3.5-1.0.1 | Done, static only | LoD companion, no changes needed |
| `AllStats` | Ganoran | 1.1 | Done, static only | Character stats panel, no changes needed |
| `Altoholic` | Thaoky | 3.3.002b | Done, static only | Alt manager (DataStore front-end) |
| `Altoholic_Achievements` | Thaoky | 3.3.002 | Done, static only | Achievements module, no changes needed |
| `AtlasLoot` | Hegarol | 5.11.04 | Done, static only | Loot browser. `break;` false positives cleared in checker |
| `AtlasLootFu` | Hegarol | 5.11.04 | Done, static only | FuBar plugin front-end |
| `AtlasLoot_BurningCrusade` | Hegarol | 5.11.04 | Done, static only | LoD loot data |
| `AtlasLoot_Crafting` | Hegarol | 5.11.04 | Done, static only | LoD loot data |
| `AtlasLoot_OriginalWoW` | Hegarol | 5.11.04 | Done, static only | LoD loot data |
| `AtlasLoot_WorldEvents` | Hegarol | 5.11.04 | Done, static only | LoD loot data |
| `AtlasLoot_WrathoftheLichKing` | Hegarol | 5.11.04 | Done, static only | LoD loot data |
| `Auc-Advanced` | Norganna's AddOns | 5.8.4723 | Done, static only (needs in-game test) | Auctioneer core. `UiParent` typo + escapes fixed |
| `Auc-Filter-Basic` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer filter module |
| `Auc-ScanData` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer scan cache |
| `Auc-Stat-Histogram` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer stat module |
| `Auc-Stat-iLevel` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer stat module |
| `Auc-Stat-Purchased` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer stat module |
| `Auc-Stat-Simple` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer stat module |
| `Auc-Stat-StdDev` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer stat module |
| `Auc-Util-FixAH` | Norganna's AddOns | 5.8.4723 | Done, static only | Auctioneer AH-taint workaround |
| `Baggins` | Nargiddley | r435 | Done, static only (needs in-game test) | Bag addon. `## Interface` bumped 30200 → 30300 |
| `Stubby` | Norganna's AddOns | 5.8.4723 | Done, static only (needs in-game test) | Auctioneer boot/hook library. Four real hook bugs fixed |
| `DataStore` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Core module registry + guild comm |
| `DataStore_Achievements` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Bad `\[` escape + nil-date and leaked-global fixes |
| `DataStore_Auctions` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | `OnDisable` event leak closed |
| `DataStore_Characters` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Unscanned-character and max-level divide-by-zero guards |
| `DataStore_Containers` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Three `GetThisGuild()` nil guards |
| `DataStore_Crafts` | Thaoky | 3.3.002 | Done, static only (needs in-game test) | Recipe-link, subclass-filter and `ScanCooldowns` guards |
| `DataStore_Currencies` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Re-entrant scan guard + leaked `_` |
| `DataStore_Inventory` | Thaoky | 3.3.002 | Done, static only (needs in-game test) | NaN average item level fixed; `ScanInventory` made local |
| `DataStore_Mails` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Nil sender in the `ReturnInboxItem` hook |
| `DataStore_Pets` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Sparse pet list fixed |
| `DataStore_Quests` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Reward `isUsable` always false; `OnDisable` leak |
| `DataStore_Reputations` | Thaoky | 3.3.001 | Done, static only | No changes needed |
| `DataStore_Skills` | Thaoky | 3.3.002 | Done, static only (needs in-game test) | Shadowed `self` in the chat handler |
| `DataStore_Spells` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Stale-index nil guard |
| `DataStore_Stats` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Leaked `_`; `UNIT_INVENTORY_CHANGED` now filtered to the player |
| `DataStore_Talents` | Thaoky | 3.3.001 | Done, static only (needs in-game test) | Glyph carry-over, leaked globals, nil-iterator crashes |

Status values: `Pending` → `In progress` → `Done (needs in-game test)` → `Verified in game`.

**Nothing here has been run in a real WoW client.** "Done" means: clean static analysis
plus a clean pass through the scripted runtime harness in `_dev/`. See
[What still needs a real client](#what-still-needs-a-real-client).

## Where things stand

Last worked on: **2026-10-01**.

- All six Bagnon-family addons have had the full pass. No addon is half-finished.
- The four Carbonite folders had a **static-only** pass (see [Carbonite](#carbonite--334)):
  the runtime harness does not load Carbonite, so none of its code has been executed here.
- **2026-09-28: 23 more addons added and given a static-only pass** (Auctioneer suite, AtlasLoot
  family, Altoholic family, AckisRecipeList family, !Swatter, AllStats, Baggins). Same as
  Carbonite: `check.js`/`run.js` load and parse them, but no runtime scenario drives them, so
  their code has not been *executed* here. Real bugs found were fixed; see
  [Per-addon details](#per-addon-details) and the checker notes below.
- **2026-10-01: Stubby and the 17 DataStore folders added and given a static pass plus a deep
  audit** (see [the 2026-10-01 pass](#2026-10-01-pass--stubby--datastore-deep-audit)). Same
  standard as the two passes before it: static gate first, then a manual runtime read with every
  candidate re-verified against the source. Their `.toc` files already declared `## Interface:
  30300`, so no bump was needed.
- **Altoholic's dependency chain resolves for the first time.** `Altoholic.toc` hard-depends on
  `DataStore` plus all 16 modules; until these folders were added the client would have refused to
  load it at all. Nothing in Altoholic changed — it simply has its dependencies now.
- The Bagnon work is committed (`e1d8651`). The Carbonite folders and everything from the
  2026-09-28 pass (the 23 addon folders, their fixes, the `check.js` improvements and the
  expanded `known.txt`) are still **untracked or modified**; `git status` shows what is not
  committed yet.
- The verification harness lives in `_dev/` and is committed with the project so it is not
  lost between sessions. `_dev/node_modules/` is gitignored — reinstall with `npm install`.
- Current gate state: **4 of 4 green** (see below).

## How to verify

```
cd _dev
npm install          # once, or after node_modules is cleaned up
node all.js          # runs everything, prints one summary
node all.js -v       # same, but shows each step's full output
```

`all.js` runs these four, and any of them can also be run on its own:

| Command | What it proves | Current result |
|---|---|---|
| `node check.js` | Every `.toc`/XML entry resolves; every `## Interface` is 30300; every Lua file parses as 5.1; no retail-only API; no undefined globals; no bogus string escapes | 624 files, 0 errors, 0 unknown globals |
| `node run.js smoke.lua` | Fresh install: all six Bagnon-family addons load and the whole UI is driven (open/close, search, bag toggles, player switch, options panels, sort, guild bank, logout); every options panel fits the 3.3.5 options window | 133 checks, 0 failures |
| `node run.js migrate.lua sv_legacy.lua` | A legacy 2.6.0 + partly corrupted SavedVariables file is repaired, migrated, and user data preserved across a save/load cycle | 50 checks, 0 failures |
| `node run.js garbage.lua sv_garbage.lua` | Top-level SavedVariables that are not even tables (a string/number/false) are rebuilt without erroring, and the user is told | 7 checks, 0 failures |

### What the harness is

- `check.js` — static checker. Walks each addon folder, follows the `.toc` into XML
  `<Script>`/`<Include>` lists, parses each Lua file with `luaparse` (Lua 5.1, latin1 + BOM
  strip), and reports missing files, syntax errors, retail-only APIs and undefined globals
  against the baseline in `known.txt`. It also rejects quoted strings with an escape Lua 5.1
  does not know (`"Interface\Buttons\..."`): the client silently drops the backslash, so the
  path is wrong but nothing errors. luaparse accepts these, which is why it is a separate check.
  Four things were added for the 2026-09-28 pass, all so the report shows real problems instead
  of structural noise:
  - **`## Interface` is checked** — anything other than `30300` is an error. Caught Baggins at
    30200 (3.2.0), which loads greyed-out as out-of-date on 3.3.5a.
  - **`break;` is tolerated.** luaparse wrongly rejects a `;` after `break` (`'end' expected near
    ';'`) although Lua 5.1's grammar allows an optional `;` after any last-statement and the real
    client accepts it. The `;` is dropped for the parse only, swapped for a space so error
    columns stay exact. This alone cleared four bogus SYNTAX errors (AtlasLoot ×3, Auc-Advanced).
  - **XML `name=` frames are registered as globals.** A UI object declared in XML becomes a
    global of that name, and `$parent` resolves to the nearest named ancestor. Without this,
    every XML-declared frame (and every `$parentTab2` child) looked like an undefined global.
  - **`CreateFrame(type, "Name", ...)` names are registered too**, the Lua equivalent of the
    same thing. Together these two removed 306 false "undefined global" reports.
- `known.txt` — curated list of real 3.3.5 globals. **Any name reported that is not in this
  file is a new typo or a new dependency**, so read new reports rather than appending blindly.
- `wowmock.lua` + `wowapi.lua` — a hand-written 3.3.5 client mock (widgets, events, container
  API, tooltips, dropdowns, popups, guild bank, interface options, slash commands).
  **Design rule: there is no catch-all.** An unmocked API errors loudly, because a silent stub
  would hide exactly the bugs this harness exists to find. When the harness reports something,
  first decide whether it is a real addon bug or mock infidelity — several fixes in the mock
  carry a comment explaining which it was and why.
- `run.js` — loads the real addon folders into a Lua VM (fengari) on top of the mock, in
  `.toc` order, calling each chunk with `(addonName, addonPrivateTable)` exactly as the client
  does, then runs a scenario. Exit code is non-zero on any failure, so it gates.
- `smoke.lua`, `migrate.lua`, `garbage.lua` — scenarios. `sv_legacy.lua` and `sv_garbage.lua`
  are SavedVariables preloads, restored before any addon loads, like the client does.

### Adding a scenario

Write `_dev/<name>.lua`, return the number of failed checks, and add it to the `steps` list in
`_dev/all.js`. Copy the `Step`/`Check`/`Note` helpers from an existing scenario.

Gotchas already paid for, don't rediscover them:

- `GetAllItemSlots`, `GetBagSlots` and `GetPlayers` return **iterators**, not tables.
- Read the database **before** showing any window: a frame saves its own position on show, and
  the mock has no real geometry, so stored anchors stop being the ones migration produced.
- Snapshot values **before** `PLAYER_LOGOUT`: logout intentionally strips values equal to
  defaults so the saved file stays small.
- `wipe(MOCK.popups)` before asserting on a popup; earlier steps leak them.
- `run.js` compiles **every** addon folder up front, Carbonite included, even though no scenario
  loads Carbonite. A Carbonite file that does not compile under fengari (Lua 5.3) therefore
  fails every scenario. That is how the bad `\H` escape surfaced: 5.3 rejects it, 5.1 does not.

## Adding a new addon

1. Copy the addon folder into this workspace root.
2. Add a row to the table above with status `Pending`.
3. Ask for the same modernization pass on that folder.
4. `check.js` and `run.js` pick up new folders automatically (they scan the workspace root),
   so run `node _dev/all.js` first — the static check alone usually finds real problems.
5. When done, move the row to `Done (needs in-game test)` and add a section under
   [Per-addon details](#per-addon-details).

## Reusable checklist (applied to every addon)

- [ ] `.toc`: correct `## Interface`, every listed file exists, no stray lines, dependencies declared
- [ ] XML include lists: no references to missing files
- [ ] Static check: Lua 5.1 syntax + undefined globals (typos such as `cMoney`, `cVersion`)
- [ ] SavedVariables: defaults, type repair for corrupted values, idempotent migrations, never wipe user data
- [ ] Events: correct names, registered once, unregistered when hidden, nothing missed on first load
- [ ] Performance: no polling/OnUpdate when idle, no per-event full scans while hidden
- [ ] API: only 3.3.5 APIs (no `C_*`, `SetSize`, `SetShown`, `SetColorTexture`, `BackdropTemplate`)
- [ ] Combat/taint: no protected calls or secure frame changes in combat
- [ ] UI: shared style module, consistent spacing/colors/buttons, tooltips on every control
- [ ] UX: destructive actions confirmed, clear error messages, reset options
- [ ] Localization: new strings added to the enUS locale file only (others fall back)
- [ ] Log updated (this file)

## Per-addon details

### `Bagnon` — 2.12.6 → 2.13.0

Core window. The largest change is the layout engine.

- **Layout rewritten around a shared style module.** `Frame:Layout()` used to accumulate
  hard-coded pixel offsets (`8`, `-4`, `24`, `156`) scattered across ten `Place*` methods.
  It now computes a header row / middle / footer from `Bagnon.Style` constants
  (`PADDING`, `GAP`, `MENU_BUTTON_SIZE`, `FOOTER_HEIGHT`, `MIN_FRAME_WIDTH`), with a
  `placeButtonRow` helper for both header sides. A header band and dividers were added.
  The `Place*` methods now take their anchor position as an argument instead of chaining off
  each other, so the order they run in is explicit.
- **Six near-identical `*_ENABLE_UPDATE` handlers collapsed** into one `Frame:LayoutForFrame`
  registered under each message name.
- **New: free slot counter** (`components/slotCounter.lua`) in the footer. Counts general-purpose
  vs specialty bags separately, colors orange when nearly full and red when full, tooltip breaks
  down the two. Off by default for the keyring and guild bank.
- **New: sort button** (`components/sortButton.lua`) in the header. Left click sorts, right click
  compresses stacks, shift-click moves stacks between bags and bank. Only appears when BankStack
  is loaded and never for cached (offline) characters. Clicking while BankStack is running aborts it.
- **New: `Bagnon:ShowFrameOptions(frameID)`** — the options toggle and title right-click now open
  the options panel already scrolled to that window's settings, and print a clear message naming
  `Bagnon_Config` if it is disabled, instead of failing silently.
- **`ResetFramePositions` no longer touches `guildbank` unless `Bagnon_GuildBank` is loaded** —
  doing so seeded the guild bank with inventory defaults.
- **Bug fixed: `SavedFrameSettings:UpgradeDB()` mutated `hiddenBags` while iterating it with
  `pairs()`** (the `{[index]=bagID}` → `{[bagID]=true}` upgrade). Adding keys during traversal is
  undefined behaviour in Lua 5.1 and raises `invalid key to 'next'` outright in 5.3. It now
  collects, then removes, then inserts. Found by the migration scenario.
- SavedVariables hardening: `ValidateDB` checks anchor points, frame layers, scale (0.25–3),
  opacity (0–1), integer column counts and colour components, repairs a non-table frame entry
  **in place**, and `GetDB()` tells the user when settings were unreadable rather than silently
  resetting.
- `GetSlotCounts` reuses one scratch table instead of allocating per contents update.

### `Bagnon_Config`

- **`_G.Bagnon` clobber fixed** (`panels/general.lua:12`). The hack panel was created as
  `CreateFrame('Frame', 'Bagnon', ...)`, which **overwrites the global `Bagnon` addon table**
  with a frame — breaking `Bindings.xml` (binding bodies run in global scope) and anything else
  reading the global. It is now named `BagnonOptionsCategory`; the Blizzard options tree nests
  by display name (`f.name` / `f.parent`), not by the frame's global name, so the panel still
  lands in the right place. The smoke test now asserts `_G.Bagnon == Bagnon` before and after
  `Bagnon_Config` loads.
- **New shared widgets**: `widgets/button.lua` and `widgets/tooltip.lua`, so every control uses
  one tooltip anchor and one button style.
- Every option now has a tooltip (`L.Tip_*`), and controls that do not apply to the current
  window are **disabled with a reason** rather than hidden or silently inert
  (`L.Warning_RequiresBankStack`, `L.Warning_NotAvailableForFrame`).
- Panels reorganized and the frame options panel largely rewritten around the shared widgets.
- New strings went into the enUS locale file only; cn/ru/tw fall back.
- **Bug fixed: the options panels spilled out of the Interface Options window.** They were laid
  out for a ~620px-wide panel area (590px dividers, a second column at x=330, 256px sliders,
  and a 250px checkbox label that wrapped into the next row on the Display panel). On 3.3.5,
  `InterfaceOptionsFrame` is a fixed **648x520**, which leaves a panel area of **413x428**
  (648 − 22 − 175 − 16 − 22 wide, taken from the 3.3.5 `InterfaceOptionsFrame.xml`). The bigger
  858x660 window only arrived in later clients. What changed:
  - `widgets/optionsPanel.lua` holds that size (`WIDTH`/`HEIGHT`) and derives `RIGHT`,
    `CONTENT_WIDTH` and the section/note widths from it. Nothing is hard-coded to 590 any more.
  - Frame Settings: two columns that fit (second column at x=226, 163px sliders). The reset
    buttons share the dropdown's row, and the layer slider hides its min/max labels, which
    would otherwise print over each other.
  - Colors: one column, with the four slot-color swatches in a 2×2 grid. Display and General:
    one column at full width. The subtitle is one line (was 32px tall), so content starts at y=64.
  - Checkboxes take a label width (`OptionsCheckButton:New(..., labelWidth)`) that defaults to
    the full content width.
  - `Place`/`CreateSection`/`CreateNote` record each widget's box, and
    `OptionsPanel:GetLayoutOverflow()` lists anything outside the panel. `smoke.lua` asserts this
    for all four panels. With the old x=330 column restored, the check fails, as it should.

### `Bagnon_Forever` — 1.1.2 → 1.2.0

Offline character cache. The version handling here was actively destroying user data.

- **Bug fixed: every login wiped the offline cache.** `LoadSettings` compared major versions and
  on a mismatch did `BagnonForeverDB = {version = cVersion}` — `cVersion` is a **typo**, that
  global does not exist, so it stored `version = nil`, which made the next login mismatch again
  and wipe again. The storage format has not actually changed, so data is never discarded now:
  an unexpected version is simply stamped forward.
- Non-table realm/player entries are replaced rather than indexed into.
- **New: class is saved** (`SaveClass`) and exposed via `BagnonDB:GetPlayerClass(player)`.
- **Bug fixed: `GetItemCount(link, 'e', player)` never counted equipment.** It used the bag
  record's size (equipment has none, so 0) and started at slot 1, missing ammo in slot 0. It now
  scans slots 0–19 for the `'e'` pseudo-bag.
- Nil-safety on `GetContainerNumSlots`, `GetInventoryItemCount` and `GetItemIcon`, which return
  nil for empty or not-yet-known slots.

### `Bagnon_GuildBank` — 1.0.0 → 1.1.0

- **Bug fixed: `localization.xml` referenced seven locale files that were never shipped.** The
  `.toc` loaded it, and it included `localization\localization.lua` plus six translations — none of
  which exist in the addon, and never did. The guild bank therefore had no locale table of its own.
  The XML was removed and it now reads from the `Bagnon` AceLocale table, which is where the guild
  bank strings already lived.
  All five keys it uses (`TipGuildFunds`, `TipGuildDeposit`, `TipGuildWithdraw`,
  `TipGuildWithdrawRemaining`, `TipTabUnavailable`) are defined in `Bagnon/localization/localization.lua`.
- `MAX_TABS` / `SLOTS_PER_TAB` are defined locally, because Bagnon prevents
  `Blizzard_GuildBankUI` (which defines them) from loading.
- `GUILDBANKFRAME_OPENED` can fire twice for one visit (the loader and the event); it now shows
  once and only queries a tab when there is a valid one. Close force-hides, so a stale show
  count cannot leave the window stuck open.
- Money frame reworked into deposit / withdraw with a remaining-allowance tooltip; unavailable
  tabs are labelled rather than blank.

### `Bagnon_Tooltips`

- **Ownership counts are now cached per player per item.** Previously the current character was
  recounted from scratch on every `OnTooltipSetItem`, which fires several times a second while
  hovering, and each count scans every saved slot of every bag. Other characters' data cannot
  change during a session; the current character's cache is cleared on `BAG_UPDATE`,
  `PLAYERBANKSLOTS_CHANGED` and `UNIT_INVENTORY_CHANGED` for `player`.
- Owner names are **class-coloured** (using the class `Bagnon_Forever` now saves), and a total
  line is added when more than one character has the item.
- The tooltip is only `:Show()`n when a line was actually added, so unowned items no longer get
  a pointless resize.
- Guards at load if `BagnonDB` is missing, instead of erroring.

### `BankStack` — v17 → v17.1

- **Bug fixed: bank bags 8–11 were not recognised as bank bags.** `is_bank_bag` tested
  `bagid <= NUM_BANKBAGSLOTS` (7) instead of `bagid <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS` (11).
- **Bug fixed: the OnUpdate driver used the removed `arg1` global** instead of the `elapsed`
  argument, so the move timer never advanced from a real value.
- **Bug fixed: sorting a specialty bag could index a missing `bagcache['Normal']`**; it is now
  always created.
- **Bug fixed: the scanning tooltip lost its owner.** A `GameTooltip` drops its owner when it
  hides, after which `Set*Item` silently does nothing — so soulbound/conjured detection quietly
  stopped working. It is re-owned and cleared before every scan. Matching also switched from
  `string.match` to a plain `string.find`, since localized strings can contain pattern magic.
- Nil-safety throughout for uncached item info (`GetItemInfo` returns nil until the client has
  the item), which previously caused arithmetic and comparison errors mid-sort.
- `Compress` now uses `check_for_banks`, which also covers guild bank groups the old
  bank-only check missed.
- Config: descriptions rewritten from shorthand ("Talkativitinessism") to sentences, explicit
  `order`, validators accept negative bag ids (`-1` is the bank) and return a usable error
  string instead of `false`.
- `/bankstack` calls `InterfaceOptionsFrame_OpenToCategory` twice, because on 3.3.x the first
  call only opens the window without selecting the category.

### `Carbonite` — 3.34

`Carbonite.lua` is shipped **minified**: 26k lines, 2 MB, one-to-three-letter method names,
and one 1.2 MB line of map data (line 265). It cannot sensibly be restructured the way the
Bagnon code was. The pass was therefore limited to what static analysis proves wrong. Every fix
is a one-token change, and every other line is byte-for-byte as shipped. The version was **not**
bumped: Carbonite compares `Nx.VERSION*` against its SavedVariables and broadcasts it to other
Carbonite users, so a local bump could reset saved data or confuse the version check.

Edit it with an exact-match script, not by hand: most editors choke on the long lines, and the
file is CRLF + latin1.

- **Bug fixed: Halls of Reflection map texture path.** Map entry `14156` was written
  `"HallsofReflection\HallsofReflection1_"`. Lua 5.1 drops an unknown escape, so the client
  looked for `HallsofReflectionHallsofReflection1_` and the map tiles did not load. Now `\\`.
- **Bug fixed: Carbonite's slider backdrop was invisible.** `Nx.Sli` built its backdrop from
  `"Interface\Buttons\UI-SliderBar-Background"` / `-Border`, which is the same escape problem
  (`InterfaceButtonsUI-...`). Now `\\`.
- **Bug fixed: call to an undefined function `SSDC`** in `Nx.Com:GUVT`. It errored as soon as a
  "General" or "crbb*" channel was listed. The 3.3.5 API is `SetSelectedDisplayChannel`. Only
  reachable through the debug `/carb comver` command.
- **Bug fixed: `NXlBGMsgIncoming`** was not defined in any locale, so `Nx.Map:BGM_OI` sent a nil
  battleground message. It now uses the "Incoming" text, `NXlBGMessages[2]`. Nothing calls it
  today.
- `Nx.Map.UQMPOIH` indexed `QUEST_MAP_POI` / `QUEST_MAP_ADDITIONAL_POI`, which are not 3.3.5
  globals, so it would error when called. It is now guarded. Also uncalled today.
- Reads of never-assigned globals were replaced with what they always evaluated to (behaviour
  unchanged, but the checker gates on them): `inf:Upd(n)` → `inf:Upd()` (`Upd` takes no
  argument), `don and … or …` → the `or` branch, `format(str, sna)` → `str`, and the button
  x-offset `x` → `0` (it is re-anchored on the next line).
- `known.txt` gained a reviewed Carbonite section: 3.3.5 API/FrameXML names, the frames
  Carbonite creates by name (`NxQuestD*`, `NXMiniMapBut`, …), and optional/version-gated
  globals (`Cartographer_Notes`, `NLF1`, `GetDifficultyColor`, `QuestFrame_SetAsLastShown`, the
  last two only on pre-3.3 branches since `Nx.V33` is true).
- `check.js` walked luaparse's `globals` list as well as the AST, so it reported every use
  twice (every count in older reports is doubled). Fixed.

Also checked, nothing to fix:
- All 27 script blocks in `Carbonite.xml` and `Bindings.xml` parse as Lua 5.1, and every
  `Nx…` function they call (key bindings, minimap button, frame handlers) is defined in
  `Carbonite.lua`.
- Every `Interface\AddOns\Carbonite\…` texture or sound path resolves to a file in `Gfx/` or
  `Snd/`. The one exception, `Gfx\Map\Cont\Kal<n>`, has no folder shipped but is dead code: it
  sits under `if n==0` inside `for n=1,…`.

`CarboniteItems`, `CarboniteNodes` (load-on-demand data tables) and `CarboniteTransfer` parse
cleanly, have no bad escapes and no unknown globals. They did not need changes.
`CarboniteTransfer` sets `CarboniteTransferData = {}` at load. That is fine: SavedVariables
are restored after the file runs, so it is only the default.

Not attempted, and not realistic in minified code: Carbonite's performance (it runs many
OnUpdate handlers and joins its own `crbb*` chat channels for its comm features, which can
be turned off in its options).

### 2026-09-28 pass (Auctioneer / AtlasLoot / Altoholic / AckisRecipeList / !Swatter / AllStats / Baggins)

These 23 addons had a **static-only** pass, same standard as Carbonite: parsed, checked, and the
real problems the checker turned up were fixed in place. None has been run through a runtime
scenario, so none of their code has been *executed* here (see
[What still needs a real client](#what-still-needs-a-real-client)). All bundled Ace2/Ace3,
Dewdrop, Tablet, Configator, FuBar and similar libraries were left byte-for-byte as shipped
except for the specific one-token escape fixes noted below.

Real bugs fixed:

- **`!Swatter/Swatter.lua` — realm-suffix strip matched any character.** `realmList:gsub("\.logon\.worldofwarcraft\.com", "")`
  used `\.`, which Lua 5.1 reads as a bare `.` — a Lua-pattern *any character*, not a literal dot.
  Changed to `%.` so it strips the real suffix. The neighbouring `\<%s\>` format string was also
  cleaned to `<%s>` (the backslashes were dropped at runtime anyway).
- **`Auc-Advanced` — `CreateFrame("Frame", nil, UiParent)` parented to nil.** `UiParent` is a
  typo for `UIParent`; the seller-ignore frame was being created with no parent in both
  `Auc-Util-Appraiser/AprFrame.lua` and `Auc-Util-CompactUI/CompactUI.lua`. Fixed to `UIParent`.
- **`Baggins` — `## Interface: 30200`.** Bumped to `30300`; at 3.2.0 the client shows it as
  out-of-date and greys it out on 3.3.5a.

Benign escape cleanups (the client already dropped the backslash, so behaviour is unchanged; the
edits just stop `check.js` gating and make intent unambiguous):

- `AckisRecipeList/Datamine.lua` `"%a+\: "` → `"%a+: "`.
- `Auc-Util-SearchUI` Searcher{Disenchant,Prospect,Milling} note text `\%` → `%`.
- `Baggins/libs/Waterfall-1.0` gmatch class `[^\.]+` → `[^.]+` (dot is already literal in a class).
- `Auc-Advanced/CoreStrings.lua` two localised help strings (elGR, zhTW) had `\n` mangled into
  `\ n`/`\ ` by a translation tool; restored so the help text keeps its line breaks.

Reviewed and deliberately **not** changed:

- `Auc-Advanced/Libs/Configator/Configator.lua` reads `MoneyInputFrame_SetOnvalueChangedFunc`
  (lower-case `v`) — but only as `X or MoneyInputFrame_SetOnValueChangedFunc`, a guarded probe for
  a client that shipped the typo'd API name. It falls through to the correct one on 3.3.5.
- `Altoholic/Characters.lua` sort comparator passes a global `self` (nil) into `DataStore[func]`.
  This is a pre-existing leaked-local in Altoholic; fixing it correctly needs the real DataStore
  call semantics, so it was left rather than guessed at.
- ~45 other leaked locals (missing `local`) live in the vendored Ace2/Ace3/Tablet/Dewdrop/
  Configator libraries and a few Auc modules. They read as nil at runtime and are harmless; they
  are listed in `known.txt` under "reviewed benign leaked globals" so the gate stays meaningful.

### 2026-09-29 pass — AtlasLoot deep audit (logic/event/perf, not syntax)

The static pass above only found what a parser can see. This pass was a manual read of AtlasLoot's
core for defects that only show up when the code actually runs. Five real bugs, all fixed; the
`_dev` gate was re-run after each and stayed 4/4 green. None of this is verifiable in-game here.

- **`AtlasLoot/Core/AtlasLoot.lua` — `AtlasLoot_QueryLootPage` hung the client.** It paced its 30
  item queries with `while i<31 do ... if GetTime() - querytime > 0.03 then ... i=i+1 end end`.
  `GetTime()` returns the *current frame's* timestamp and does not advance during a single script
  execution, so after the first iteration the difference is always `0`, `i` never increments, and
  the loop spins until the client's script watchdog trips. Pressing the "query loot page" button
  froze the game. Replaced with a hidden frame driven by `OnUpdate(self, elapsed)` that accumulates
  real elapsed time and issues one query per 0.03 s, hiding itself after item 30 — same pacing and
  the same `GameTooltip:SetHyperlink` call, without blocking the frame. The stray globals `i`,
  `button` and `queryitem` became locals in the process.
- **`AtlasLoot/Core/LootButtons.lua:173` — `SetHyperlink(nil)` on enchant rows.**
  `AtlasLoot_GetEnchantLink` returns nil when the scanned tooltip line contains no `:` *and*
  `GetSpellLink` also returns nil; the result was passed straight into
  `AtlasLootTooltip:SetHyperlink`, which errors on nil. The link is now captured into a local and
  only set when non-nil.
- **`AtlasLoot/Core/LootButtons.lua:200` — method reference used as a condition.**
  `if ( ShoppingTooltip2:IsVisible() or ShoppingTooltip1.IsVisible)` — the second operand is the
  function object, not a call, so it is always truthy and the branch always ran. Changed to
  `ShoppingTooltip1:IsVisible()`.
- **`AtlasLoot/Core/AtlasLoot.lua:636` and `AtlasLoot/Core/Search.lua:90` — unguarded registry
  lookups.** Both indexed `AtlasLoot_TableNames[dataID]` without checking the `dataID` is
  registered. The item branch at `Search.lua:70` already had exactly this guard, so the two
  unguarded siblings were brought in line with it rather than given new behaviour.

`known.txt` gained a dated 2026-09-28 section: real 3.3.5 API/FrameXML frames and GlobalStrings,
the addons' own UI objects named via Lua string concatenation, and the third-party addons this
suite optionally integrates with (`DataStore*`, `Altoholic`, `AtlasLoot`, `AceLibrary`, `FuBar`,
`Skillet`, `TipTac`, `BeanCounter`, `Enchantrix`, `Stubby`, `BugGrabber`, …). Everything was
reviewed by category before being added, not appended blindly.

### 2026-09-30 pass — Altoholic / AckisRecipeList / Baggins / !Swatter / Auc-Filter-Basic deep audit

Same method as the AtlasLoot pass above: a manual read for defects that only appear when the code
runs, with every candidate re-verified against the source before anything was changed. Thirty-eight
bugs fixed across seven addon folders. The `_dev` gate was re-run after each batch and finished
4/4 green (501 Lua files parsed, 0 errors, 0 warnings, 0 unknown globals). The full per-file table
with severities is in `ADDON_TRACKER.md` under "Deep-audit findings"; this section records the
patterns and the judgement calls.

**Three recurring root causes account for most of it.**

The first is the pre-3.3.5 event model. WoW used to hand event arguments to handlers through the
globals `arg1`, `arg2`, … Those globals are gone, and AceEvent-3.0 passes `(event, ...)` to a
plain function handler instead. Three handlers in Altoholic were still filtering on `arg1`, which
now reads as nil, so the filter never passed and the handler body never ran:
`Altoholic.lua:278` never detected a raid lock, and `Frames/Pets.lua:292` never rescanned pet
data. The Pets case needed the declaration changed too — it was `function ns:OnChange()`, so the
implicit `self` was swallowing the event name. It is now `function ns.OnChange(event, unit)`.

The second is globals that were meant to be locals. `Baggins-Filtering.lua` had three: `operation`
in `CheckCategory`, `used` in `OnSlotChanged`, and `qualname` in the Quality rule's `GetName`.
Each is written and read within one function, so on a single bag the code appears to work; with
two bag frames filtering in the same frame, or a nested rule evaluation, they clobber each other.
The `operation` case is the worst of the three because it silently turns a configured OR into an
AND and the category simply comes back with the wrong items in it — no error, no clue.

The third is nil returns from client APIs that are only nil sometimes. `GetItemInfo`,
`GetTradeSkillRecipeLink`, `GetAchievementInfo` and DataStore's accessors all return nil for
something the client has not cached yet, and the calling code then concatenated, formatted, or
indexed it. Roughly twenty of the fixes are guards of this kind. In almost every case the addon's
*own* code already had the guard somewhere else, and the fix was to make the outlier match its
sibling rather than to invent behaviour: `Characters.lua:126-128` proved the shape for
`AccountSummary.lua:41-43`; `Search.lua:588` for `Search.lua:859`; `Talents.lua:435` for
`Talents.lua:611`; `Calendar.lua:944`'s load-on-demand guard for `Calendar.lua:482`;
`Baggins.lua`'s four `type(entry) == "table"` loops for the lone `if entry then` at line 663;
`GetRuleDesc:160` for `CleanRule:124`. Where no sibling existed the guard follows the file's own
`or 0` / early-return idiom.

**Four bugs were not in that pattern and are worth naming.**

`Altoholic/Characters.lua:229` — the sort comparator called `DataStore[func](self, a.key)`, but
`self` is not a parameter of that local function, so it resolved to the global `self`, which is
nil. Every DataStore accessor reached through a column sort ran with a nil receiver and errored.
This one had been known and unexplained for a while; the fix is `DataStore[func](DataStore, a.key)`.

`AckisRecipeList` walked the spellbook with `for index = 1, 25` and broke on `index == 25`. That
is wrong twice over: it stops 25 entries in, and the `index == 25` clause means entry 25 itself is
never examined. A profession sitting far enough down the General tab was simply not detected, and
`Player["Specialty"]` was cleared as though the player had none. The same loop appears in
`Player.lua`, `ARL.lua` and `AckisRecipeList_QuickScan/QuickScan.lua`; all three now walk
`1, 1024` and stop on the first nil `GetSpellName`, which is the actual end of the book.

`AckisRecipeList/ARL.lua:1114` called `GameTooltip:SetOwner(UIParent, ANCHOR_NONE)` with a bare
global. There is no such global — the argument is the *string* `"ANCHOR_NONE"`. Passing nil leaves
the tooltip anchored wherever it last was, so the quest scan reads whatever text is in it. The
interesting part is why the static gate never flagged it: `_dev/known.txt` carried an
`ANCHOR_NONE` entry, which was false and was masking a real bug. That entry has been removed and
the gate still reports zero unknown globals, which confirms nothing else relied on it.

`Baggins-Skins.lua:57` — `EnableSkin` looked up the profile's saved skin with no fallback. If the
plugin providing that skin is no longer installed, `currentSkin` stays nil and every later
`SkinSection` / `SetBankVisual` call errors, so the bags never draw at all. It now falls back to
`'default'`.

**`ChatFrameEditBox` is gone.** It was removed in 3.3.5 — `Altoholic/Changelog-Altoholic-r90.txt:30`
records the author hitting this at the time. Four call sites across three addons still used it
(`AtlasLoot/Core/LootButtons.lua:242`, `AckisRecipeList/Frame.lua:3570` and `:3584`,
`Auc-Filter-Basic/BasicFilter.lua:284`). Each was a dead branch that threw instead of doing its
job — inserting an item link into chat, or restoring chat focus when a popup closed. All four now
use `ChatEdit_GetLastActiveWindow()` behind a nil check.

**What was deliberately not changed.**

Five findings against Altoholic proposed guarding call sites for the case where `DataStore` is
absent. Altoholic declares DataStore as a hard `## Dependencies`, so the client refuses to load
the addon without it; those guards would handle a state that cannot occur, and they were rejected.
A proposed `GetCenter()` nil guard in `Baggins.lua:1849` was rejected for the same reason — the
button is visible and anchored by the time its own click handler runs.

`Altoholic/Profiler.lua:48` is a real bug and was still left alone. It computes
`p.duration = GetTime() - p.startTime`, and `GetTime()` does not advance inside a single script
execution, so every profiled duration is exactly `0`. The correct call is `debugprofilestop()`,
but it returns milliseconds where this code and its `:Dump()` output assume seconds, so fixing it
properly means auditing the display maths as well. It is a developer-only tool with no user-facing
effect, so it is recorded rather than half-fixed.

One layout detail in `Baggins:OptimizeSectionLayout` — sections with a nil `layout_areaid` are
skipped rather than treated as area 0 — is a plausible improvement whose only effect is visual.
It cannot be checked without a client, so it was left as-is. (The adjacent real bug in the same
function, a reset that cleared `layout_area_index` when the loop below uses `layout_areaid`, *was*
fixed.)

**Two findings are held pending a real client**, because both are claims about a 3.3.5 API
signature that cannot be settled from anything in this workspace, and applying either one wrongly
would break more than it fixes:

1. **AllStats** — the claim that `PaperDollFrame_SetStat` and its siblings take
   `(statFrame, unit, statIndex)` on 3.3.5. If that is wrong, the change breaks the entire stats
   panel. AllStats is otherwise unchanged.
2. **`!Swatter/Swatter.lua:122`** — the claim that 3.3.5 calls `UIParent_OnEvent` as
   `(self, event, ...)` rather than `(etype, ...)`. Swatter *hooks* this function, so a wrong
   signature here corrupts the event chain for every addon in the client.

Both need a real 3.3.5 `FrameXML` dump or a running client to settle.

**The Auctioneer suite was not audited.** That audit was cancelled before it produced anything, so
`Auc-Advanced` and its modules have had nothing beyond the static gate. The one Auctioneer-family
fix in this pass (`Auc-Filter-Basic/BasicFilter.lua:284`) came out of the `ChatFrameEditBox` sweep,
not out of an audit of that addon. Phase 7 still stands in full.

No tests were written for any of this: the `_dev` harness has no way to execute these addons (see
"What still needs a real client" below), and adding scenarios for the auction house, trade skill
and DataStore APIs is the separate piece of work already listed under "What is left".

### 2026-10-01 pass — Stubby + DataStore deep audit

Eighteen new folders: `Stubby` and the DataStore family (`DataStore` plus its 16 modules). Same
method as the two passes above — static gate first, then a manual read for defects that only
appear when the code runs, with every candidate re-verified against the source before anything was
changed. The `_dev` gate finished 4/4 green (624 Lua files parsed, 0 errors, 0 warnings,
0 unknown globals). The per-file table with severities is in `ADDON_TRACKER.md` under "Deep-audit
findings"; this section records the patterns and the judgement calls.

**The `.toc` files needed nothing.** All 18 already declare `## Interface: 30300`, every listed
file resolves, and every module except the core declares `## Dependencies: DataStore`. One hard
static error existed: `DataStore_Achievements.lua:200` wrote the achievement hyperlink as
`"|h\[%s\]|h"`. Lua 5.1 drops an unknown escape, so the output was already correct; the edit stops
`check.js` gating and makes the intent unambiguous. Same class as the 2026-09-28 benign escape
cleanups.

**`## DefaultState: disabled` was left alone.** It is present identically in all 17 DataStore
`.toc` files *and* in `Altoholic.toc`. That is Thaoky's packaging choice — the modules are opt-in
and the user enables them alongside Altoholic — not an install defect, so nothing was changed.

**Fourteen "undefined globals" turned out to be a checker gap, not addon bugs.** Names like
`DataStoreMailOptions_SliderMailExpiryLow` are children created by an *inherited* Blizzard FrameXML
template (`OptionsSliderTemplate` gives a slider `$parentLow`/`$parentHigh`/`$parentText`). Those
children exist only in Blizzard's XML, which `check.js` never reads, so they looked undefined.
`collectXmlNames` now expands a reviewed per-template `TEMPLATE_CHILDREN` table when it sees an
`inherits=` attribute. It is deliberately per-template rather than a blanket "any suffix after a
known name": a catch-all would also swallow genuine typos, which is the only thing this check
exists to find. Consistent with the harness's documented no-catch-all rule. The remaining 66
unknown names are real 3.3.5 APIs (combat ratings, arena, 3.0+ achievements and currency,
trade-skill, mail, quest log, talents/glyphs, companions) and went into `known.txt` under a dated,
grouped, commented section — reviewed by category, not appended blindly.

**The recurring root causes are the same three as the 2026-09-30 pass**, which is itself a useful
result: nil returns from client APIs that are only nil sometimes, globals that were meant to be
locals, and events whose arguments are not what the handler assumes.

The nil-return family is the largest. `GetThisGuild()` returns nil in the documented post-login
window, and three call sites indexed it unguarded while the function *directly above* them already
had the guard (`DataStore_Containers.lua:354` and `:760`, against the sibling at `:271`).
`GetTradeSkillRecipeLink` is nil until the tradeskill is cached, which is exactly the state on the
first `TRADE_SKILL_SHOW` (`DataStore_Crafts.lua:487`; the sibling idiom is eight lines up at
`:448`). `GetSubClassID` falls off the end and returns nil when no filter matched, and its twin two
lines down already wrote `invSlotID = invSlotID or 1`. In almost every case the fix was to make the
outlier match its sibling rather than invent behaviour.

Leaked globals: `prereqTier`/`prereqColumn` written for every talent of every tab
(`DataStore_Talents.lua:161`), `month`/`day`/`year` written for every achievement of every category
(`DataStore_Achievements.lua:73`), the global `_` written six times per stats scan
(`DataStore_Stats.lua:61`) and twice in `DataStore_Currencies`, and `function ScanInventory()`
without `local` — a very generic name any other addon can overwrite, where every sibling scanner in
the family is local.

Event-argument bugs: `function addon:CHAT_MSG_SKILL(self, msg)` and
`function addon:ACHIEVEMENT_EARNED(self, id)` both declare an explicit `self` that shadows the
colon's implicit one and absorbs the event name. Both happen to work, because the bodies reach
`addon` directly, but they are the same shape as the Altoholic `ns:OnChange` bug from the previous
pass and were renamed to `event`. `UNIT_INVENTORY_CHANGED` fires for *every* unit — pet, party,
target, inspect — and both `DataStore_Stats` and `DataStore_Inventory` rescanned the player
unconditionally on it; both now filter on `unit == "player"`, matching `OnBagUpdate(event, bag)` in
`DataStore_Mails`.

**Six bugs sit outside those patterns and are worth naming.**

`DataStore_Inventory.lua:165` divided by `itemCount` with no guard. The count is 0 whenever nothing
but a shirt or tabard is equipped, or when every `GetInventoryItemLink` returns nil — which happens
on `PLAYER_ALIVE` during a loading screen. `0/0` is NaN, and NaN written to SavedVariables makes
the whole `DataStore_InventoryDB` file unparseable on the next login. This is the only finding in
the pass that could destroy user data.

`DataStore_Talents.lua:204` declared `glyphID` once outside both loops and only reassigned it
inside `if link then`. An empty socket left the *previous* socket's id in place, and the `glyphID or 0`
below preserved it, so every empty socket after a filled one was stored as a duplicate of the last
filled one. Any character with fewer than six glyphs per spec hit this.

`DataStore_Quests.lua:265` read `isUsable = (isUsable and isUsable == 1)`, but `isUsable` came from
`strsplit`, so it is the *string* `"1"` and never the number. The comparison was always false:
`GetQuestLogRewardInfo` reported every reward as unusable.

`DataStore_Pets.lua:37` skipped index `i` rather than compacting when `GetCompanionInfo` returned
nil, leaving holes in the list. `#pets` is undefined on a sparse array and in practice stops at the
first hole, so `_IsPetKnown` under-reported mounts and companions. `DataStore_Spells.lua:92`
already used `table.insert` for the same shape.

`Stubby/Stubby.lua:314` — `unpack(callDetail)` where `callDetail[3]` is nil for a
**negative-position** hook. With a hole at [3] the length operator yields 2, `unpack` returns two
values, and `callParams` is nil, so the next line errors. Negative positions are what real callers
use (`Auc-Advanced/CoreMain.lua:205` at -200, `Auc-Util-AskPrice/AskPrice.lua:74` at -200 on
`ChatFrame_OnEvent`, `Auc-Util-SimpleAuction/SimpFrame.lua:1281` at -300). The error is swallowed
by the surrounding `xpcall`, so the hook silently never ran and the user got "Error while calling
hook" spam instead. Now `unpack(callDetail, 1, 4)`.

`Stubby/Stubby.lua:478` — `unhookFrom` was broken three ways at once. It compared the global
against `origFuncs[...]`, but after `hookInto` the global holds the *wrapper*, so the condition was
always false and the function always returned error 3. Inside that dead branch it rebound the
string name to the function object and then used it as a table key, clearing entries that do not
exist. And it never restored the global, so even a corrected guard would have left the wrapper
installed. All three are fixed together.

**What was deliberately not changed.**

Guards for `DataStore` being absent were rejected, as in the previous pass: every module declares a
hard `## Dependencies: DataStore` plus a redundant `if not DataStore then return end` on line 1.

`DataStore_Containers.lua:512` computes a container cooldown as `duration - (GetTime() - startTime)`
from a `startTime` persisted to SavedVariables. `GetTime()` is session uptime, so after any relog
the stored value is from a different epoch and the remaining time is meaningless. Fixing it properly
means storing `time()` alongside and migrating the database; it is recorded rather than half-fixed,
the same call as `Altoholic/Profiler.lua:48` in the previous pass.

`DataStore_Options.lua:161` calls `collectgarbage()` with no argument — a full collection on every
`OnShow` of the panel. That is a visible hitch, not a defect, and was left.

`GetSpellInfo(spellID)` is fed unguarded into `format("%s")` in `DataStore_Pets`, `DataStore_Talents`
and four places in `DataStore_Crafts`. It is a real nil risk, but there is no sibling guard anywhere
in the family to copy and the id always comes from a link the caller already read, so it is recorded
rather than guessed at.

**One finding is held pending a real client.** `DataStore_Talents.lua:211` reads
`GetGlyphSocketInfo` as four return values. If WotLK returns five
(`enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename`) then `spell` and `icon` are off
by one and `enabled` may be a boolean the concatenation below would reject. This cannot be settled
without a real 3.3.5 `FrameXML` dump — same standing as the AllStats and `!Swatter` signature items
from the 2026-09-30 pass.

**`DataStore/Export/ExportToXML.lua` is not an addon file.** It is absent from `DataStore.toc` and
runs as a standalone desktop lua5.1 script via `go.bat`. Three nil-dereferences that abort an export
run were fixed anyway (`BottomLevels[bottom]`, `CompletionDates[index]:match(...)`), along with a
guild-bank tab exporter that computed an item name and then emitted the raw id while its twin eight
lines up emitted the name.

No tests were written: the `_dev` harness cannot execute these addons (see "What still needs a real
client"), and a DataStore scenario is the separate piece of work already listed under "What is left".

## What is left

1. **In-game testing.** Everything below.
2. Commit the Carbonite folders + fixes, the Bagnon_Config layout fix, the 2026-09-28 static pass
   (23 addon folders, the `check.js` improvements, the expanded `known.txt`) and the 2026-09-29 /
   2026-09-30 deep-audit fixes, plus the 2026-10-01 Stubby/DataStore pass (18 folders, the
   `check.js` template-children change and the expanded `known.txt`) — all untracked or modified.
3. Optional: runtime scenarios for the 2026-09-28 addons. Like Carbonite, they touch far more of
   the client API than the mock has (auction house, trade skill, calendar, DataStore), and the
   mock has no catch-all, so each new scenario is real work. Nothing in this suite has been
   *executed* here — only parsed and checked.
4. Optional: a Carbonite load scenario. Its file-level code and `NXInit` touch hundreds of
   APIs the mock does not have, and the mock deliberately has no catch-all. Expect real work.
5. Optional: the guild bank scenario in `smoke.lua` only covers 2 tabs; a 6-tab case with
   withdraw limits would be worth adding.

## What still needs a real client

The harness cannot see any of this. Do not treat these as verified:

- **Pixel layout.** The mock has no geometry engine — `GetWidth`/`GetHeight` return what was
  set, nothing is measured. The new layout maths is exercised for *errors*, not for *appearance*.
  The header row, footer, dividers and the resized close button all need eyes on them.
  The options-panel check works on declared widths (label wrap width, dropdown width + 50),
  not on measured text. It proves nothing is *placed* outside 413×428. It cannot prove that a
  translated label does not wrap onto a third line.
- **Carbonite at all.** Nothing in Carbonite has been executed by the harness, only parsed.
- **The whole 2026-09-28 suite.** Auctioneer, AtlasLoot, Altoholic, AckisRecipeList, !Swatter,
  AllStats and Baggins were parsed and statically checked, never executed. Their event flow,
  saved-variable handling, AH/trade-skill hooks and inter-addon `DataStore`/`Altoholic` handoffs
  are unverified. The static pass only proves the files load and reference real globals.
- **Stubby and the DataStore family.** Same situation. In particular: Stubby's hook installation
  and removal paths are now materially different code and nothing here can run them; the DataStore
  guild comm (`RegisterComm`, guild-bank and alt broadcasts) needs two real clients in one guild;
  and the `GetGlyphSocketInfo` return arity above needs a real client to settle.
- **Taint.** No secure frames or protected calls are used anywhere in this workspace
  (`InCombatLockdown` appears nowhere because nothing needs it), but taint is only observable
  in a real client.
- **Real guild bank.** Tab permissions, withdraw limits, and the
  `GuildBankFrame_LoadUI` interception that keeps Blizzard's UI from loading.
- **Real BankStack moves.** The mock models the true cursor/lock protocol
  (`PickupContainerItem` locks a slot rather than emptying it) and item conservation is asserted,
  but real sorting involves server round-trips and latency the mock does not have.
- **Other locales.** Only enUS strings were added; the cn/ru/tw files were not translated, so
  those clients fall back to English for the new strings. That is the intended behaviour, but
  it has not been seen running.

### Open assumption

`SetSize` is believed to exist in 3.3.5 — the bundled 2008–2011 LibDBIcon calls it — but this
has not been confirmed against a client. It does not matter for correctness here: all addon code
deliberately uses `SetWidth`/`SetHeight`, so the code is right either way. `SetSize` is *not*
in `check.js`'s retail-only list, because the bundled libraries use it and flagging them would
be noise -- the convention is enforced by review, not by the checker.
