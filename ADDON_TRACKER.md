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
(501 lua files parse, 0 errors, 0 unknown globals; smoke 133, migrate 50, garbage 7 — all 0 failures).

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
- **Auction ecosystem incomplete** vs the plan: `BeanCounter`, `Enchantrix`, `Enchantrix-Barker`, `Informant` are **not present**. Only Auc-* modules + FixAH exist.
- **Priority-list addons not in this workspace at all:** EveryQuest, ZygorGuidesViewer, TomTomLite, GatherMate, SilverDragon, GearScore, Grid2, PowerAuras, Quartz, Recount, Postal, BankStack(present), Bartender4, Prat-3.0, Titan, SCT, SellJunk, Overachiever, BonusScanner, MobInfo2. Phases 4/5/8/9/10/11 in the master plan cannot start until those folders exist.

---

## Addon inventory & status

33 addon folders. Grouped by ecosystem.

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
| Auc-Advanced | 5.8.4723 | AucAdvancedConfig, AucAdvancedData / AucAdvancedLocal(char) | Static-only + audit pending | Core. Needs **Stubby** (missing). Fixed `UiParent`→`UIParent`, `\n` mangles in elGR/zhTW help. |
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
| Altoholic | 3.3.002b | AltoholicDB | Static-only + audited | DataStore front-end. **DataStore family missing** — won't load as-is. Deep audit done — 16 bugs fixed, incl. the `Characters.lua` sort comparator that passed the global `self` (nil) into `DataStore[func]`, and two handlers that filtered on the removed `arg1` global and so never ran. |
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

### Queued (actionable without a client)
1. ~~Apply + verify confirmed high/med bugs from the deep audit; re-run `node all.js`~~ — **done for every audited addon**, gate 4/4 green. Remaining: the Auctioneer suite, and the two findings under [Needs a client](#needs-a-client).
2. **AtlasLoot Phase 6** — UI modernize. ~~Confirm data modules load lazily (LoD), not at startup~~ — **verified correct, no change needed**: all 5 data modules carry `## LoadOnDemand: 1`, and the one startup path that would force them in (`AtlasLoot.lua:361`) is behind the `LoadAllLoDStartup` profile option, which defaults to `false` (`AtlasLoot.lua:109`). The other `AtlasLoot_LoadAllModules()` calls are user-initiated (search across all modules, browser buttons) or a one-time wishlist migration for pre-4.03.01 SavedVariables.
3. **Auctioneer Phase 7** — scan stability, duplicate-scan prevention, caching, error recovery, respect AH throttle. Guard for missing **Stubby**.
4. Optional runtime scenarios in `_dev` to actually *execute* the static-only addons (auction/tradeskill/DataStore mocks — real work, no catch-all in mock by design).
5. Guard Altoholic against absent DataStore so it degrades instead of hard-crashing (or document that DataStore folders must be added).

### Blocked (need folders added to workspace)
- Phase 4 leveling integration (Carbonite + EveryQuest + Zygor + TomTom): EveryQuest/Zygor/TomTom absent.
- Phase 5 EveryQuest improvements: absent.
- Phase 8 Postal: absent.
- Phases 9–11 dungeon/raid (GearScore, Grid2, PowerAuras, Quartz, Recount): all absent.
- Complete auction suite (BeanCounter, Enchantrix, Informant, Stubby): absent.

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

### Needs a client

Two findings are behaviour-critical if the underlying API claim is wrong, and neither can be
settled from the source in this workspace. Both are recorded rather than applied:

1. **AllStats — `PaperDollFrame_Set*` signatures.** Claim: 3.3.5 passes `(statFrame, unit, statIndex)`.
2. **`!Swatter/Swatter.lua:122` — `UIParent_OnEvent`.** Claim: 3.3.5 calls it as `(self, event, ...)`,
   not `(etype, ...)`. Swatter hooks this function, so a wrong signature here breaks the hook chain
   for every addon in the client.

Verify each against a real 3.3.5 `FrameXML` dump or a running client before changing anything.
