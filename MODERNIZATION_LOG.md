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

Status values: `Pending` → `In progress` → `Done (needs in-game test)` → `Verified in game`.

**Nothing here has been run in a real WoW client.** "Done" means: clean static analysis
plus a clean pass through the scripted runtime harness in `_dev/`. See
[What still needs a real client](#what-still-needs-a-real-client).

## Where things stand

Last worked on: **2026-09-28**.

- All six Bagnon-family addons have had the full pass. No addon is half-finished.
- The four Carbonite folders had a **static-only** pass (see [Carbonite](#carbonite--334)):
  the runtime harness does not load Carbonite, so none of its code has been executed here.
- **2026-09-28: 23 more addons added and given a static-only pass** (Auctioneer suite, AtlasLoot
  family, Altoholic family, AckisRecipeList family, !Swatter, AllStats, Baggins). Same as
  Carbonite: `check.js`/`run.js` load and parse them, but no runtime scenario drives them, so
  their code has not been *executed* here. Real bugs found were fixed; see
  [Per-addon details](#per-addon-details) and the checker notes below.
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
| `node check.js` | Every `.toc`/XML entry resolves; every `## Interface` is 30300; every Lua file parses as 5.1; no retail-only API; no undefined globals; no bogus string escapes | 501 files, 0 errors, 0 unknown globals |
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

`known.txt` gained a dated 2026-09-28 section: real 3.3.5 API/FrameXML frames and GlobalStrings,
the addons' own UI objects named via Lua string concatenation, and the third-party addons this
suite optionally integrates with (`DataStore*`, `Altoholic`, `AtlasLoot`, `AceLibrary`, `FuBar`,
`Skillet`, `TipTac`, `BeanCounter`, `Enchantrix`, `Stubby`, `BugGrabber`, …). Everything was
reviewed by category before being added, not appended blindly.

## What is left

1. **In-game testing.** Everything below.
2. Commit the Carbonite folders + fixes, the Bagnon_Config layout fix, and the whole 2026-09-28
   pass (23 addon folders, the `check.js` improvements, the expanded `known.txt`) — all untracked
   or modified since `e1d8651`.
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
