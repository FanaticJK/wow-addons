# Addon Tracker — Resume File

**Target client:** WoW Classic WotLK **3.3.5a** (`## Interface: 30300`) — Lua 5.1.
**Purpose:** single place to resume the modernize/stabilize/optimize work across sessions.
**Companion files:** [MODERNIZATION_LOG.md](MODERNIZATION_LOG.md) (per-addon detail of what was fixed), [MODERNIZATION_REPORT.md](MODERNIZATION_REPORT.md) (cross-addon summary), [_dev/](_dev/) (static + runtime verification harness).

> **Resuming?** Read [How to resume](#how-to-resume) then jump to [Work queue](#work-queue).
> Do NOT rewrite working addons. Do NOT introduce Retail APIs. Preserve SavedVariables.

---

## How to resume

```
cd _dev
npm install        # once, if node_modules missing (gitignored)
node all.js        # full gate: static check + 3 runtime scenarios
node all.js -v     # verbose
```

Gate must stay green before and after any change. Current baseline: **4/4 green**
(737 lua files parse, 0 errors, 0 unknown globals; smoke 154, migrate 50, garbage 7 — all 0 failures).

**Status legend**
- `Done` — full pass (restructure + fixes) AND driven by a runtime scenario in `_dev`.
- `Static-only` — parsed + statically checked + real checker bugs fixed, but code **never executed** here. Logic/event/perf still unverified.
- `Deep-audit pending` — a manual logic/event/perf audit is queued or in progress.
- `Needs in-game` — everything; no real WoW client is available in this environment.

---

## Environment gaps (important)

- **No WoW client here.** Nothing is verified in-game. Pixel layout, taint, real AH/tradeskill/guild-bank flow all unverified.
- **Missing dependencies present as hard `## Dependencies`** — these addons will NOT load until the dep folders are added:
  - `Altoholic` + `Altoholic_Achievements` need the entire **DataStore** family (`DataStore`, `DataStore_Achievements`, `_Auctions`, `_Characters`, `_Containers`, `_Crafts`, `_Currencies`, `_Inventory`, `_Mails`, `_Pets`, `_Quests`, `_Reputations`, `_Skills`, `_Spells`, `_Stats`, `_Talents`). **None present.**
  - `Auc-Advanced` needs **Stubby**. **Not present.**
- **Auction ecosystem incomplete** vs the plan: `Enchantrix`, `Enchantrix-Barker` and `Informant` are **not present**. `Stubby` was added 2026-10-01 and `BeanCounter` 2026-10-02, so Auc-Advanced's hard dependency now resolves and BeanCounter's own `## Dependencies: Stubby` is satisfied.
- **Priority-list addons not in this workspace at all:** EveryQuest, ZygorGuidesViewer, TomTomLite, GatherMate, SilverDragon, GearScore, Grid2, PowerAuras, Quartz, Recount, Postal, Prat-3.0, Titan, SCT, SellJunk, Overachiever, BonusScanner, MobInfo2. (`BankStack` and, since 2026-10-02, `Bartender4` are present.) Phases 4/5/8/9/10/11 in the master plan cannot start until those folders exist.

---

## Addon inventory & status

35 addon folders. Grouped by ecosystem.

### Bagnon family — bags/bank (author: Tuller) — **Done**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Bagnon | 2.13.0 | BagnonGlobalSettings / BagnonFrameSettings(char) | Done | Core window. Layout engine rewritten, slot counter, sort button, options integration. Runtime-tested. |
| Bagnon_Config | — | — | Done | LoD options. Fixed `_G.Bagnon` clobber; options panels resized to fit 3.3.5 648x520 window. |
| Bagnon_Forever | 1.2.0 | BagnonForeverDB | Done | Offline cache. Fixed every-login wipe (`cVersion` typo); saves class; equipment count fix. |
| Bagnon_GuildBank | 1.1.0 | — (req Bagnon) | Done | Fixed 7 missing locale-file refs; deposit/withdraw rework. |
| Bagnon_Tooltips | — | — (req Bagnon_Forever) | Done | Per-player/item count cache; class-colored owners. |

### Carbonite family — map/quest/guide (author: Carbon Based Creations) — **Static-only**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Carbonite | 3.34 | NxData, NxCombatOpts, NxMapOpts / NxCData(char) | Static-only | **Minified 26k-line file.** Fixed: HoR map path escape, slider backdrop escape, `SSDC`→`SetSelectedDisplayChannel`, BGM nil msg, `QUEST_MAP_POI` guard, never-assigned global reads. Version NOT bumped (broadcasts to peers). Edit only with exact-match scripts (CRLF+latin1, long lines). Perf (many OnUpdate, crbb* channels) not addressed. |
| CarboniteItems | 1.00 | — | Static-only | LoD item data. Clean, no changes. |
| CarboniteNodes | 1.00 | — | Static-only | LoD gather nodes. Clean, no changes. |
| CarboniteTransfer | 1.01 | CarboniteTransferData | Static-only | Warehouse transfer stub. Clean. |

### Auctioneer suite — auction (author: Norganna) — **Static-only / Deep-audit pending**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Auc-Advanced | 5.8.4723 | AucAdvancedConfig, AucAdvancedData / AucAdvancedLocal(char) | Static-only + audit pending | Core. **Stubby added 2026-10-01.** Fixed `UiParent`→`UIParent`, `\n` mangles in elGR/zhTW help. |
| Auc-Filter-Basic | 5.8.4723 | AucAdvancedFilterBasic(+_IgnoreList) | Static-only + partly audited | Filter module. One fix: the ignore-list popup called the removed `ChatFrameEditBox` on close. Not part of a full Auctioneer audit. |
| Auc-ScanData | 5.8.4723 | AucScanData | Static-only + audit pending | LoD scan cache. |
| Auc-Stat-Histogram | 5.8.4723 | AucAdvancedStatHistogramData(+Total) | Static-only + audit pending | Stat module. |
| Auc-Stat-iLevel | 5.8.4723 | AucAdvancedStat_iLevelData | Static-only + audit pending | Stat module. |
| Auc-Stat-Purchased | 5.8.4723 | AucAdvancedStatPurchasedData | Static-only + audit pending | Stat module. |
| Auc-Stat-Simple | 5.8.4723 | AucAdvancedStatSimpleData | Static-only + audit pending | Stat module. |
| Auc-Stat-StdDev | 5.8.4723 | AucAdvancedStatStdDevData | Static-only + audit pending | Stat module. |
| Auc-Util-FixAH | 5.8.4723 | — | Static-only + audit pending | AH paging workaround. |

### AtlasLoot family — loot browser (author: Hegarol) — **Static-only / Deep-audit DONE**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| AtlasLoot | v5.11.04 | AtlasLootOptions, AtlasLootDB, AtlasLootWishList / AtlasLootCharDB, AtlasLootFilterDB(char) | Static-only + audited | Core. `break;` false positives cleared in checker. Deep audit done — 6 bugs fixed incl. a client-hanging spin loop in `AtlasLoot_QueryLootPage`, see [Deep-audit findings](#deep-audit-findings). Phase 6 UI-modernize + lazy-load not started. |
| AtlasLootFu | v5.11.04 | AtlasLootFuDB | Static-only + audited | FuBar minimap front-end (Ace2/FuBar-2.0). 57-line plugin; all 7 embedded libs load before it in `embeds.xml`, and both globals it calls (`AtlasLootOptions_Toggle`, `AtlasLootDefaultFrame`) come from its hard dep. No defects found, no changes. |
| AtlasLoot_BurningCrusade | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_Crafting | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_OriginalWoW | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_WorldEvents | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_WrathoftheLichKing | v5.11.04 | — | Static-only | LoD loot data table. |

### Altoholic family — alt manager (author: Thaoky) — **Static-only + audited**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Altoholic | 3.3.002b | AltoholicDB | Static-only + audited | DataStore front-end. **DataStore family added 2026-10-01**, so its hard `## Dependencies` chain resolves for the first time. Deep audit done — 16 bugs fixed, incl. the `Characters.lua` sort comparator that passed the global `self` (nil) into `DataStore[func]`, and two handlers that filtered on the removed `arg1` global and so never ran. |
| Altoholic_Achievements | 3.3.002 | — | Static-only + audited | Achievements UI module. One nil-concat fix. |

### AckisRecipeList family — recipe scanner (author: Ackis/Torhal) — **Static-only + audited**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| AckisRecipeList | 1.0-2817 | ARLDB2 | Static-only + audited | Recipe scanner (all tradeskills incl. Runeforging). Fixed `%a+\:`→`%a+:`. Deep audit done — 8 bugs fixed, incl. a spellbook walk that stopped at 25 entries and two dead `ChatFrameEditBox` branches. Large recipe data files. |
| AckisRecipeList_QuickScan | 3.3.5-1.0.1 | — (dep ARL) | Static-only + audited | LDB quick-menu companion. Same 25-entry spellbook walk fixed, plus a `GetTradeSkillLine()` nil-level guard. |

### Standalone — **Static-only + audited**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Baggins | r435 | BagginsDB | Static-only + audited | Virtual-bag inventory (Ace2/Ace3/Waterfall/Dewdrop). Fixed `## Interface` 30200→30300. Deep audit done — 9 bugs fixed, incl. three undeclared globals in the filter engine and a missing default-skin fallback that left the bags undrawn. |
| BankStack | v17.1 | BankStackDB | Done | Sort/stack. Fixed bank-bag range 8–11, OnUpdate `arg1`→`elapsed`, tooltip re-owning, nil-safety. Runtime-tested (used by Bagnon sort button). |
| Stubby | 5.8.4723 | StubbyConfig | Static-only + audited | Auctioneer boot/hook library (hard dep of Auc-Advanced). Deep audit done — 4 bugs fixed, incl. an `unpack` over a table with a hole that made every negative-position hook silently fail, and an `unhookFrom` that could never succeed. |
| Bartender4 | 4.4.2 | Bartender4DB | Static-only + audited | Action bars (Ace3 + LibKeyBound + LibWindow + LibDBIcon). Added 2026-10-02. Deep audit done — 12 bugs fixed, incl. a `rangeTimer` that was never armed (both out-of-range modes dead for every user) and an operator-precedence slip that rebuilt secure stance buttons in combat. **The only addon here that touches secure frames.** |
| BeanCounter | 5.8.4723 | BeanCounterDB, BeanCounterAccountDB | Static-only + audited | Auction-house transaction history (Auctioneer suite; hard dep on Stubby). Added 2026-10-02. Deep audit done — 24 bugs fixed, incl. three loops that removed from the table they iterated with `pairs`, a doubled-suffix database key that hid every neutral-AH buyout from maintenance, and a `debugPrint` that errored on a nil global on every call. |

### DataStore family — character data library (author: Thaoky) — **Static-only + audited**

Added 2026-10-01. All 17 `.toc` files already declared `## Interface: 30300` and
`## DefaultState: disabled` (the author's opt-in packaging, left as-is); every module except the
core declares `## Dependencies: DataStore`. Deep audit done — 32 bugs fixed across 13 folders, see
[Deep-audit findings](#deep-audit-findings).

| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| DataStore | 3.3.001 | DataStoreDB | Static-only + audited | Module registry, guild comm, character/guild key mapping. 2 bugs fixed. |
| DataStore_Achievements | 3.3.001 | DataStore_AchievementsDB | Static-only + audited | 4 fixed, incl. the `\[` escape the static gate caught. |
| DataStore_Auctions | 3.3.001 | DataStore_AuctionsDB | Static-only + audited | 1 fixed (`OnDisable` event leak). |
| DataStore_Characters | 3.3.001 | DataStore_CharactersDB | Static-only + audited | 3 fixed, incl. a NaN XP rate at max level. |
| DataStore_Containers | 3.3.001 | DataStore_ContainersDB | Static-only + audited | 4 fixed, all nil-guards around `GetThisGuild()`. |
| DataStore_Crafts | 3.3.002 | DataStore_CraftsDB | Static-only + audited | 3 fixed, all first-`TRADE_SKILL_SHOW` nil cases. |
| DataStore_Currencies | 3.3.001 | DataStore_CurrenciesDB | Static-only + audited | 3 fixed, incl. a re-entrant scan. |
| DataStore_Inventory | 3.3.002 | DataStore_InventoryDB | Static-only + audited | 5 fixed, incl. the NaN that corrupts its own SavedVariables file. |
| DataStore_Mails | 3.3.001 | DataStore_MailsDB | Static-only + audited | 1 fixed (nil sender in the `ReturnInboxItem` hook). |
| DataStore_Pets | 3.3.001 | DataStore_PetsDB | Static-only + audited | 2 fixed (sparse list, `OnDisable` leak). |
| DataStore_Quests | 3.3.001 | DataStore_QuestsDB | Static-only + audited | 4 fixed, incl. reward `isUsable` always reading false. |
| DataStore_Reputations | 3.3.001 | DataStore_ReputationsDB | Static-only + audited | No defects found, no changes. |
| DataStore_Skills | 3.3.002 | DataStore_SkillsDB | Static-only + audited | 1 fixed (shadowed `self` in the chat handler). |
| DataStore_Spells | 3.3.001 | DataStore_SpellsDB | Static-only + audited | 1 fixed (stale-index nil guard). |
| DataStore_Stats | 3.3.001 | DataStore_StatsDB | Static-only + audited | 2 fixed (leaked `_`, unfiltered `UNIT_INVENTORY_CHANGED`). |
| DataStore_Talents | 3.3.001 | DataStore_TalentsDB | Static-only + audited | 6 fixed — the worst folder in the family. One return-arity claim held pending a client. |
| AllStats | 1.1 | — | Static-only + audited | Paperdoll stats panel. No changes. One `PaperDollFrame_Set*` signature claim held pending a client — see [Needs a client](#needs-a-client). |
| !Swatter | 5.8.4723 | SwatterData | Static-only + audited | Error catcher (Auctioneer lib). Fixed realm-suffix gsub `\.`→`%.` and a stale-error-id check. One `UIParent_OnEvent` signature claim held pending a client. |

---

## Work queue

Ordered by value, given no in-game client.

### In progress
- **Deep audit of the 23 static-only addons** (logic/event/perf bugs the checker can't catch).
  Ran as 4 parallel audits: (1) Auctioneer suite — **cancelled before it reported, still un-audited**, (2) ~~AtlasLoot family~~ **done, 6 fixed**, (3) ~~Altoholic~~ **done, 17 fixed**, (4) ~~AckisRecipeList+Baggins+AllStats+!Swatter~~ **done, 20 fixed** (plus 1 in Auc-Filter-Basic).
  Findings + fixes are appended to [Deep-audit findings](#deep-audit-findings) below and to MODERNIZATION_LOG.md.
  Every finding is re-read against the source in the main thread before any fix is applied — audit reports are leads, not authority.
- **Deep audit of Stubby + the 17 DataStore folders** — **done 2026-10-01, 36 bugs fixed.** Ran as 4 parallel audits: (1) DataStore core + Stubby, (2) Achievements/Auctions/Characters/Containers, (3) Crafts/Currencies/Inventory/Mails, (4) Pets/Quests/Reputations/Skills/Spells/Stats/Talents. Scoped to addon logic only — pure data/locale/SavedVariables files were excluded on the user's instruction. Gate 4/4 green afterwards (624 Lua files).
- **Deep audit of Bartender4 + BeanCounter** — **done 2026-10-02, 36 bugs fixed** (12 in Bartender4, 24 in BeanCounter). Both folders were added this session. Audited in the main thread against the source, no agents. Bartender4 is the first addon here that drives secure frames, state drivers and override bindings, so its findings are the ones most exposed to taint; BeanCounter closes the Auctioneer dependency chain alongside Stubby. Gate 4/4 green afterwards (737 Lua files).

### Queued (actionable without a client)
1. ~~Apply + verify confirmed high/med bugs from the deep audit; re-run `node all.js`~~ — **done for every audited addon**, gate 4/4 green. Remaining: the Auctioneer suite, and the two findings under [Needs a client](#needs-a-client).
2. **AtlasLoot Phase 6** — UI modernize. ~~Confirm data modules load lazily (LoD), not at startup~~ — **verified correct, no change needed**: all 5 data modules carry `## LoadOnDemand: 1`, and the one startup path that would force them in (`AtlasLoot.lua:361`) is behind the `LoadAllLoDStartup` profile option, which defaults to `false` (`AtlasLoot.lua:109`). The other `AtlasLoot_LoadAllModules()` calls are user-initiated (search across all modules, browser buttons) or a one-time wishlist migration for pre-4.03.01 SavedVariables.
3. **Auctioneer Phase 7** — scan stability, duplicate-scan prevention, caching, error recovery, respect AH throttle. Stubby is now present and audited, so the boot-stub path is live rather than missing.
4. Optional runtime scenarios in `_dev` to actually *execute* the static-only addons (auction/tradeskill/DataStore mocks — real work, no catch-all in mock by design).
5. ~~Guard Altoholic against absent DataStore~~ — **moot**: the DataStore family was added 2026-10-01, so Altoholic's hard dependency chain resolves. No guards needed (and they were rejected on the same grounds in the Altoholic audit).

### Blocked (need folders added to workspace)
- Phase 4 leveling integration (Carbonite + EveryQuest + Zygor + TomTom): EveryQuest/Zygor/TomTom absent.
- Phase 5 EveryQuest improvements: absent.
- Phase 8 Postal: absent.
- Phases 9–11 dungeon/raid (GearScore, Grid2, PowerAuras, Quartz, Recount): all absent.
- Complete auction suite (Enchantrix, Enchantrix-Barker, Informant): absent. **Stubby added 2026-10-01, BeanCounter added 2026-10-02.**

### Always-outstanding
- **In-game testing** of everything (see MODERNIZATION_LOG "What still needs a real client").
- Keep the `_dev` gate green.

---

## Deep-audit findings

> Populated as the 4 audit agents report. Each entry: `addon file:line | severity | problem | fix | state(confirmed/fixed/rejected)`.

### AtlasLoot — audit complete, 6 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `Core/AtlasLoot.lua:1400` | **high** | `AtlasLoot_QueryLootPage` spaced its item queries with `while i<31 do ... if GetTime() - querytime > 0.03`. `GetTime()` returns the current frame's timestamp and does **not** advance inside a single script execution, so the condition is never true after the first pass, `i` never increments, and the loop spins forever — hanging the client whenever the "query loot page" button is pressed. | Replaced the wait loop with a dedicated hidden frame driven by `OnUpdate(self, elapsed)`, which accumulates real elapsed time and queries one item per 0.03 s, then hides itself after item 30. Same pacing, same query call, no hang. Also removed the stray globals `i`, `button`, `queryitem`. | Fixed |
| `Core/LootButtons.lua:173` | medium | `AtlasLootTooltip:SetHyperlink(AtlasLoot_GetEnchantLink(spellID))` — `AtlasLoot_GetEnchantLink` returns nil when the enchant scan-tooltip line has no `:` **and** `GetSpellLink(enchantID)` is also nil, and `SetHyperlink(nil)` raises a Lua error on mouseover of such a spell/enchant row. | Capture the link into a local and only call `SetHyperlink` when it is non-nil; the tooltip still `:Show()`s (empty) as before. | Fixed |
| `Core/LootButtons.lua:200` | medium | `if ( ShoppingTooltip2:IsVisible() or ShoppingTooltip1.IsVisible)` — the second operand is a *method reference*, not a call, so it is always truthy. The compare tooltips were therefore hidden on every `OnLeave` regardless of state. | `ShoppingTooltip1.IsVisible` → `ShoppingTooltip1:IsVisible()`. | Fixed |
| `Core/AtlasLoot.lua:636` | low | `AtlasLoot_TableNames[dataID][2] == "Menu"` indexes the registry without checking the `dataID` is registered; an unregistered `dataID` errors here. The sibling code in `Core/Search.lua` already guards this exact lookup, which is what a registered-vs-unregistered `dataID` can be. | Added the `AtlasLoot_TableNames[dataID] and` guard, matching the existing Search.lua pattern. | Fixed |
| `Core/LootButtons.lua:242` | medium | The shift-click link insert tested `ChatFrameEditBox:IsVisible()`. `ChatFrameEditBox` was removed in 3.3.5 (confirmed by `Altoholic/Changelog-Altoholic-r90.txt:30`), so the branch was dead and shift-clicking a loot row never inserted the name into chat. | `ChatEdit_GetLastActiveWindow()` with a nil guard, then `:Insert(name)` on it. | Fixed |
| `Core/Search.lua:90` | low | Spell/enchant branch did `AtlasLoot_TableNames[dataID][1]` unguarded, while the item branch at line 70 already guarded the same lookup. | Added the `AtlasLoot_TableNames[dataID] and` guard so the spell branch falls back to `"Argh!"` like the item branch. | Fixed |

Gate re-run after each change: **4/4 green**. None of these are verifiable in-game here — see [Environment gaps](#environment-gaps-important).

### Altoholic + Altoholic_Achievements — audit complete, 17 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `Characters.lua:229` | **high** | `SortByFunction` called `DataStore[func](self, a.key)`. `self` is not a parameter of this local function, so it resolved to the *global* `self` — nil. Every DataStore accessor invoked through the column sort therefore ran with a nil `self` and errored, breaking sorting on every sortable character column. | Pass the real object: `DataStore[func](DataStore, a.key)`. | Fixed |
| `Frames/Pets.lua:292` | **high** | `function ns:OnChange()` was registered as an AceEvent handler and filtered with `if arg1 ~= "player"`. AceEvent-3.0 calls a plain function as `handler(event, ...)`, so the implicit `self` received the *event name* and `arg1` (the global removed in 3.3.5) was always nil — the filter never passed and pet data was never rescanned. | Declared `function ns.OnChange(event, unit)` and filtered on `unit ~= "player"`. | Fixed |
| `Altoholic.lua:278` | **high** | `OnChatMsgSystem(event, arg)` compared `tostring(arg1)` — the old pre-3.3.5 global, always nil — against `INSTANCE_SAVED`, so raid-lock detection never fired. | `tostring(arg)`, the parameter the function actually receives. | Fixed |
| `Frames/TabCharacters.lua:217` | medium | The profession loop indexed `DS:GetPrimaryProfessions(character)` without the nil check `Characters.lua:97-107` already uses, and had no upper bound although only `AltoholicTabCharacters_Prof1` and `_Prof2` exist — a third entry indexed a nil frame. | Hoisted the call into a local behind `if professions then`, and break once `i > 2`. | Fixed |
| `Altoholic.lua:719` | medium | `GOLD..zone` / `GOLD..subZone` in the character tooltip. `DataStore:GetLocation()` returns nil for a character never scanned in a zone, and `..` on nil errors. | `GOLD..(zone or "")`, `GOLD..(subZone or "")`. | Fixed |
| `Altoholic.lua:726` | medium | `format("%.1f", DS:GetAverageItemLevel(character))` errors when the accessor returns nil (character scanned before the iLevel module existed). | `... or 0`, matching the `or 0` idiom already used throughout `Characters.lua`. | Fixed |
| `Frames/AccountSummary.lua:41-43` | medium | `level + DS:GetCharacterLevel(...)`, `money + DS:GetMoney(...)`, `played + DS:GetPlayTime(...)` — arithmetic on a possibly-nil accessor result, which aborts the whole faction-totals row. | Wrapped each in `(… or 0)`; `Characters.lua:126-128` already does exactly this for the same three accessors. | Fixed |
| `Frames/GuildProfessions.lua:28-29, 79-80` | medium | Both level comparators did `select(4, DataStore:GetGuildMemberInfo(...))` and compared the results directly; a guild member not yet in the roster cache yields nil and `nil < nil` errors mid-`table.sort`. | `or 0` on both sides of both comparators. | Fixed |
| `Frames/GuildMembers.lua:84-85` | medium | Same defect in the secondary (alt) level sort; the primary sort in the same file already had the guard. | `or 0` on both sides. | Fixed |
| `Frames/Calendar.lua:482` | medium | `Altoholic.Calendar:Update()` used `CalendarFrame` without the load-on-demand guard its own `:Scan()` (line 944) already carries — Blizzard's Calendar is LoD, so the frame is nil until the player opens it once. | Added the same early return, with a comment pointing at `:Scan()`. | Fixed |
| `Frames/Skills.lua:342`, `Frames/Recipes.lua:462` | medium | `local link = profession.FullLink` with no nil check on `profession`; clicking a profession row for a character whose skill data was never scanned errors. | `profession and profession.FullLink`. | Fixed |
| `Frames/Talents.lua:611` | medium | `Button_OnEnter` fed a possibly-nil talent `link` into the tooltip. The sibling handler at line 435 already returns early on a nil link. | `if not link then return end`. | Fixed |
| `Frames/Containers.lua:151` | medium | `GameTooltip:SetHyperlink(link)` on a container slot whose item is not in the client cache passes nil and errors. | `if link then … end`. | Fixed |
| `Frames/Search.lua:859` | low | `string.find(strlower(name), …)` on a guild member name that can be nil; `CraftMatchFound` at line 588 already guards the same value. | `if name and string.find(…)`. | Fixed |
| `Frames/Mails.lua:182` | low | `if money > 0` on a mail entry with no attached money (nil, not 0). | `if money and money > 0`. | Fixed |
| `Loots.lua:1045` | low | `AddCurrentlyEquippedItem` scanned a nil `itemLink` when the item was not in the client cache. | Early `if not itemLink then return end`. | Fixed |
| `Altoholic_Achievements/Achievements.lua:384` | low | `WHITE .. achName` — `GetAchievementInfo` returns nil for an achievement id the client does not know, and `..` on nil errors during the list refresh. | `WHITE .. (achName or "")`. | Fixed |

**Rejected (5 findings).** The audit proposed guarding five call sites against `DataStore` being
absent. Altoholic declares DataStore as a hard `## Dependencies`, so the client will not load the
addon at all without it — those guards would be error handling for a state that cannot occur.

**Deferred.** `Profiler.lua:48` computes `p.duration = GetTime() - p.startTime`, and `GetTime()`
does not advance within a single script execution, so every profiled duration is `0`. The correct
call is `debugprofilestop()`, but that returns milliseconds where the code and `:Dump()` assume
seconds, so fixing it means auditing the display maths too. Developer-only tool, no user-facing
effect — left alone and recorded here instead.

### AckisRecipeList + AckisRecipeList_QuickScan — audit complete, 10 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `Player.lua:155`, `ARL.lua:1524` | **high** | The spellbook walk ran `for index = 1, 25` and broke on `index == 25`, so it stopped short of a full General tab and never examined entry 25 itself. A profession sitting low enough in the spellbook was never detected, and the player's specialty was silently cleared. | Walk `1, 1024` and break only on the first nil `GetSpellName`, which is the real end of the book. | Fixed |
| `AckisRecipeList_QuickScan/QuickScan.lua:170` | **high** | Identical `1, 25` walk in the LDB menu's profession detection. | Same fix. | Fixed |
| `Frame.lua:1113` | **high** | The reverse profession switch set `startLoop = NUM_PROFESSIONS + 1`, one past the end of `SortedProfessions`, so the first right-click from the "all professions" state indexed a nil entry. | `startLoop = NUM_PROFESSIONS`. | Fixed |
| `Frame.lua:1135` | **high** | `CastSpellByName(SortedProfessions[MainPanel.profession].name)` with no check that the index resolves; a player who knows none of the tracked professions leaves `MainPanel.profession` at 0 and this errors on every mode-button click. | Early return on `not SortedProfessions[MainPanel.profession]`. The audit's own suggestion (return when `displayProf == 0`) was rejected — it would also block the legitimate single-profession case, where re-casting the same profession is correct. | Fixed |
| `ARL.lua:1114` | **high** | `GameTooltip:SetOwner(UIParent, ANCHOR_NONE)` used a bare global that does not exist; the real argument is the *string* `"ANCHOR_NONE"`. Passing nil makes the quest tooltip keep whatever anchor was last set, and the scan then reads the wrong tooltip text. | `"ANCHOR_NONE"`. `_dev/known.txt` carried an `ANCHOR_NONE` entry that was masking this from the static gate; the entry was false and has been removed, and the gate still reports 0 unknown globals. | Fixed |
| `ARL.lua:1586` | medium | `strmatch(SpellLink, …)` and `RecipeList[tonumber(SpellString)]` with no nil check, and the else-branch then concatenated the nil `SpellString` into a `:Print`. `GetTradeSkillRecipeLink` returns nil for a row the server has not sent yet. | Guarded both, and only print the "missing from DB" line when a spell id was actually extracted. | Fixed |
| `Datamine.lua:1688` | medium | `strlower(_G["ARLDatamineTTTextLeft1"]:GetText())` — the scan tooltip is empty when the link is not in the client cache, so `GetText()` returns nil and `strlower` errors, aborting the datamine run. | Read the text into a local, then hide the tooltip and return when it is nil. | Fixed |
| `Frame.lua:2223` | medium | `if num_entries < display_lines then display_lines = num_entries / 2` — halving the visible-line count when the list is short makes `FauxScrollFrame_Update` hide half the remaining entries, and passes a fraction for an odd count. | `display_lines = num_entries`. | Fixed |
| `Frame.lua:3570, 3584` | medium | Both shift- and ctrl-click link inserts called `ChatFrameEditBox`, a global removed in 3.3.5 — the branch always errored instead of inserting the link. | `ChatEdit_GetLastActiveWindow()` with a nil guard, falling back to the addon's existing `L["NoItemLink"]` message. | Fixed |
| `QuickScan.lua:72` | low | `ARL_Scan` formatted `"%s: %d"` with the level from `GetTradeSkillLine()`, but the tradeskill window opens asynchronously and has no level to return on the first cast, so the format errored. | Guard on `prof_level`, falling back to the bare profession name. | Fixed |

### Baggins — audit complete, 9 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `Baggins-Skins.lua:57` | **high** | `EnableSkin` did `local newskin = self:GetSkin(name)` with no fallback. A saved profile naming a skin whose plugin is no longer loaded leaves `currentSkin` nil, and every later `SkinSection` / `SetBankVisual` call errors — the bags never draw. | Fall back to `self:GetSkin('default')`. | Fixed |
| `Baggins.lua:663` | **high** | The stacking loop tested `if entry then` before reading `entry.itemid`, while the four sibling loops (lines 449, 508, 547, 562) all test `if type(entry) == "table" then`. Layout entries can be non-table separators, and indexing one errors during a rebuild. | Brought line 663 in line with its four siblings. | Fixed |
| `Baggins-Filtering.lua:275` | **high** | `operation` was never declared, so `CheckCategory` wrote and read a *global*. Two bag frames filtering in the same frame, or a nested rule evaluation, clobber each other's operator and silently produce AND where OR was configured. | `local operation`. | Fixed |
| `Baggins-Filtering.lua:312` | **high** | Same defect for `used` in `OnSlotChanged` — a global holding either `bankuseditems` or the bag cache, leaking the bank's used-item set into a bag update. | `local used`. | Fixed |
| `Baggins-Filtering.lua:878` | medium | Same defect for `qualname` in the Quality rule's `GetName`. | `local qualname`. | Fixed |
| `Baggins-Filtering.lua:124` | medium | `RuleTypes[rule.type].CleanRule` — unguarded lookup of a rule type that may no longer be registered, e.g. a plugin removed since the profile was saved. `GetRuleDesc` at line 160 already guards the identical lookup. | Added the `RuleTypes[rule.type] and` guard. | Fixed |
| `Baggins.lua:2859` | medium | `count = count + v.itemcount or 0` parses as `(count + v.itemcount) or 0` — the `or 0` guards nothing and the addition still errors on a nil `itemcount`. | `count = count + (v.itemcount or 0)`. | Fixed |
| `Baggins.lua:2453, 2473` | low | `("|cFF%2X%2X00"):format(r*255, g*255)` — `%2X` pads with *spaces*, not zeroes, so any channel below 16 produced a colour code containing a space and the escape rendered as literal text in the bag title. | `%02X`. | Fixed |
| `Baggins.lua:1077` | low | `OptimizeSectionLayout` cleared `sectionframe.layout_area_index`, but the loop directly below writes and reads `sectionframe.layout_areaid` — the reset targeted a field that does not exist, so a stale area id survived into the next optimisation pass. | Clear `layout_areaid`. | Fixed |

**Deferred.** The same optimiser skips sections whose `layout_areaid` is nil rather than treating
them as area 0. Changing it is a plausible improvement, but the effect is purely visual and cannot
be checked without a client, so it was left as-is.

**Rejected.** A proposed `GetCenter()` nil guard at `Baggins.lua:1849` — the button is visible and
anchored by the time its click handler runs, so `GetCenter()` cannot return nil there.

### !Swatter — audit complete, 1 bug fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `Swatter.lua:136` | medium | `if (not ( id and #(SwatterData.errors) ~= 0))` — the author's own comment directly above says an `id` can survive a clear, so it has to be checked against the *current* error list. Testing the list's length instead accepts a stale id and the handler then indexes a missing entry. | `if (not ( id and SwatterData.errors[id] ))`. | Fixed |

### Auc-Filter-Basic — audit complete, 1 bug fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `BasicFilter.lua:284` | medium | The ignore-list popup's `OnHide` called `ChatFrameEditBox:IsShown()`. `ChatFrameEditBox` was removed in 3.3.5 (confirmed by `Altoholic/Changelog-Altoholic-r90.txt:30`), so closing the popup always threw a Lua error. | `local chat = ChatEdit_GetLastActiveWindow()` with a nil guard before `:IsShown()` / `:SetFocus()`. | Fixed |

### AllStats — no changes

One finding was raised and **held, not applied**: that `PaperDollFrame_SetStat` and its siblings
take `(statFrame, unit, statIndex)` on 3.3.5 rather than the signature AllStats uses. If the claim
is wrong, applying it breaks the whole panel, and it cannot be settled without a real client or a
copy of 3.3.5's `PaperDollFrame.lua`. See [Needs a client](#needs-a-client).

### Auctioneer suite — audit **not** performed

The Auctioneer audit was cancelled before it reported. The suite (`Auc-Advanced` and its `Auc-*`
modules, aside from the one `Auc-Filter-Basic` fix above) is un-audited beyond the static gate.
Phase 7 in the work queue still stands.

### Stubby — audit complete, 4 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `Stubby.lua:314` | **high** | `callRunner` did `unpack(callDetail)`. For a **negative-position** hook, `hookCall` writes `callDetail[3] = retVal` while `retVal` is still nil, leaving a hole at [3]; `#callDetail` is then 2, `unpack` yields two values, and `callParams` is nil, so the next line errors. Negative positions are what real callers use (`Auc-Advanced/CoreMain.lua:205` at -200, `Auc-Util-AskPrice/AskPrice.lua:74` at -200 on `ChatFrame_OnEvent`, `Auc-Util-SimpleAuction/SimpFrame.lua:1281` at -300). The surrounding `xpcall` swallows the error, so the hook silently never ran and the user got "Error while calling hook" spam. | `unpack(callDetail, 1, 4)`. | Fixed |
| `Stubby.lua:478` | **high** | `unhookFrom` was broken three ways: it compared the global against `origFuncs[...]` although after `hookInto` the global holds the *wrapper*, so the guard was always false and the function always returned error 3; inside that dead branch it rebound the string name to the function object and used it as a table key, clearing entries that do not exist; and it never restored the global. | Compare against `config.hooks.functions[triggerFunction]`, `setglobal` the original back, then clear both tables by their string key. | Fixed |
| `Stubby.lua:429` | medium | When the loadstring'd chunk bails out because the target is not a function, `hookInto` fell through, wrote `origFuncs[tf] = <non-function>` and **returned 0 = success**. `registerFunctionHook` then reported success for a hook that was never installed — exactly the case that arises when boot code names a function that does not exist on 3.3.5. | Check `type(Stubby_OldFunction) == "function"` after running the chunk and return error 5 otherwise. | Fixed |
| `Stubby.lua:545-567` | medium | `local insertPos = tonumber(position) or 200` normalised the slot, but `p = position` stored the **raw** value and the collision loop compared the raw `position`. With `position` nil (the file's own header documents it as defaulting) the comparison raises "attempt to compare nil with number", and `func.p` stays nil so `hookCall:340` (`func.p >= 0`) errors on *every* invocation of the hooked function. | Use `insertPos` in both `funcObj` constructors and in the loop comparison. | Fixed |
| `Stubby.lua:372` | low | `returns = true` — an undeclared global written on every `setreturn` and read nowhere in the file. | Deleted. | Fixed |

**Rejected.** `RunScript` at `:916` is a real 3.3.5 API (corroborated by a captured 3.3.5 stack trace
in `!Swatter/Swatter.lua:311`) and was added to `known.txt`. `StubbyConfig = {}` at file scope is
correct — SavedVariables are restored after the addon's Lua runs. `Stubby.xml`'s
`Stubby.Events(event, ...)` is already the 3.3.5 model. `getglobal` is deprecated but present in
3.3.5. The `pairs()` mutations at `:688`, `:736`, `:613` and `:831` only assign nil to an existing
field, which Lua 5.1 permits during traversal.

### DataStore family — audit complete, 32 bugs fixed across 13 folders

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `DataStore_Inventory.lua:165` | **high** | `averageItemLvl = totalItemLevel / itemCount` with `itemCount` 0 whenever only a shirt/tabard is equipped, or when every `GetInventoryItemLink` returns nil (which happens on `PLAYER_ALIVE` during a loading screen). `0/0` is NaN, and NaN written to SavedVariables makes the whole `DataStore_InventoryDB` file unparseable on the next login. | `(itemCount > 0) and (totalItemLevel / itemCount) or 0`, matching the file's own `or 0` idiom. | Fixed |
| `DataStore_Talents.lua:204` | **high** | `glyphID` declared once outside both loops and only reassigned inside `if link then`, so an empty socket kept the previous socket's id and the `glyphID or 0` below preserved it. Every empty socket after a filled one was stored as a duplicate of the last filled one. | Reset `glyphID = nil` at the top of each socket iteration. | Fixed |
| `DataStore_Talents.lua:161` | **high** | `prereqTier, prereqColumn = GetTalentPrereqs(...)` with no `local` — two leaked globals written for every talent of every tab on every `PLAYER_ALIVE`. | `local prereqTier, prereqColumn`. | Fixed |
| `DataStore_Talents.lua:277` | **high** | `_GetTreeInfo` guarded `if t then`, but `t` comes from an AceDB `['*']` default and is never nil — the guard was dead. `t.icon`/`t.background` *are* nil whenever the tab did not exist when the class reference was captured, and both are concatenated. | Guard the fields instead: `if t.icon and t.background then`. | Fixed |
| `DataStore_Talents.lua:106` | medium | `GetTalentTabInfo(tabNum, nil, nil, 2)` returns nil for a character without dual spec; `name .. "|" .. specNum` then errors, and `table.insert(points, nil)` is a no-op that mis-aligns `PointsSpent` so `_GetNumPointsSpent`'s `index + (specNum-1)*3` reads the wrong tree. | `table.insert(points, pointsSpent or 0)` to keep the fixed layout, and wrap the talent loop in `if name then`. | Fixed |
| `DataStore_Talents.lua:329, 287` | medium | `for treeName in _GetClassTrees(character.Class)` — `_GetClassTrees` returns **nil** when `ref.Order` is nil (the author's own TODO sits on that line), so the generic-for raises "attempt to call a nil value". `strsplit(",", character.PointsSpent)` is also nil for a sub-10 character. | Hoist the iterator into a local and early-return when it, or `PointsSpent`, is missing. Same at `_GetTreeNameByID`. | Fixed |
| `DataStore_Containers.lua:354` | **high** | `ScanGuildBankInfo` did `thisGuild.Tabs[tabID]` with no nil check, while `ScanContainer` at `:271` — same file, same tick, reached from the same `GUILDBANKBAGSLOTS_CHANGED` handler — already guards it. | `if not thisGuild then return end`. | Fixed |
| `DataStore_Containers.lua:760` | **high** | The `MSG_BANKTAB_TRANSFER` comm callback iterated `guild.Tabs` unguarded. It runs on an incoming guild whisper, i.e. on data the local player does not control. | `if not guild then return end`. | Fixed |
| `DataStore_Containers.lua:161` | medium | `SaveBankTimestamps` opened with `strlen(timestamps)` on wire data; the sender's `GetBankTimestamps` returns nil when the guild bank has never been visited, and the sibling sender at `:722` guards for exactly that reason. | `if not timestamps or strlen(timestamps) == 0 then return end`. | Fixed |
| `DataStore_Characters.lua:143` | **high** | `_GetColoredCharacterName` concatenated `ClassColors[character.englishClass] .. character.name`; both are nil for an entry that exists but was never scanned, and AceDB's `['*']` default manufactures exactly such an entry on any key read. `Altoholic/Frames/Tooltip.lua:194` already expects the miss. | `or ""` on both, and on `_GetClassColor`. | Fixed |
| `DataStore_Characters.lua:180` | medium | `_GetXPRate` is `floor((character.XP / character.XPMax) * 100)` with no guard: nil `XPMax` errors, and at max level `UnitXPMax` is 0 so `0/0` prints as `-nan%`. Siblings `_GetXP`/`_GetXPMax` both use `or 0`. | Early-return 0 when `XPMax` is nil or 0; same guard applied to `_GetRestXPRate`. | Fixed |
| `DataStore_Crafts.lua:487` | **high** | `link:match(...)` on `GetTradeSkillRecipeLink`, which is nil while the tradeskill is not fully cached — the state on the first `TRADE_SKILL_SHOW`. The sibling idiom is eight lines up at `:448`. | `(link and tonumber(link:match("enchant:(%d+)"))) or 0`. | Fixed |
| `DataStore_Crafts.lua:327` | **high** | `SetTradeSkillSubClassFilter(subClassID-1, …)` — `GetSubClassID` falls off the end and returns nil when no subclass filter matched, so the arithmetic errors and the user's tradeskill filters are never restored. Its twin two lines down already writes `invSlotID = invSlotID or 1`. | `subClassID = subClassID or 1`. | Fixed |
| `DataStore_Crafts.lua:397` | medium | `ScanCooldowns` used `GetTradeSkillLine()` unguarded: nil raises "table index is nil" through the AceDB metatable, and `"UNKNOWN"` silently creates a bogus profession row that Altoholic then displays. `ScanRecipes:468` has the guard. | Copied the sibling guard. | Fixed |
| `DataStore_Currencies.lua:60` | medium | `ScanCurrencies` is the `CURRENCY_DISPLAY_UPDATE` handler and calls `ExpandCurrencyList`, which re-fires that event — a re-entrant rescan with no guard. `DataStore_Crafts.lua:528` documents this exact hazard. | A file-local `isScanning` flag in the handler. | Fixed |
| `DataStore_Currencies.lua:102, 147` | low | `_` missing from both `local` lists, so both public mixins write the global `_`. | Added to both declarations. | Fixed |
| `DataStore_Inventory.lua:142` | medium | `function ScanInventory()` with no `local` — a very generic leaked global, where every sibling scanner in the family is local. | `local function`. | Fixed |
| `DataStore_Inventory.lua:92` | medium | `format("%s:%d", UnitName("player"), ail)` with `ail` unguarded, although the same function guards the alt case eight lines later. Runs on `DATASTORE_GUILD_ALTS_RECEIVED` at every login. | `ail or 0`. | Fixed |
| `DataStore_Inventory.lua:228` | medium | When the member is offline **and** the player is not in a guild, the early return is skipped and `sentRequests[nil] = time()` raises "table index is nil". | `if not main then return end`. | Fixed |
| `DataStore_Inventory.lua:174`, `DataStore_Stats.lua:141` | medium | Both `UNIT_INVENTORY_CHANGED` handlers ignored the unit argument and rescanned the player for events fired by pets, party members and targets — constant churn in a raid. | `(event, unit)` with `if unit == "player"`, matching `DataStore_Mails`' `OnBagUpdate(event, bag)`. | Fixed |
| `DataStore_Mails.lua:551` | medium | `strlower(mailSender)` in the `ReturnInboxItem` hook — `GetInboxHeaderInfo` returns a nil sender for system/GM mail and mail from deleted characters, and the error aborts the return for every addon in the client. `ScanMailbox:183` already tolerates a nil sender. | `local senderName = mailSender or ""`. | Fixed |
| `DataStore_Achievements.lua:200` | medium | `"|h\[%s\]|h"` — `\[` is not a valid Lua 5.1 escape. Behaviour was already correct (the client drops the backslash); the edit stops `check.js` gating. | `"|h[%s]|h"`. | Fixed |
| `DataStore_Achievements.lua:45` | medium | `format("%d:%d:%d", month, day, year)` with no nil check. `ACHIEVEMENT_EARNED` forces `isCompleted = true` regardless, so if the client has not yet flagged the achievement the date trio is nil and `%d` errors. `_GetAchievementLink:173` already tolerates a missing completion date. | Wrapped in `if month then`. | Fixed |
| `DataStore_Achievements.lua:73` | medium | `month`, `day`, `year` were leaked globals, written for every achievement of every category on every `PLAYER_ALIVE`. | Added to the `local` declaration. | Fixed |
| `DataStore_Achievements.lua:78` | medium | `GetAchievementInfo` returns nil for a filtered or unavailable index, and `ScanSingleAchievement(nil, …)` then does `Achievements[nil] = true`. | `if achievementID then` around the body, and `break` in the progressive-achievement walk. | Fixed |
| `DataStore_Quests.lua:265` | medium | `isUsable = (isUsable and isUsable == 1)` — `isUsable` comes from `strsplit`, so it is the string `"1"` and never the number. The comparison was always false: every quest reward was reported as unusable. | `isUsable = (isUsable == "1")`. | Fixed |
| `DataStore_Quests.lua:237`, `DataStore_Spells.lua:36` | medium | `strsplit("|", …)` on a possibly-nil cached entry (a stale index after the list shrank). Siblings at `DataStore_Quests.lua:257` and `DataStore_Reputations.lua:40` show the shape. | Early return on nil. | Fixed |
| `DataStore_Pets.lua:37` | medium | The `if modelID and name …` guard skipped index `i` rather than compacting, leaving holes. `#pets` is undefined on a sparse array and stops at the first hole, so `_IsPetKnown` under-reported mounts and companions. `DataStore_Spells.lua:92` already uses `table.insert`. | `table.insert(list, …)`. | Fixed |
| `DataStore_Stats.lua:61` | medium | `_, t[i] = UnitResistance("player", i)` — no `local`, so the global `_` is written six times per scan. | `local _, total` then `t[i] = total`. | Fixed |
| `DataStore.lua:263` | medium | `arg1 = owner.Characters[arg1]` then `arg1.lastUpdate` with no nil check, although the guild sibling nine lines below already has it. This metatable is the entry point for *every* `DataStore:GetXXX(character, …)` call, and `DataStore:GetCharacter()` legitimately returns nil for an unknown key. | `if not arg1 or not arg1.lastUpdate then return end`. | Fixed |
| `DataStore.lua:291` | medium | `GUILD_ROSTER_UPDATE`, `CHAT_MSG_SYSTEM` and `RegisterComm` were registered only if `IsInGuild()` was true at `OnEnable`. A player who joins a guild mid-session got no roster indexes, no online tracking and no alt broadcast for the rest of the session, although `OnPlayerGuildUpdate` is written to handle joining. `OnDisable` also left the comm registered. | Extracted `RegisterGuildEvents()` (forward-declared) and call it from both `OnEnable` and `OnPlayerGuildUpdate`; added `UnregisterComm` to `OnDisable`. | Fixed |
| `DataStore_Skills.lua:195`, `DataStore_Achievements.lua:242` | low | `function addon:CHAT_MSG_SKILL(self, msg)` / `addon:ACHIEVEMENT_EARNED(self, id)` — the explicit `self` shadows the colon's implicit one and absorbs the event name. Both work (the bodies reach `addon` directly) but it is the same shape as the Altoholic `ns:OnChange` bug. | Renamed to `event`, matching `DataStore_Reputations.lua:170`. | Fixed |
| `DataStore_Quests.lua:340`, `DataStore_Pets.lua:144`, `DataStore_Auctions.lua:143`, `DataStore_Containers.lua:814` | low | Each `OnDisable` omitted events its own `OnEnable` (or an on-demand handler) had registered, so handlers kept firing after the module was disabled. | Added the missing `UnregisterEvent` calls. | Fixed |
| `DataStore/Export/ExportToXML.lua:156, 274, 479` | low (offline) | Not an addon file — absent from `DataStore.toc`, run as a standalone desktop lua5.1 script via `go.bat`. `BottomLevels[bottom]` is nil for any non-threshold value and `format("%s", nil)` errors in 5.1; `CompletionDates[index]:match(...)` indexes a date that may not exist; and the guild-bank tab exporter computed an item name and then emitted the raw id, where its twin at `:228` emits the name. | `or "Unknown"`, a `completionDate` guard matching `DataStore_Achievements.lua:173`, and `text` instead of `itemID`. | Fixed |

**Rejected.** Guards for `DataStore` being absent (every module has a hard `## Dependencies`
plus a line-1 early return). The header walkers in Quests/Reputations/Skills/Crafts/Currencies —
all save state, expand descending so revealed rows land at already-passed indices, and restore;
correct as written. `pairs()` value mutations in Quests, Skills, Containers, Crafts and Stubby —
Lua 5.1 permits replacing a value or clearing an existing key during traversal. `DataStore_Quests`'
`QuestFrameCompleteQuestButton` hook — both names are genuine 3.3.5 FrameXML, corroborated by
`Carbonite.lua:11393`. `DataStore_Currencies:152 if isHeader == "1"` — misleading name, correct
logic. No `arg1`/`arg2`/`this`/`ChatFrameEditBox` anywhere in the family.

**Deferred.** `DataStore_Containers.lua:512` computes a container cooldown from a `GetTime()`
value persisted to SavedVariables; `GetTime()` is session uptime, so after a relog the stored
start time is from a different epoch and the remaining time is meaningless. Fixing it means
storing `time()` alongside and migrating the database — recorded, not half-fixed, the same call as
`Altoholic/Profiler.lua:48`. `DataStore/Options.lua:161` runs a full `collectgarbage()` on every
panel `OnShow` (a visible hitch, not a defect). `GetSpellInfo(spellID)` is fed unguarded into
`format("%s")` in Pets, Talents and four places in Crafts — a real nil risk with no sibling guard
anywhere in the family to copy, so it is recorded rather than guessed at.

**Not changed: `## DefaultState: disabled`.** Present identically in all 17 DataStore `.toc` files
*and* in `Altoholic.toc`. That is the author's packaging choice — the modules are opt-in and the
user enables them alongside Altoholic — not an install defect.

### Bartender4 — audit complete, 12 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `ActionButton.lua:459` | **high** | `Button:UpdateRange` clears `self.rangeTimer` when range tracking does not apply, but has no `else` to set it. `onUpdate` only decrements and re-arms a timer that is **already** running (`if self.rangeTimer then … = TOOLTIP_UPDATE_TIME`), so the field was nil for every button's whole lifetime and the entire out-of-range block never ran once. Both out-of-range modes — the red icon tint and the hotkey indicator — were dead for every user. | Added `else self.rangeTimer = -1`, so the `onUpdate(self, 10)` at the end of `UpdateRange` evaluates range immediately. | Fixed |
| `StanceBar.lua:267` | **high** | `if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORMS" and not InCombatLockdown()`. `and` binds tighter than `or`, so the combat check only guarded the second event. `PLAYER_ENTERING_WORLD` fires on every zone change, including one taken in combat, and the body creates and re-anchors secure `CheckButton`s. The only protected-frame defect found anywhere in this workspace. | Parenthesised: `(a or b) and not InCombatLockdown()`. | Fixed |
| `ActionBars.lua:138` | **high** | `BT4ActionBars:UpdateButtons` walked `ipairs(self.actionbars)`. That table is sparse by design — bars 7-10 ship disabled, and only enabled bars get an entry — so `ipairs` stops at the first hole. Enabling bar 9 while 7 stays disabled means bar 9 never refreshes its buttons. The sibling `GetAll` in the same file already uses `pairs`. | `pairs`, plus a nil guard on `self.actionbars` and on each bar's `buttons`. | Fixed |
| `ActionButton.lua:236` | medium | `local valid = IsActionInRange(self.action)` then `if valid and hkshown then hotkey:Show()`. `IsActionInRange` returns **0** when out of range and `0` is truthy in Lua, so in-range and out-of-range took the same branch and the indicator was always shown. The next line already reads the value correctly (`self.outOfRange = (valid == 0)`). | `if valid == 0 and hkshown`. | Fixed |
| `ActionBars.lua:158` | medium | A 120-iteration pre-4.2.0 binding-rename migration plus an unconditional `SaveBindings` ran on **every** `UPDATE_BINDINGS`. `SaveBindings` itself fires `UPDATE_BINDINGS`, so the handler re-entered on its own write. | Gated behind a `self.renamedLegacyBindings` flag (it is a one-off migration) and `SaveBindings` is only called when something was actually renamed. | Fixed |
| `Bartender4.lua:360` | medium | `Bartender4:Merge` filled a key whenever `not target[k]`, which overwrites a stored `false` with the default. Any boolean default of `true` silently reverted a user's "off". | `elseif target[k] == nil then`. | Fixed |
| `Bartender4.lua:405` | medium | `function createLDBLauncher()` at file scope with no `local` — a leaked global with a name generic enough for any other addon to clobber. Same class as `function ScanInventory()` in DataStore_Inventory. | Forward-declared `local createLDBLauncher` next to the `LDB`/`LDBIcon` upvalues it closes over. | Fixed |
| `BagBar.lua:59` | medium | `function clearSetPoint(btn, ...)` — same defect, and an even more generic name. | `local function clearSetPoint`. | Fixed |
| `Bartender4.lua:300, 305` | low | `f:CreateFontString('ARTWORK')` ×2. The first argument of `CreateFontString` is the **name**, not the layer, so both registered a global called `ARTWORK` and the second clobbered the first. | `f:CreateFontString(nil, 'ARTWORK')`. | Fixed |
| `Bartender4.lua:171, 219` | low | `Bartender4:GetModule("Vehicle", true)` passes the silent flag and can return nil, but the next line called `vehicleModule:Disable()` unguarded; the matching disable path used the non-silent `GetModule` and then indexed the result. | Both paths now use the silent form behind an `if vehicleModule then`. | Fixed |
| `ButtonBar.lua:160` | low | `UpdateButtonLayout` reads `#buttons` with no nil check, while `ForAll` six lines down already guards `if not self.buttons then return end`. | Matched the sibling guard. | Fixed |
| `ActionBars.lua:117` | low | `BT4ActionBars:ApplyConfig` indexes `self.actionbars`, which is only built in `OnEnable`; a profile change arriving first would error. | Early return when the table is absent. | Fixed |

**Recorded, not changed.** `StanceBarMod:ApplyConfig` disables the whole module when
`GetNumShapeshiftForms() == 0`, and `Bar:Disable` unregisters the bar's events — including the
`UPDATE_SHAPESHIFT_FORMS` that would tell it a form has since been learned. A Warrior who installs
Bartender4 below level 10 has no stance bar until a `/reload` after dinging. The fix means
re-registering at module level, which changes the enable path, so it is recorded rather than done
blind. `Bartender4.ButtonBar:Create` also calls `LBF:RegisterSkinCallback("Bartender4", …)` once
per bar created rather than once in total; harmless if LibButtonFacade de-duplicates, and LBF is
not vendored here to check.

### BeanCounter — audit complete, 24 bugs fixed

| File:line | Severity | Problem | Fix | State |
|---|---|---|---|---|
| `BeanCounterMail.lua:225` | **high** | `private.mailSort` iterates `pairs(private.reconcilePending)` and **every one of its seven branches** calls `tremove` on that same table. `table.remove` shifts the sequence down, so `next` skips entries and can raise "invalid key to 'next'". In practice roughly every other auction-house mail went unrecorded. | Reverse numeric loop, the idiom `BeanCounterUpdate._2_11` already uses. | Fixed |
| `BeanCounterTidyUp.lua:49, 123, 168, 264` | **high** | Four database filter lists test `DB == "completedBidsBuyoutsNeutralNeutral"` — a doubled suffix. The real key is `completedBidsBuyoutsNeutral` (created at `BeanCounter.lua:214`, written at `BeanCounterMail.lua:428`, read correctly in Search and the API). Every neutral-auction-house buyout was therefore invisible to `sumDatabase`, and was never compacted, sorted or integrity-checked. | Corrected all four. | Fixed |
| `BeanCounterConfig.lua:39` | **high** | `debugPrint` calls `get(…)`, but line 35 deliberately takes `_, _` from `getLocals` (because `lib.GetSetting` is not defined until line 366), and line 374 declares a **new** `local get, set` that the already-closed-over `debugPrint` can never see. Every call errored on a nil global. | `get`/`set` forward-declared above `debugPrint` and **assigned** (not re-declared) at line 374. | Fixed |
| `BeanCounterTidyUp.lua:277` | **high** | `integrityCheck`'s row loop calls `table.remove(data, index)` while iterating `pairs(data)` — the same undefined behaviour, in the one routine whose whole job is to repair a corrupt database. | Reverse numeric loop. | Fixed |
| `MatchBeanCount.lua:62` | **high** | `cacheKey = itemId .."x".. property .. "x" .. factor .. "x" .. marketprice` is built **four lines above** the `if not marketprice then marketprice = 0 end` that was meant to protect it. A nil market price — which Auctioneer does pass — errors on the concatenation. | Moved the default above the key. | Fixed |
| `BeanCounterMail.lua:582` | medium | `mailCurrent[n].read = wasRead or 0`, and `read` is later compared with `< 2`. `GetInboxHeaderInfo` can return `wasRead` as a boolean, which makes that comparison error. | `wasRead and 1 or 0`. | Fixed |
| `BeanCounterUpdate.lua:63` | medium | `startPlayerUpgrade` compares `playerData["version"] < 2.0` with no coercion (a partly written SavedVariables file leaves it nil), and after the `< 2.0` branch resets the character it keeps using the **stale** local `playerData`, so every later step ran against a discarded table's version number. | `tonumber(...) or 0`, a `type(playerData) == "table"` guard, and an early `return` after the reset — the table `initializeDB` just built is already current. | Fixed |
| `BeanCounter.lua:171` | medium | `initializeDB` created `db["settings"]` and `db["ItemIDArray"]` only inside the `if not db` branch, so a database that lost either of them stayed broken for every later session. The top-level `BeanCounterDB` was also assumed to be a table. | Type-check the top level, then create either sub-table whenever it is missing — the same repair the `garbage.lua` scenario exercises for Bagnon. | Fixed |
| `BeanCounter.lua:297` | medium | `attachMeta` tests `if META == 0`, but `unpackString` returns strings, so the empty field arrives as `"0"` and the comparison was never true. Every disenchant record got a leading `0|`. Same shape as the `DataStore_Quests` `isUsable` bug. | `META == "0"`. | Fixed |
| `BeanCounter.lua:352` | medium | The disenchant watcher compares the `UNIT_SPELLCAST_SUCCEEDED` spell name against the literal `"Disenchant"` — only ever true on an enUS client — and `inDEState` is only ever cleared on `LOOT_OPENED`, so a cancelled disenchant left it armed and the next unrelated loot window was recorded as a disenchant result. | `GetSpellInfo(13262)` for the name, plus `UNIT_SPELLCAST_FAILED`/`_INTERRUPTED` registered to clear the flag. | Fixed |
| `BeanCounterTidyUp.lua:143, 155` | medium | `removeUniqueID` and `removeOldData` each recurse once per removed row — a few thousand stack frames on the first search of a long-lived character. `removeUniqueID` also compared a raw `strsplit` string against a number without `tonumber`, which its own sibling `removeOldData` already did. | Both converted to `while` loops; both now coerce the timestamp and stop on a non-numeric one. | Fixed |
| `BeanCounterTidyUp.lua:157` | medium | `date("%c", keep)` — `keep` is an undefined global; the cutoff variable is `expire`. | `date("%c", expire)`. | Fixed |
| `BeanCounterSearch.lua:165` | medium | `searchServerData` returns bare `nil` when a realm is below the current database version, and the caller feeds that straight into `formatServerData`, which iterates it. | `return data` (the empty accumulator). | Fixed |
| `BeanCounterAPI.lua:216` | medium | `getAHProfitGraph` does `for i,v in pairs(tbl) do … tinsert(tbl, b) end` — inserting into the table it is iterating — and never checks that `startSearch` returned anything. | Collect into a second table, then append; plus a `type(tbl) ~= "table"` early return. | Fixed |
| `BeanCounterConfig.lua:191` | medium | The purge-checkbox label divides the months-to-keep slider by 100, so a 6-48 slider rendered as "older than 0.06 months". The identical label built at line 472 has no `/100`. | Dropped the `/100`. | Fixed |
| `BeanCounterMail.lua:347, 393` | low | `tremove(private.reconcilePending, i, private.reconcilePending[i]["itemLink"])` — `table.remove` takes two arguments. Lua 5.1 ignores the third; Lua 5.2+ raises "wrong number of arguments", and the `_dev` harness compiles every addon under fengari (5.3). | Two arguments. | Fixed |
| `BeanCounterMail.lua:424` | low | `deposite` — an undefined global passed into `packString`. Benign in effect (nil round-trips to `"0"`, which is what the comment says the field should be) but it was reading a global to get there. | Explicit `""`. | Fixed |
| `BeanCounterMail.lua:432` | low | `debugPrint(…, value, …)` in the failure branch, where `value` is declared inside the success branch — another undefined global read. | Dropped from the argument list. | Fixed |
| `BeanCounterMail.lua:570` | low | The `group` start/end tracker is a file local that is never reset, so the first row of each mailbox scan was compared against the last row of the previous one. | Reset at the top of `mailBoxColorStart`. | Fixed |
| `BeanCounter.lua:50-57` | low | The `private` table constructor listed `AucModule,`, `wealth,`, `playerData,` and `serverData,` as bare names. That is not a declaration in Lua — each reads an undefined global and adds a nil array entry. The intent was documentation. | Converted to comments naming where each is actually assigned. | Fixed |
| `BeanCounter.lua:142-150` | low | Four events registered on the main script frame with no handler at all: `MERCHANT_SHOW`/`_UPDATE`/`_CLOSED` (the vendor branch is commented out and `private.vendorOnevent` is never called) and `UNIT_SPELLCAST_SENT` (the disenchant watcher uses its own frame and a different event). | Removed, with a comment saying why. | Fixed |
| `BeanCounter.lua:440` | low | `databaseAdd` does `suffixID = tonumber(suffixID)` then `if suffixID < 0`; a malformed itemString errors on the compare. | `or 0`. | Fixed |
| `BeanCounterTidyUp.lua:127, 200` | low | `string.len(uniqueID)` in `compactDB` and `time() - TIME` in `prunePostedDB`, both on values that come straight out of `decodeLink`/`strsplit` and can be nil. | `or "0"` and a `tonumber` guard on the loop condition. | Fixed |
| `BeanCounterAPI.lua:110, 288` | low | `addDEValue` matches with `(%d-)`, which can capture the empty string and then reach a multiply; `getAHSoldFailed` indexes `playerData["completedAuctions"]`/`["failedAuctions"]` and does arithmetic on `auctime` with no guard on either. | `(%d+)` plus `tonumber`; `type(...) == "table"` guards on both databases and an `auctime and` on both comparisons. | Fixed |

**Recorded, not changed.**

- `"util.beacounter.invoicetime"` is misspelled (missing the `n`) but **consistently** — the
  default, the slider and the single read all agree. Correcting it would orphan every existing
  user's setting for no behavioural gain.
- `private.scriptframe` keeps a permanent `OnUpdate` calling `private.mailonUpdate` every frame.
  Idle cost is two length operations and a comparison. Registering the script only while
  `inboxStart`/`reconcilePending` are non-empty is the right fix and is a visible change to the
  mail-reconcile flow, so it is not done blind.
- `private.matchDB` linear-scans the whole `ItemIDArray` for every auction-house mail. A name→id
  reverse index fixes it but changes the SavedVariables shape — the same call as
  `DataStore_Containers.lua:512`.
- `BeancounterVendor.lua` is dead end to end: `vendorOnevent` is never called, two functions have
  empty bodies, and the `hooksecurefunc("BuyMerchantItem", …)` that would drive `merchantBuy` is
  commented out. Its one nil-dereference was guarded; the file was otherwise left alone.
- `MatchBeanCount.lua` runs its `SetDefault` block and a `print` at file scope because
  `lib.OnLoad` is commented out upstream. It works and matches the other Auc-* modules here.
- `private.hasUnreadMail` has an entirely commented-out body and is still called from two places.
  Left as the author's disabled feature.

### Needs a client

Three findings are behaviour-critical if the underlying API claim is wrong, and none can be
settled from the source in this workspace. All are recorded rather than applied:

1. **AllStats — `PaperDollFrame_Set*` signatures.** Claim: 3.3.5 passes `(statFrame, unit, statIndex)`.
2. **`!Swatter/Swatter.lua:122` — `UIParent_OnEvent`.** Claim: 3.3.5 calls it as `(self, event, ...)`,
   not `(etype, ...)`. Swatter hooks this function, so a wrong signature here breaks the hook chain
   for every addon in the client.
3. **`DataStore_Talents.lua:211` — `GetGlyphSocketInfo` return arity.** The code reads four values.
   If WotLK returns five (`enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename`) then
   `spell` and `icon` are off by one and `enabled` may be a boolean the concatenation below rejects.

Verify each against a real 3.3.5 `FrameXML` dump or a running client before changing anything.
