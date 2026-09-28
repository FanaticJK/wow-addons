# Modernization Report

Six addons in `e:\laragon\www\wow`, all targeting **WotLK 3.3.5a** (`## Interface: 30300`):
`Bagnon`, `Bagnon_Config`, `Bagnon_Forever`, `Bagnon_GuildBank`, `Bagnon_Tooltips`, `BankStack`.

Per-addon detail and how to re-run the checks live in [MODERNIZATION_LOG.md](MODERNIZATION_LOG.md).
This report is the summary across all six.

**Verification status up front:** nothing here has been run in a real WoW client. Every claim below
is either *static analysis* or *mock-runtime verified*, and each section says which.
[Testing](#testing) and [Remaining Issues](#remaining-issues) spell out the boundary.

---

## Changed

47 files modified, 4 new addon files, 9 new harness files. No file was rewritten from scratch;
every module kept its original structure, public API and message names.

**New addon files**

| File | Purpose |
|---|---|
| `Bagnon/components/sortButton.lua` | Header sort/stack/compress button (BankStack-backed) |
| `Bagnon/components/slotCounter.lua` | Footer free-slot counter |
| `Bagnon_Config/widgets/button.lua` | Shared button widget |
| `Bagnon_Config/widgets/tooltip.lua` | Shared tooltip anchoring |

**Removed**: `Bagnon_GuildBank/localization.xml` — it referenced seven locale files that do not
exist in the addon (see [Bug Fixes](#bug-fixes)). The guild bank now reads the `Bagnon` AceLocale
table, where its strings already lived.

**Structural changes**

- `Bagnon/components/frame.lua` — layout engine rebuilt around `Bagnon.Style` constants instead of
  offsets hard-coded across ten `Place*` methods. Header row / middle / footer are now explicit,
  and `Place*` methods take their anchor position as an argument rather than chaining off each
  other. Six near-identical `*_ENABLE_UPDATE` handlers collapsed into one `LayoutForFrame`.
- `Bagnon_Config/panels/frameOptions.lua` — rewritten against the shared widgets.
- `Bagnon_Forever/db.lua` — version handling replaced (see [Data Migration](#data-migration)).
- `Bagnon_Tooltips/tooltips.lua` — counting separated from formatting and put behind a cache.

**Versions bumped**: Bagnon 2.12.6 → 2.13.0, Bagnon_Forever 1.1.2 → 1.2.0,
Bagnon_GuildBank 1.0.0 → 1.1.0, BankStack v17 → v17.1. Bagnon_Config carries no version.

**Not changed**: every slash command, every SavedVariables name, every message name, every
setting key, and the bundled libraries under `libs/` and `lib/`. No new dependencies.

## Bug Fixes

Ordered by severity. The first three destroy or silently corrupt user data.

1. **`Bagnon_Forever` wiped the entire offline cache on every login.** `LoadSettings` compared
   major versions and on a mismatch did `BagnonForeverDB = {version = cVersion}`. `cVersion` is a
   typo — no such global — so it stored `version = nil`, which guaranteed a mismatch next login
   and another wipe. The storage format never actually changed, so the version is now simply
   stamped forward and data is never discarded. *Found by static analysis (undefined global).*

2. **`Bagnon` corrupted its own settings during migration.** `SavedFrameSettings:UpgradeDB()`
   added keys to `hiddenBags` while iterating it with `pairs()`, in the `{[index]=bagID}` →
   `{[bagID]=true}` upgrade. Modifying a table's key set during traversal is undefined behaviour
   in Lua 5.1 and raises `invalid key to 'next'` outright in 5.3. Now collects, removes, then
   inserts. *Found by the migration scenario, which died on it.*

3. **`Bagnon_Config` overwrote the global `Bagnon` addon table.** The options hack panel was
   `CreateFrame('Frame', 'Bagnon', ...)`, which replaces `_G.Bagnon` with a frame the moment the
   config addon loads — breaking `Bindings.xml` (binding bodies execute in global scope) and
   anything else reading the global. Renamed to `BagnonOptionsCategory`; the Blizzard options tree
   nests by display name (`f.name` / `f.parent`), not the frame's global name, so the panel still
   appears in the right place. *Regression-tested: the smoke scenario asserts `_G.Bagnon == Bagnon`
   before and after `Bagnon_Config` loads.*

4. **`BankStack` did not recognise bank bags 8–11.** `is_bank_bag` tested
   `bagid <= NUM_BANKBAGSLOTS` (7) instead of `bagid <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS` (11).

5. **`BankStack`'s scanning tooltip silently stopped working.** A `GameTooltip` loses its owner
   when it hides — e.g. after scanning an empty slot — after which `Set*Item` does nothing at all
   and every subsequent soulbound/conjured check returns false. It is now re-owned and cleared
   before each scan.

6. **`BankStack`'s move timer never advanced.** The `OnUpdate` driver did `t = t + arg1`, using
   the `arg1` global removed from script handlers, instead of the `elapsed` argument.

7. **`Bagnon_Forever:GetItemCount(link, 'e', player)` never counted equipment.** It used the bag
   record's size — equipment has no bag record, so 0 — and started at slot 1, also missing ammo in
   slot 0. Now scans slots 0–19 for the `'e'` pseudo-bag.

8. **`BankStack` errored mid-sort on uncached items.** `GetItemInfo` returns nil until the client
   has the item cached; `prime_sort`, `default_sorter`, `ScanBags`, `DoMoves` and `is_partial` all
   did arithmetic or comparison on those nils. Each now has a neutral fallback, and `prime_sort`
   breaks name ties by slot so the comparator stays a strict weak ordering.

9. **`BankStack` could index a missing `bagcache['Normal']`** when sorting a group that began with
   a specialty bag. Always created now.

10. **`Bagnon:ResetFramePositions()` seeded the guild bank with inventory defaults** when
    `Bagnon_GuildBank` was not loaded, because touching the settings created them from the wrong
    defaults table. It now skips `guildbank` unless that addon is loaded.

11. **`Bagnon_GuildBank` could show its window twice for one visit.** `GUILDBANKFRAME_OPENED` fires
    from both the loader and the event; the show is now idempotent and close force-hides, so a
    stale show count cannot leave the window stuck open. It also no longer queries tab 0.

12. **Nil-safety** on `GetContainerNumSlots`, `GetInventoryItemCount`, `GetItemIcon` and
    `GetContainerItemLink` in `Bagnon_Forever`, all of which return nil for empty or unknown slots.

13. **`BankStack` config validators rejected valid input**: bag ids can be negative (`-1` is the
    bank) and the group validator refused them. Validators also returned `false` instead of an
    error string, so AceConfig showed nothing useful.

14. **`/bankstack` opened the Interface Options window without selecting the category** — on 3.3.x
    the first `InterfaceOptionsFrame_OpenToCategory` only opens the window, so it is called twice.

15. **`BankStack`'s `Compress` missed guild bank groups**, using a bank-only check instead of
    `check_for_banks`.

16. **`Bagnon_GuildBank` loaded an XML include list of seven files that do not exist.** The `.toc`
    loaded `localization.xml`, which included `localization\localization.lua` and six translations
    — none of which are in the addon, and none of which ever were. It had no locale table of its
    own; the XML was removed and it now uses `Bagnon`'s, where its strings already lived.

17. **`BankStack` tooltip matching treated localized strings as Lua patterns.** `string.match` on
    `ITEM_SOULBOUND` etc. breaks for any locale whose string contains pattern magic; switched to a
    plain `string.find`.

## UI Improvements

- **A single design system.** All spacing, sizing and colour now come from `Bagnon.Style`
  (`PADDING`, `GAP`, `MENU_BUTTON_SIZE`, `FOOTER_HEIGHT`, `MIN_FRAME_WIDTH`, `colors`), replacing
  offsets like `8`, `-4`, `24` and `156` scattered through the layout code. The window reads as
  three bands — header, item area, footer — with a header band texture and dividers marking them.
  The art direction is unchanged: same tooltip-border backdrop, same Blizzard textures, same
  Classic feel.
- **A real header row.** Menu buttons align left, sort and options align right, and the close
  button sits in the corner at a size that matches the toolbar buttons instead of the stock
  texture's smaller visual weight. The title and the search box both span the gap between them, so
  neither overlaps a button any more.
- **A real footer.** Slot counter left, broker plugin centre, money right, vertically centred on
  one baseline. The money frame's built-in right padding is compensated for, so its visible edge
  lines up with the frame edge.
- **Every option has a tooltip** (`L.Tip_*` strings), and options that do not apply to the current
  window are **disabled with a stated reason** rather than hidden or silently inert —
  "requires BankStack", "not available for this window".
- **Ownership tooltips are class-coloured** and gain a total line when more than one character
  holds the item. The tooltip is only re-shown when a line was actually added, so hovering an item
  nobody owns no longer causes a pointless resize.
- **Clear failure messages instead of silence.** Opening options with `Bagnon_Config` disabled now
  says so and names the addon; BankStack's config descriptions were rewritten from shorthand
  ("Talkativitinessism") into sentences, with explicit ordering.
- **Guild bank money frame** reworked into deposit / withdraw with a remaining-allowance tooltip;
  unavailable tabs are labelled rather than left blank.

## New Features

Deliberately few — three, each earning its place.

1. **Sort button** (`Bagnon/components/sortButton.lua`). Left click sorts, right click compresses
   stacks, shift-click moves stacks between bags and bank. Appears only when BankStack is loaded,
   and never for cached (offline) characters, where the actions would be meaningless. Clicking
   while BankStack is running aborts it. Off by default for the keyring and guild bank.
2. **Free slot counter** (`Bagnon/components/slotCounter.lua`). Counts general-purpose and
   specialty bags (keyring, quivers, soul and profession bags) separately, since specialty slots
   cannot hold most items. Turns orange when nearly full, red when full; the tooltip breaks down
   both groups.
3. **`Bagnon:ShowFrameOptions(frameID)`**. The options toggle and title right-click now open the
   options panel already on that window's settings, rather than the top of the tree.

Supporting: **`BagnonDB:GetPlayerClass(player)`**, backed by a new `class` field
`Bagnon_Forever` saves at login — this is what makes class-coloured ownership tooltips possible.

Both UI features are settings (`hasSortButton`, `hasSlotCounter`) with defaults per window,
plumbed through the full stack: `SavedFrameSettings` defaults → `FrameSettings` setter and message
→ `Frame` layout → a checkbox in `Bagnon_Config`.

## Performance

- **Ownership tooltips no longer recount on every frame.** `OnTooltipSetItem` fires several times
  a second while hovering, and each count scans every saved slot of every bag of the character.
  Previously the current character was recounted from scratch every time. Counts are now cached
  per player per item; other characters' saved data cannot change during a session, and the
  current character's cache is cleared on `BAG_UPDATE`, `PLAYERBANKSLOTS_CHANGED` and
  `UNIT_INVENTORY_CHANGED` for `player`.
- **`ItemFrame:GetSlotCounts` reuses one scratch table** instead of allocating a fresh bag-type
  map on every contents update.
- **Fewer message handlers.** Six `*_ENABLE_UPDATE` handlers that each did the same frame-id check
  and relayout became one registered under six names.
- **Existing throttles left alone.** `RequestContentsUpdate` already coalesced bag updates through
  a throttled updater, and the slot counter hangs off that same coalesced message rather than
  adding its own event registrations. Components still unregister all messages on hide, so a
  hidden window costs nothing.
- Nothing polls. No `OnUpdate` was added; BankStack's existing one is its move pump and only does
  work while a sort is running.

*Measured? No.* These are structural reductions in work per event, reasoned from the code. No
profiling was done — that needs a real client.

## Compatibility

- **3.3.5a only.** A static check across all 121 Lua files reports zero uses of `C_Container`,
  `C_Timer`, `C_Item`, `C_CVar`, `C_AddOns`, `C_GuildBank`, `SetShown`, `SetColorTexture`,
  `BackdropTemplateMixin`, `GetItemInfoInstant` or `securecallfunction`. Container access stays on
  `GetContainerItemInfo` / `GetContainerNumSlots`, backdrops on `SetBackdrop`, sizing on
  `SetWidth`/`SetHeight`.
- **Zero undefined globals** across all 121 files, against a curated baseline of real 3.3.5
  globals in `_dev/known.txt`. This is what caught the `cVersion` typo.
- **Every `.toc` and XML `<Script>`/`<Include>` entry resolves to a file that exists**, including
  after the guild bank's locale files were removed.
- **No new dependencies.** The bundled Ace3, LibStub, LibDataBroker-1.1, LibItemSearch-1.0 and
  LibDBIcon are untouched. BankStack remains an *optional* dependency of Bagnon — the sort button
  hides itself when it is absent, and the config checkbox disables itself with a reason.
- **Load order.** `Bagnon_GuildBank` is still load-on-demand with `RequiredDeps: Bagnon`, still
  loaded through Bagnon's `GuildBankFrame_LoadUI` interception. `Bagnon_Config` is still
  load-on-demand. BankStack is in Bagnon's `OptionalDeps`, so when present it loads first and the
  sort button sees it.
- **Combat / taint.** Nothing in this workspace creates a secure frame, sets a secure attribute or
  calls a protected function — the item buttons are plain `Button`s on Blizzard's container
  template. There is therefore no combat lockdown to guard, which is why `InCombatLockdown` appears
  nowhere. *This is a code-reading conclusion; taint is only observable in a real client.*
- **Localization preserved.** The AceLocale structure is untouched. New strings went into the enUS
  files only; cn/ru/tw fall back to English by design. Guild bank strings were consolidated into
  the `Bagnon` locale, where they already were.

## Data Migration

No SavedVariables were renamed, removed or repurposed. `BagnonGlobalSettings`,
`BagnonFrameSettings` and `BagnonForeverDB` keep their names, shapes and keys.

**Repair.** `SavedSettings:ValidateDB` and `SavedFrameSettings:ValidateDB` check each stored value
and replace only what is provably broken: anchor points against a valid-point set, frame layers
against a valid-layer set, scale clamped to 0.25–3, opacity to 0–1, column counts floored to an
integer, colours checked component by component, `itemBorderStyle` against its enum. A frame entry
that is not a table at all is replaced; a frame entry that is a table is repaired **in place**, so
nothing else holding a reference to it goes stale.

**Migration.** The pre-2.6.3 `autoDisplayEvents` array part is cleared while its keyed part — a
real user choice — is kept. `hiddenBags` migrates from `{[index]=bagID}` to `{[bagID]=true}`.
Migrations are idempotent: running them twice produces the same result, which the round-trip in
the migration scenario asserts.

**Preservation.** Unknown keys are never discarded — an older or newer build, or a sibling addon,
may still need them. Deliberate user choices that merely differ from the default are kept. A
well-formed value the current version does not recognise (an unknown slot-colour type) is left
alone: the addon repairs what it knows is broken and does not discard what it merely does not know.

**Logout.** Values equal to their default are stripped at `PLAYER_LOGOUT` so the saved file stays
small and users pick up improved defaults later. The effective values are unchanged across the
round trip, which the scenario asserts by snapshotting before logout and re-reading after.

**Total loss.** If the saved file is unreadable — the top-level variable is a string, a number or
`false` — the database is rebuilt from defaults and the user is told
("Saved settings were unreadable and have been reset to defaults") rather than left to wonder.

**Nothing was wiped.** The one place that *did* wipe user data unconditionally —
`Bagnon_Forever`'s version check — was the bug that got fixed.

## Testing

**No in-game testing was performed.** There is no WoW client in this environment. What follows is
exactly what was run.

### Static analysis — `node _dev/check.js`

Walks each addon's `.toc` into its XML include lists, parses every file with `luaparse` as Lua 5.1,
and reports missing files, syntax errors, retail-only APIs and undefined globals.

```
addons: Bagnon, Bagnon_Config, Bagnon_Forever, Bagnon_GuildBank, Bagnon_Tooltips, BankStack
lua files parsed: 121
errors=0 warnings=0 unknown-globals=0
```

All three counts now fail the gate, not just syntax errors — verified by injecting a typo'd global
and confirming a non-zero exit, then removing it.

### Mock-runtime verification — `node _dev/run.js <scenario>`

The real addon folders are loaded into a Lua VM (fengari) on top of a hand-written 3.3.5 client
mock, in `.toc` order, each chunk called with `(addonName, addonPrivateTable)` as the client does.
**The mock has no catch-all**: any API an addon touches that is not modelled raises an error,
because a silent stub would hide exactly the bugs the harness exists to find.

| Scenario | Covers | Result |
|---|---|---|
| `smoke.lua` | Fresh install. All six addons load; inventory/bank/keyring open and close; search; bag slot show/hide; player switch to a cached character; options panels; sort button with item conservation asserted across 200 update ticks; guild bank open/close; `_G.Bagnon` integrity; logout | **98 checks, 0 failures** |
| `migrate.lua` + `sv_legacy.lua` | A 2.6.0 database with corrupted, legacy and deliberate values mixed on purpose, plus a stale offline character; then a full logout / reload round trip | **50 checks, 0 failures** |
| `garbage.lua` + `sv_garbage.lua` | Top-level SavedVariables that are a string, a number and `false` | **7 checks, 0 failures** |

`node _dev/all.js` runs all four gates and prints one summary. Current state: **4 of 4 pass.**

### What that does and does not establish

*Established:* the addons load in the right order with no errors; the code paths those 155 checks
touch execute correctly; SavedVariables repair, migration, preservation and round-tripping behave
as described; sorting conserves items; the global-clobber and `hiddenBags` bugs stay fixed.

*Not established:* anything visual, anything about taint, anything involving server latency, and
any code path the scenarios do not reach.

### Honest note on method

Several harness findings turned out to be mock infidelity rather than addon bugs — a
`format('%d', float)` that Lua 5.3 rejects and WoW's 5.1 accepts; a missing `bit` library;
`PickupContainerItem` modelled as emptying a slot when the real client *locks* it. In each case the
mock was corrected rather than the addon, and each fix carries a comment in `_dev/wowmock.lua` or
`_dev/wowapi.lua` saying which it was and why. Only one harness finding was a genuine addon
defect: the `hiddenBags` mutation-during-iteration bug.

## Remaining Issues

**Requires a real client — do not treat as verified**

1. **Pixel layout.** The mock has no geometry engine; `GetWidth`/`GetHeight` return what was set
   and nothing is measured. The new layout maths was exercised for *errors*, never for
   *appearance*. The header row, footer alignment, dividers and the resized close button all need
   eyes on them, at several scales and column counts.
2. **Taint.** The code-reading conclusion is that there is none to have. Only a client can confirm.
3. **Real guild bank.** Tab permissions, withdraw limits, and the `GuildBankFrame_LoadUI`
   interception that keeps `Blizzard_GuildBankUI` from loading.
4. **Real BankStack moves.** The mock implements the true cursor/lock protocol and item
   conservation is asserted, but real sorting involves server round-trips and latency it does not
   have. The uncached-`GetItemInfo` fixes in particular deserve a test on a fresh client cache.
5. **Performance.** The reductions are structural, not measured.

**Known limitations, accepted**

6. **Only enUS strings were added.** The cn/ru/tw locale files were not translated, so those
   clients fall back to English for the new strings. That is the intended AceLocale behaviour and
   matches how the addons already handled partial locales, but it is a visible gap for those users.
7. **`SetSize` on 3.3.5 — unresolved.** The bundled 2008–2011 LibDBIcon calls it, which suggests it
   exists, but this was not confirmed against a client. It does not affect correctness: all addon
   code deliberately uses `SetWidth`/`SetHeight`. `SetSize` is deliberately *not* in `check.js`'s
   retail-only list, because flagging the bundled libraries would be noise.
8. **Guild bank scenario coverage is thin.** The mock guild bank has 2 tabs and no withdraw limits;
   a 6-tab case with limits would be worth adding to `smoke.lua`.
9. **Pre-existing dead code left in place.** `IsBankSlot`, `HasBag`, `UnregisterItemEvent`,
   `GetHiddenBags`, `EnableSearch` and `SplitStack` were already unreferenced upstream. They are
   part of these classes' public surface and removing them is not what this pass was for, so they
   stay. (Two functions this refactor itself orphaned — `GetRightmostHeaderAnchor` and
   `GetMenuButtons` — were removed.)
10. **The work is uncommitted.** Everything sits in the working tree on top of the single
    `initial commit`, which is what makes `git diff` show the complete change set. It should be
    committed once it has been tried in game.
