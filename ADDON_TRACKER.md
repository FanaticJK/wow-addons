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

34 addon folders. Grouped by ecosystem.

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
| Auc-Filter-Basic | 5.8.4723 | AucAdvancedFilterBasic(+_IgnoreList) | Static-only + audit pending | Filter module. |
| Auc-ScanData | 5.8.4723 | AucScanData | Static-only + audit pending | LoD scan cache. |
| Auc-Stat-Histogram | 5.8.4723 | AucAdvancedStatHistogramData(+Total) | Static-only + audit pending | Stat module. |
| Auc-Stat-iLevel | 5.8.4723 | AucAdvancedStat_iLevelData | Static-only + audit pending | Stat module. |
| Auc-Stat-Purchased | 5.8.4723 | AucAdvancedStatPurchasedData | Static-only + audit pending | Stat module. |
| Auc-Stat-Simple | 5.8.4723 | AucAdvancedStatSimpleData | Static-only + audit pending | Stat module. |
| Auc-Stat-StdDev | 5.8.4723 | AucAdvancedStatStdDevData | Static-only + audit pending | Stat module. |
| Auc-Util-FixAH | 5.8.4723 | — | Static-only + audit pending | AH paging workaround. |

### AtlasLoot family — loot browser (author: Hegarol) — **Static-only / Deep-audit pending**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| AtlasLoot | v5.11.04 | AtlasLootOptions, AtlasLootDB, AtlasLootWishList / AtlasLootCharDB, AtlasLootFilterDB(char) | Static-only + audit pending | Core. `break;` false positives cleared in checker. Phase 6 UI-modernize + lazy-load not started. |
| AtlasLootFu | v5.11.04 | AtlasLootFuDB | Static-only + audit pending | FuBar minimap front-end (Ace2/FuBar-2.0). |
| AtlasLoot_BurningCrusade | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_Crafting | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_OriginalWoW | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_WorldEvents | v5.11.04 | — | Static-only | LoD loot data table. |
| AtlasLoot_WrathoftheLichKing | v5.11.04 | — | Static-only | LoD loot data table. |

### Altoholic family — alt manager (author: Thaoky) — **Static-only / Deep-audit pending**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Altoholic | 3.3.002b | AltoholicDB | Static-only + audit pending | DataStore front-end. **DataStore family missing** — won't load as-is. Known bug: `Characters.lua` sort comparator passes global `self`(nil) into `DataStore[func]`. |
| Altoholic_Achievements | 3.3.002 | — | Static-only + audit pending | Achievements UI module. |

### AckisRecipeList family — recipe scanner (author: Ackis/Torhal) — **Static-only / Deep-audit pending**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| AckisRecipeList | 1.0-2817 | ARLDB2 | Static-only + audit pending | Recipe scanner (all tradeskills incl. Runeforging). Fixed `%a+\:`→`%a+:`. Large recipe data files. |
| AckisRecipeList_QuickScan | 3.3.5-1.0.1 | — (dep ARL) | Static-only | LDB quick-menu companion. Clean. |

### Standalone — **Static-only / Deep-audit pending**
| Folder | Ver | SavedVariables | Status | Notes |
|---|---|---|---|---|
| Baggins | r435 | BagginsDB | Static-only + audit pending | Virtual-bag inventory (Ace2/Ace3/Waterfall/Dewdrop). Fixed `## Interface` 30200→30300. |
| BankStack | v17.1 | BankStackDB | Done | Sort/stack. Fixed bank-bag range 8–11, OnUpdate `arg1`→`elapsed`, tooltip re-owning, nil-safety. Runtime-tested (used by Bagnon sort button). |
| AllStats | 1.1 | — | Static-only | Paperdoll stats panel. Clean, no changes. |
| !Swatter | 5.8.4723 | SwatterData | Static-only | Error catcher (Auctioneer lib). Fixed realm-suffix gsub `\.`→`%.`. |

---

## Work queue

Ordered by value, given no in-game client.

### In progress
- **Deep audit of the 23 static-only addons** (logic/event/perf bugs the checker can't catch).
  Running as 4 parallel audits: (1) Auctioneer suite, (2) AtlasLoot family, (3) Altoholic, (4) AckisRecipeList+Baggins+AllStats+!Swatter.
  Findings + fixes will be appended to [Deep-audit findings](#deep-audit-findings) below and to MODERNIZATION_LOG.md.

### Queued (actionable without a client)
1. Apply + verify confirmed high/med bugs from the deep audit; re-run `node all.js`.
2. **AtlasLoot Phase 6** — UI modernize + confirm data modules load lazily (LoD), not at startup.
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

_(pending — audits running)_
