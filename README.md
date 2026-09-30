# WoW 3.3.5a Addon Pack

A maintained set of **World of Warcraft: Wrath of the Lich King 3.3.5a** addons
(`## Interface: 30300`), with bug fixes, a cleaned-up UI and a verification harness.
33 addon folders across seven groups.

| | |
|---|---|
| **Game client** | WotLK **3.3.5a** (build 12340) only. Retail and Classic clients will not work. |
| **Inventory** | Bagnon family (one window for bags, bank, keyring and guild bank, plus offline alts), Baggins (virtual bags split into rule-driven sections), BankStack (sort, stack, compress, fill) |
| **Alts** | Altoholic: browse every character's bags, bank, mail, skills, talents and achievements while offline |
| **Loot tables** | AtlasLoot Enhanced + its five data modules: what drops from which boss, plus crafting, world events and set lists |
| **Auction house** | Auctioneer suite (core + five statistics modules + a filter, scan-data cache and a browse-paging fix) |
| **Professions** | Ackis Recipe List: which recipes you are missing and where each one comes from |
| **Map & quests** | Carbonite 3.34: world map, quest helper, guide, gathering nodes |
| **Utility** | AllStats (full stat list beside the character sheet), Swatter (readable Lua error catcher) |
| **Status** | Static analysis and mock-runtime checks pass. **Not yet tested in a live game client** (see [Testing status](#testing-status)) |

> **Two groups need folders that are not in this repository.** Altoholic needs the DataStore
> family and Auctioneer needs Stubby. Neither is bundled here, and WoW will not load an addon
> whose hard dependency is missing. See [Missing dependencies](#missing-dependencies).

> **Upgrading from the original versions?** Your saved settings and offline character data are
> kept. Nothing is renamed or wiped. See [Saved data](#saved-data).

---

## Contents

- [What's included](#whats-included)
- [Missing dependencies](#missing-dependencies)
- [Installation](#installation)
- [Usage](#usage)
  - [Bagnon](#bagnon)
  - [Baggins](#baggins)
  - [BankStack](#bankstack)
  - [Altoholic](#altoholic)
  - [AtlasLoot](#atlasloot)
  - [Auctioneer](#auctioneer)
  - [Ackis Recipe List](#ackis-recipe-list)
  - [AllStats](#allstats)
  - [Swatter](#swatter)
  - [Carbonite](#carbonite)
- [What changed](#what-changed)
- [Saved data](#saved-data)
- [Testing status](#testing-status)
- [Troubleshooting](#troubleshooting)
- [For developers](#for-developers)
- [Repository layout](#repository-layout)
- [Credits and licenses](#credits-and-licenses)

---

## What's included

Each group works on its own. Install only the group you want, or all of it.

### Bags and bank

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `Bagnon` | 2.13.0 | Single-window inventory, bank and keyring | Always | — (BankStack and Bagnon_Forever optional) |
| `Bagnon_Config` | — | Options panels under *Interface → AddOns → Bagnon* | On demand | `Bagnon` |
| `Bagnon_Forever` | 1.2.0 | Remembers every character's bags, bank and equipment for offline viewing | Always | — |
| `Bagnon_GuildBank` | 1.1.0 | Guild bank in the Bagnon style | On demand (at the guild vault) | `Bagnon` |
| `Bagnon_Tooltips` | — | Adds "who owns this item" lines to item tooltips | Always | `Bagnon_Forever` |
| `Baggins` | 435 | Alternative bag window: virtual bags split into sections by rules you write | Always | — |
| `BankStack` | v17.1 | Sort, stack, compress and fill | Always | — |

Bagnon and Baggins are two different answers to the same problem, and both replace the default
bag frames. Run **one** of them, not both.

### Alts

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `Altoholic` | 3.3.002b | Browse every character on the account offline: bags, bank, mail, quests, skills, talents, reputations, currencies, glyphs, pets, plus a cross-character item search | Always | **DataStore family — not bundled** |
| `Altoholic_Achievements` | 3.3.002 | The Achievements tab inside Altoholic | On demand | `Altoholic`, `DataStore`, `DataStore_Achievements`, `DataStore_Characters` |

### Loot tables

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `AtlasLoot` | v5.11.04 | Loot browser: what each boss drops, searchable, with a wish list | Always | — |
| `AtlasLootFu` | v5.11.04 | Minimap / FuBar button for AtlasLoot | Always | `AtlasLoot` |
| `AtlasLoot_OriginalWoW` | v5.11.04 | Vanilla instance loot tables | On demand | `AtlasLoot` |
| `AtlasLoot_BurningCrusade` | v5.11.04 | Burning Crusade instance loot tables | On demand | `AtlasLoot` |
| `AtlasLoot_WrathoftheLichKing` | v5.11.04 | Wrath instance loot tables | On demand | `AtlasLoot` |
| `AtlasLoot_Crafting` | v5.11.04 | What every profession can make | On demand | `AtlasLoot` |
| `AtlasLoot_WorldEvents` | v5.11.04 | Holiday and world-event rewards | On demand | `AtlasLoot` |

The five data modules are load-on-demand: they cost nothing until you open a table they hold.

### Auction house

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `Auc-Advanced` | 5.8.4723 | Auctioneer core: scanning, the price engine, the AH interface | Always | **Stubby — not bundled** |
| `Auc-Stat-Simple` | 5.8.4723 | Price model: exponential moving averages over 1 / 3 / 7 / 14 days | Always | `Auc-Advanced` |
| `Auc-Stat-StdDev` | 5.8.4723 | Price model: uses variance to discard outliers | Always | `Auc-Advanced` |
| `Auc-Stat-Histogram` | 5.8.4723 | Price model: histogram of observed prices | Always | `Auc-Advanced` |
| `Auc-Stat-Purchased` | 5.8.4723 | Price model: weights the last known price before an auction ended | Always | `Auc-Advanced` |
| `Auc-Stat-iLevel` | 5.8.4723 | Price model: groups by quality, type and item level, for items with no history | Always | `Auc-Advanced` |
| `Auc-Filter-Basic` | 5.8.4723 | Hides auctions below a quality or item level, and ignores named sellers | Always | `Auc-Advanced` |
| `Auc-ScanData` | 5.8.4723 | Holds the (large) scan dataset, loaded only when something asks for it | On demand | `Auc-Advanced` |
| `Auc-Util-FixAH` | 5.8.4723 | Forces new AH searches back to page 1, working around a client paging bug | Always | — |

Auctioneer needs **at least one** `Auc-Stat-*` module enabled or it has nothing to price with.

### Professions

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `AckisRecipeList` | 1.0 (2817) | Lists the recipes your character is missing for a profession and where each one drops, is sold or is taught. Covers every tradeskill including Runeforging | Always | — |
| `AckisRecipeList_QuickScan` | 3.3.5-1.0.1 | LibDataBroker button that scans a profession without opening its window | Always | `AckisRecipeList` |

### Map and quests

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `Carbonite` | 3.34 | Map, quest tracking, guide, warehouse, social | Always | — |
| `CarboniteItems` | 1.00 | Item database for Carbonite | On demand | `Carbonite` |
| `CarboniteNodes` | 1.00 | Herbalism and mining locations to import into Carbonite | On demand | `Carbonite` |
| `CarboniteTransfer` | 1.01 | Moves Carbonite Warehouse data between accounts | Always | `Carbonite` |

### Utility

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `AllStats` | 1.1 | Shows every stat from the character-sheet dropdowns at once, beside the paperdoll | Always | — |
| `!Swatter` | 5.8.4723 | Catches Lua errors and shows them in a readable window with the call stack. The `!` keeps it first in load order so it can catch errors in other addons | Always | — |

---

## Missing dependencies

Two groups declare hard `## Dependencies` on folders that are **not in this repository**. WoW
silently refuses to load an addon whose hard dependency is absent, so these will sit greyed out
in the AddOns list until you add the missing folders yourself.

| Group | Needs | Where it comes from |
|---|---|---|
| `Altoholic`, `Altoholic_Achievements` | The whole **DataStore** family: `DataStore`, `DataStore_Achievements`, `_Auctions`, `_Characters`, `_Containers`, `_Crafts`, `_Currencies`, `_Inventory`, `_Mails`, `_Pets`, `_Quests`, `_Reputations`, `_Skills`, `_Spells`, `_Stats`, `_Talents` | Shipped alongside Altoholic in its original 3.3.5 distribution |
| `Auc-Advanced` and every `Auc-*` module | **Stubby** | Shipped inside the Auctioneer Suite installer |

The rest of the Auctioneer Suite (`BeanCounter`, `Enchantrix`, `Enchantrix-Barker`, `Informant`)
is also absent. Those are optional — Auctioneer runs without them — but the AH tooltip lines and
purchase history they provide will not be there.

Everything else in this repository is self-contained: the libraries each addon needs
(Ace2, Ace3, LibStub, Dewdrop, Tablet, Waterfall, Configator, FuBar shims, LibGratuity and the
rest) are bundled inside the addon folders that use them.

---

## Installation

1. **Download** the repository: on GitLab use **Code → Download source code (zip)**, or clone it:

   ```sh
   git clone https://gitlab.com/regolithsjk/wow-plugins.git
   ```

2. **Copy the addon folders** into your client's AddOns directory:

   ```
   <World of Warcraft 3.3.5a>\Interface\AddOns\
   ```

   Copy the folders themselves, so the result looks like `Interface\AddOns\Bagnon\Bagnon.toc`.
   Do **not** copy `_dev/`, `.git/` or the `.md` files. They are for development only.

   > A common mistake is ending up with `AddOns\wow-plugins\Bagnon\...` or
   > `AddOns\Bagnon\Bagnon\...`. WoW only finds an addon when its `.toc` sits directly
   > inside `AddOns\<FolderName>\`, and the folder name must match the `.toc` name.

3. **Enable them in game.** On the character select screen, click **AddOns** (bottom left).
   Several folders ship with `DefaultState: disabled` (the Bagnon family, BankStack, Altoholic,
   Ackis Recipe List, AllStats), so tick what you want the first time:

   | Want | Enable |
   |---|---|
   | Bag window | `Bagnon` |
   | Options UI | `Bagnon_Config` (easy to forget: without it the options button only prints a message) |
   | Alts' items and money | `Bagnon_Forever` |
   | "Who has this" tooltips | `Bagnon_Tooltips` (needs `Bagnon_Forever`) |
   | Guild bank window | `Bagnon_GuildBank` |
   | Sectioned bags instead of Bagnon | `Baggins` (do not run it alongside Bagnon) |
   | Sort button and `/sort` | `BankStack` |
   | Offline alt browser | `Altoholic` (plus the DataStore folders, and `Altoholic_Achievements` for the achievements tab) |
   | Boss loot tables | `AtlasLoot`, plus whichever data modules you want, and `AtlasLootFu` for the minimap button |
   | Auction house | `Auc-Advanced`, at least one `Auc-Stat-*`, and any of `Auc-Filter-Basic`, `Auc-ScanData`, `Auc-Util-FixAH` |
   | Missing recipes | `AckisRecipeList` (`AckisRecipeList_QuickScan` for the data broker button) |
   | Full stat list | `AllStats` |
   | Readable Lua errors | `!Swatter` |
   | Map and quests | `Carbonite`, `CarboniteItems`, `CarboniteNodes` (`CarboniteTransfer` only if you move data between accounts) |

   The `.toc` files already say `30300`, so **Load out of date AddOns** is not needed on a
   3.3.5a client.

4. **Log in.** Press `B` (or your bag key) to open Bagnon.

---

## Usage

### Bagnon

**Slash commands:** `/bagnon` or `/bgn`

| Command | Effect |
|---|---|
| `/bagnon` | Lists the commands |
| `/bagnon bags` | Toggle the inventory window |
| `/bagnon bank` | Toggle the bank window (live at a banker, cached otherwise with Bagnon_Forever) |
| `/bagnon keys` | Toggle the keyring |
| `/bagnon config` | Open the options |
| `/bagnon reset` | Move every Bagnon window back to its default position (use this if a window is off screen) |
| `/bagnon version` | Print the version |

**Key bindings** (*Game Menu → Key Bindings → Bagnon*): toggle inventory, toggle bank, toggle keyring.

**In the window:**

- **Drag the title** to move the window. Right-click the title to open that window's settings.
  Double-click the title to search.
- **Search:** click the magnifier and type a name, quality, type or tooltip text.
- **Bag bar:** the backpack button shows your bags. Click a bag to hide or show its slots.
- **Player selector:** view another character's bags (needs Bagnon_Forever).
- **Sort button** (header, needs BankStack):
  - left click sorts
  - right click compresses partial stacks
  - Shift-click moves stacks between your bags and the bank
  - clicking while a sort is running stops it
  - hidden for offline characters
- **Free slot counter** (footer): free / total slots. It turns orange when you are almost full
  and red when you are full. The tooltip separates normal bags from specialty bags (quiver, soul,
  profession, keyring).

**Options** (*Interface → AddOns → Bagnon*, needs `Bagnon_Config`):

| Page | Settings |
|---|---|
| General Settings | Which windows Bagnon replaces, Blizzard bag passthrough, lock positions, empty slot background, reset positions / reset everything |
| Frame Settings | Per window (inventory, bank, keyring, guild bank): bag bar, money, DataBroker, search, options and sort buttons, slot counter, reverse slot order, bag break layout, colors, columns, spacing, scale, opacity, layer, reset |
| Automatic Display | Open the inventory automatically at the bank, auction house, vendor, trade, guild bank, crafting, character sheet |
| Color Settings | Highlight by quality or quest item, highlight style and brightness, tint empty slots by bag type |

Every option has a tooltip. Options that don't apply to the selected window are greyed out,
and the tooltip says why.

### Baggins

**Slash command:** `/baggins` (opens the Baggins menu)

Baggins replaces the bag frames with one or more **bag windows**, each divided into **sections**.
A section is filled by **categories** rather than by which physical bag an item sits in, so a
"Trade Goods" section collects trade goods from every bag at once.

**Key binding** (*Key Bindings → Baggins*): toggle all bag windows.

**Menu** (`/baggins`, or right-click the FuBar / minimap plugin):

| Entry | What it does |
|---|---|
| Config Window | The main options window: item display, layout, skin, FuBar text |
| Bag/Category Config | The editor for bag windows, their sections, and the categories that fill them |
| Load Profile | Apply a built-in layout — *Default* (sorted into categories), *All in one* (one bag sorted by quality), *All In One Sorted* — or one you saved. **This discards your custom bags** |
| Save Profile / Delete Profile | Keep the current layout under a name, or remove a saved one |
| Items | Item display: quality colouring, item counts, new-item highlighting, empty slots |
| Layout | Columns, scale, spacing, padding and where the bag windows sit |
| Skin | Which skin draws the frames (see the note below) |
| Hide Default Bank / Override Bags | Whether Baggins replaces the default bank and bag frames |
| Force Full Refresh | Re-sort everything now, if a category change has not taken effect |
| PT3 LoD Modules | Only shown if LibPeriodicTable-3.1 modules are installed: which ones to load at startup |

**Category rules.** A category is a list of rules combined with AND / OR. The available rule
types are:

| Rule | Matches on |
|---|---|
| `ItemName` | Item name, substring match |
| `ItemID` | An explicit item id |
| `ItemType` | Item type and subtype (Armor / Cloth, Trade Goods / Herb, …) |
| `ItemLevel` | Item level, with a minimum and maximum |
| `Quality` | Item quality, from Poor to Legendary |
| `EquipLoc` | Equipment slot |
| `Bind` | Bind type: on pickup, on equip, on use, quest item |
| `Bag` | Which physical bag the item is in |
| `ContainerType` | Bag type: normal, quiver, soul bag, profession bag |
| `AmmoBag` | Items in an ammo bag or quiver |
| `Empty` | Empty slots |
| `NewItems` | Items picked up since the bags were last opened |
| `Tooltip` | Text anywhere in the item's tooltip |
| `PTSet` | A LibPeriodicTable set, if that library is installed |
| `Category` | Another category, so categories can be composed |
| `Other` | Everything no other section claimed — put this last |

An item lands in the **first** section that claims it, so order sections from most specific to
least and finish with an `Other` section as a catch-all.

> **Skins:** a bag window's skin is saved by name. If you later remove the addon that provided
> that skin, Baggins falls back to the built-in `default` skin rather than failing to draw.

### BankStack

| Command | Effect |
|---|---|
| `/sort` (`/sortbags`) | Sort your bags. `/sort bank` sorts the bank (while it is open) |
| `/stack` | Move items from your bags onto matching partial stacks in the bank |
| `/stack <from> <to>` | Stack between two groups, e.g. `/stack bank bags` |
| `/compress` (`/compressbags`) | Merge partial stacks. `/compress bank` for the bank |
| `/fill` (`/fillbags`) | Fill empty slots of one group from another, e.g. `/fill bags bank` |
| `/bankstack` | Open the BankStack options |

Groups: `bags`, `bank`, `all`, `guild`, `guild1` … `guild6`, plus any custom groups you define in
the options. Bank and guild bank commands only work while that window is open.

### Altoholic

**Slash commands:** `/altoholic` or `/alto`

| Command | Effect |
|---|---|
| `/alto toggle` | Show or hide the Altoholic window |
| `/alto show` / `/alto hide` | Show or hide it explicitly |
| `/alto search <item name>` | Search every character's bags for an item |
| `/alto` | List the commands |

**Key binding** (*Key Bindings → Altoholic*): toggle the Altoholic window.

**Tabs:**

| Tab | What it shows |
|---|---|
| Summary | One row per character: level, money, played time, item level, professions, rest XP, mail expiry, auction expiry, currencies, glyphs |
| Characters | One character in detail: bags, bank, equipment, mail, quests, skills, talents, spells, reputations, pets, companions |
| Search | Search every character's bags, bank, mail and equipment at once. Also searches the loot and recipe databases |
| Guild Bank | Guild bank tabs recorded by any of your characters, browsable offline |
| Achievements | Achievement progress per character (needs `Altoholic_Achievements`) |

Data is collected by the DataStore modules as you play: log in on a character once and its bags,
mail and skills become visible from every other character.

### AtlasLoot

**Slash commands:** `/atlasloot` or `/al`

| Command | Effect |
|---|---|
| `/al` | Open the loot browser |
| `/al options` | Open the options |
| `/al reset` | Move the AtlasLoot frames back to their default positions |

**Minimap button** (needs `AtlasLootFu`): left-click toggles the loot browser, shift-left-click
opens the options, right-click gives the standard FuBar plugin menu, and dragging moves the
button. It also registers as a FuBar plugin if FuBar is installed.

**In the browser:**

- Pick a category on the left (an expansion, a set list, a profession, a world event), then a
  boss or a table, and the drops appear on the right.
- **Hover** an item for its tooltip. Hold **shift** while hovering to compare it against what
  you have equipped.
- **Shift-click** an item to link it into chat.
- **Ctrl-click** an item to preview it in the dressing room.
- **Alt-click** an item to put it on (or take it off) the **wish list**, which has its own entry
  in the category list and is saved per account.
- **Search** finds an item by name across the loaded tables; from a search result or a wish-list
  entry, clicking the source takes you back to the table the item came from.
- Heroic, 25-man and faction variants of a table are switched with the buttons on the panel
  where they exist.

### Auctioneer

**Slash commands:** `/auc`, `/aadv` or `/auctioneer`

| Command | Effect |
|---|---|
| `/auc help` | List the commands, including the ones each loaded module adds |
| `/auc config` | Open the Auctioneer configuration |
| `/auc begin [catid [subcatid]]` | Scan the auction house, optionally one category only |
| `/auc pause` / `/auc resume` | Pause and continue a running scan |
| `/auc end` | Stop scanning and commit what was collected |
| `/auc abort` | Stop scanning and discard what was collected |
| `/auc getall` | Download the whole auction house in one request |
| `/auc clear <itemlink>` | Forget the stored data for one item |
| `/auc about [all]` | Print the running version, or every file's version |

**At the auction house,** Auctioneer adds its own tabs to the AH frame: *Browse* for searching
with price appraisal, *Post* for listing items at a suggested price, and *Search* for saved
searches. Item tooltips gain a price line as soon as one statistics module has data.

**Getting useful prices:** Auctioneer knows nothing until it has scanned. Run a full scan
(`/auc begin`) at an auction house a few times over several days; the moving-average modules need
repeat observations before their numbers mean anything. `Auc-Stat-iLevel` is the exception — it
estimates from item level and quality, so it has an opinion about items it has never seen.

### Ackis Recipe List

**Slash commands:** `/arl` or `/ackisrecipelist`

| Command | Effect |
|---|---|
| `/arl` | Open the options |
| `/arl scan` | Scan the currently open tradeskill window |
| `/arl scanprof` | Scan every profession this character knows |
| `/arl filter` | Open the filter options |
| `/arl profile` | Open the profile options |
| `/arl about` | Open the about panel |

**Normal use:** open a profession window and click the **Ackis Recipe List** button attached to
it. The list shows every recipe for that profession you have *not* learned, with the acquire
method for each one — trainer, vendor, mob drop, quest, world drop, reputation, seasonal or
discovery — including the NPC name, zone and coordinates where that applies.

**Filters** matter here: by default the list includes everything, which is a lot. The filter
panel narrows by skill level, faction, reputation standing, item quality, acquire method and
armour/weapon type, so you can ask "what can I train right now" rather than "what exists".

`AckisRecipeList_QuickScan` adds a LibDataBroker launcher: click it to scan a known profession
without opening its window.

### AllStats

No slash command and no configuration. Open the character sheet and every stat that normally
hides behind the Base / Melee / Ranged / Spell / Defence dropdowns is listed at once in a panel
beside the paperdoll.

### Swatter

**Slash commands:** `/swatter` or `/swat`

| Command | Effect |
|---|---|
| `/swat` (or `/swat help`) | List the commands |
| `/swat show` | Show the last error box again |
| `/swat clear` | Clear the list of recorded errors |
| `/swat enable` / `/swat disable` | Turn error catching on or off |
| `/swat autoshow` / `/swat noauto` | Pop the error window up automatically, or only print to chat |
| `/swat warn` / `/swat nowarn` | Catch or ignore blocked-action warnings |

Swatter replaces the default Lua error popup with a window that shows the message, the call
stack, the addon it came from and the loaded-addon list, all selectable so you can copy the text
into a bug report. Errors are kept in `SwatterData` between sessions.

The folder name starts with `!` on purpose: WoW loads addons alphabetically, so `!Swatter` loads
first and can catch errors thrown by everything after it. Do not rename it.

### Carbonite

**Slash commands:** `/carb` or `/nx`

| Command | Effect |
|---|---|
| `/carb` | Lists the commands |
| `/carb options` | Open the options window |
| `/carb menu` | Open the Carbonite menu |
| `/carb goto [zone] x y` | Set a map target |
| `/carb note "name" [zone] [x y]` | Add a map note |
| `/carb track <name>` | Track a player on the map |
| `/carb resetwin` | Reset window layouts (use this if a window is lost) |
| `/carb winshow <name> [0/1]` | Show, hide or toggle a Carbonite window |
| `/carb winpos <name> x y` / `winsize <name> w h` | Position or size a window |
| `/carb rl` | Reload the UI |

**Key bindings** (*Key Bindings → Nx*):
- map sizes (original / normal / max / none), restore map scale, full-size minimap
- herb and mining nodes on the map
- toggle Favorites, Guide and Warehouse
- minimize the watch list, use the top quest watch item, skip the current target

**Gathering nodes:** after enabling `CarboniteNodes`, import the herb and mining locations
from the **Guide** page of the Carbonite options window.

---

## What changed

A short list, covering the Bagnon family, BankStack and Carbonite.
[ADDON_TRACKER.md](ADDON_TRACKER.md) holds the per-folder status for every addon and the full
findings table for the rest of them, [MODERNIZATION_LOG.md](MODERNIZATION_LOG.md) has the
per-addon detail, and [MODERNIZATION_REPORT.md](MODERNIZATION_REPORT.md) has the write-up for
the Bagnon family and BankStack.

### Bugs fixed that could lose or corrupt data

- **Bagnon_Forever wiped every offline character on every login.** A typo (`cVersion`) stored
  `version = nil`, so every login looked like a version change and reset the cache.
- **Bagnon's settings upgrade changed a table while looping over it**, which can corrupt the
  hidden-bags list.
- **Bagnon_Config overwrote the global `Bagnon` table** with an options frame. That broke the key
  bindings and anything else using it.

### Other fixes

- **Bagnon options no longer spill out of the options window.** The panels were laid out for a
  ~620 px area, but 3.3.5a gives an addon panel only 413×428 px. All four pages were re-laid
  to fit.
- **BankStack:**
  - bank bags 8–11 were not treated as bank bags
  - the move timer used the removed `arg1` global
  - item scans silently stopped after the scanning tooltip lost its owner
  - sorting errored on items the client had not cached yet
  - `/compress` skipped guild bank groups
  - the config rejected the bank's bag id (`-1`)
- **Bagnon_Forever:**
  - equipment (and ammo in slot 0) was never counted
  - empty or unknown slots could cause errors
- **Bagnon_GuildBank:**
  - loaded a list of seven locale files that never existed
  - could open twice for one visit
  - queried tab 0
- **Bagnon:** "reset positions" seeded guild bank settings even when the guild bank addon
  was not installed.
- **Carbonite** (only the provably wrong code was touched; everything else is as shipped):
  - Halls of Reflection map tiles did not load (bad `\H` escape in the texture path)
  - Carbonite's slider backgrounds were invisible (same escape problem)
  - a call to an undefined function (`SSDC`, now `SetSelectedDisplayChannel`)
  - a missing battleground message string
  - an unguarded read of quest-map globals that don't exist in 3.3.5

### Improvements

- **Bagnon window:**
  - a consistent header / items / footer layout driven by one style module
  - a **sort button** and a **free slot counter**
  - class-colored owner names and a total line in item tooltips
- **Bagnon options:** every option has a tooltip, and options that don't apply are greyed out
  with the reason.
- **Performance:** ownership tooltips are cached instead of recounting every bag on every
  tooltip refresh.
- **Clearer messages:** e.g. naming `Bagnon_Config` when it is disabled, and saying so when
  saved settings were unreadable and had to be reset.

Nothing was removed: all slash commands, settings, SavedVariables names and bundled libraries
are unchanged, and no new dependencies were added.

---

## Saved data

| Addon | SavedVariables | Scope |
|---|---|---|
| Bagnon | `BagnonGlobalSettings`, `BagnonFrameSettings` | account, per character |
| Bagnon_Forever | `BagnonForeverDB` | account |
| Baggins | `BagginsDB` | account |
| BankStack | `BankStackDB` | account |
| Altoholic | `AltoholicDB` | account (the character data itself lives in the DataStore modules) |
| AtlasLoot | `AtlasLootOptions`, `AtlasLootDB`, `AtlasLootWishList`, `AtlasLootCharDB`, `AtlasLootFilterDB` | account, last two per character |
| AtlasLootFu | `AtlasLootFuDB` | account |
| Auc-Advanced | `AucAdvancedConfig`, `AucAdvancedData`, `AucAdvancedLocal` | account, last one per character |
| Auc-Stat-* | one `AucAdvancedStat<Name>Data` per module | account |
| Auc-Filter-Basic | `AucAdvancedFilterBasic`, `AucAdvancedFilterBasic_IgnoreList` | account |
| Auc-ScanData | `AucScanData` | account |
| AckisRecipeList | `ARLDB2` | account |
| AllStats | — (no saved settings) | — |
| !Swatter | `SwatterData` | account |
| Carbonite | `NxData`, `NxCombatOpts`, `NxMapOpts`, `NxCData` | account, per character |
| CarboniteTransfer | `CarboniteTransferData` | account |

`AucScanData` and `AltoholicDB` grow large — a full auction scan or a dozen tracked characters
runs to several megabytes. That is normal, and it is why `Auc-ScanData` is load-on-demand.

- **Existing data is kept.** Old Bagnon settings (back to 2.6.0) are migrated in place. Only
  values that are provably broken (a bad anchor, an out-of-range scale) are repaired. Unknown
  keys are never deleted.
- If a settings file is completely unreadable, Bagnon rebuilds it from defaults **and tells you**
  in chat instead of silently resetting.
- Carbonite's version number was deliberately **not** changed, so it will not treat your saved
  data as outdated.

Back up `WTF\Account\<ACCOUNT>\SavedVariables\` before upgrading any addon. It is a good habit.

---

## Testing status

**Nothing in this repository has been run in a real WoW 3.3.5a client yet.** What *has* been
done:

| Check | Result |
|---|---|
| Static check: every `.toc`/XML file reference exists, every Lua file parses as Lua 5.1, no retail-only APIs, no undefined globals, no invalid string escapes | 501 Lua files parsed, 0 errors, 0 warnings, 0 unknown globals |
| Fresh-install run of the Bagnon family and BankStack against a mocked 3.3.5 client (windows, search, bags, player switch, options, sorting with item conservation, guild bank, logout, options fit inside 413×428) | 133 checks pass |
| Legacy 2.6.0 plus deliberately corrupted SavedVariables, migrated and saved/reloaded | 50 checks pass |
| SavedVariables that are not even tables | 7 checks pass |

What still needs a real client:
- how things look on screen (the mock has no geometry)
- taint
- real guild bank permissions and withdraw limits
- real sorting with server latency
- performance

**Everything outside the Bagnon family and BankStack has only been checked, not executed.**
The mock-runtime scenarios cover Bagnon, its plugins and BankStack. The other 23 addon folders
were parsed, globals-checked, asset-path-checked, and in most cases read line by line for logic,
event and performance defects — but the auction house, tradeskill and DataStore APIs they depend
on are not mocked, so none of them has actually been run here.

| Group | How far it got |
|---|---|
| Bagnon family, BankStack | Static check + mock runtime scenarios |
| Altoholic, Ackis Recipe List, Baggins, AtlasLoot, AllStats, Swatter, Auc-Filter-Basic | Static check + a manual logic/event audit |
| Carbonite family, Auctioneer core and its statistics modules | Static check only |

Bug reports from real play are very welcome (see below).

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Addon missing from the AddOns list | Wrong folder depth. The path must be `Interface\AddOns\Bagnon\Bagnon.toc` |
| Bagnon doesn't open | Enable `Bagnon` in the AddOns list. It ships disabled |
| Options button only prints a message | Enable `Bagnon_Config` |
| No sort button | Enable `BankStack`. The button is also hidden for offline characters, and by default on the keyring and guild bank |
| A window is off screen | `/bagnon reset` for Bagnon, `/carb resetwin` for Carbonite |
| No other characters in Bagnon | Enable `Bagnon_Forever` and log in once on each character |
| Altoholic greyed out in the AddOns list | The DataStore folders are missing. See [Missing dependencies](#missing-dependencies) |
| Altoholic loads but every character is empty | Log in once on each character; DataStore records a character the first time it plays |
| Auctioneer greyed out in the AddOns list | `Stubby` is missing. See [Missing dependencies](#missing-dependencies) |
| Auctioneer shows no prices | Enable at least one `Auc-Stat-*` module, then run `/auc begin` at an auction house a few times. The averaging modules need repeat scans |
| AtlasLoot category is empty | The data module holding it is not enabled. Enable the matching `AtlasLoot_*` folder |
| Ackis Recipe List shows hundreds of recipes | Expected with no filters. Narrow it in `/arl filter` — skill level and acquire method help most |
| Both Bagnon and Baggins fight over the bags | Run one of them. Both replace the default bag frames |
| Lua errors | Enable `!Swatter` for a readable error window with the call stack, or type `/console scriptErrors 1` and report the full error text |

**Reporting a bug:** open an issue with the full error text, what you clicked or typed, and which
addons from this pack are enabled.

---

## For developers

The `_dev/` folder holds a verification harness. It needs **Node.js** (any current LTS).

```sh
cd _dev
npm install        # once: installs luaparse and fengari
node all.js        # runs every check, prints one summary, non-zero exit on failure
node all.js -v     # same, with full output
```

| Script | What it does |
|---|---|
| `check.js` | Static checker. Follows each `.toc` into its XML, parses every Lua file as 5.1, and reports missing files, retail-only APIs, invalid string escapes (e.g. `"Interface\Buttons"`), and globals not in `known.txt` |
| `run.js <scenario> [preload]` | Loads the real addon folders into a Lua VM (fengari) on a hand-written 3.3.5 client mock (`wowmock.lua`, `wowapi.lua`) in `.toc` order, then runs a scenario |
| `smoke.lua`, `migrate.lua`, `garbage.lua` | Scenarios. `sv_legacy.lua` and `sv_garbage.lua` are SavedVariables preloads |
| `known.txt` | Reviewed list of real 3.3.5 globals. A name reported that is not in it is a typo or a new dependency, so investigate it rather than just adding it |

Ground rules for changes:
- **3.3.5 APIs only:**
  - no `C_*` namespaces, `SetShown`, `SetColorTexture` or `BackdropTemplate`
  - use `SetWidth`/`SetHeight`, not `SetSize`
- **The mock has no catch-all.** An unmocked API errors on purpose. Before changing addon code,
  decide whether a failure is an addon bug or a gap in the mock.
- **Localization:** add new strings to the enUS locale file only. Other locales fall back.
- **SavedVariables:** repair what is broken, never wipe user data, and keep migrations idempotent.
- **Options panels** must fit **413×428**. `smoke.lua` asserts it.
- **`Carbonite.lua`** is minified, CRLF and latin1, with a 1.2 MB line. Edit it with an
  exact-match script, not by hand.

To add a new addon folder, follow *Adding a new addon* in
[MODERNIZATION_LOG.md](MODERNIZATION_LOG.md#adding-a-new-addon).

---

## Repository layout

```
!Swatter/                       Lua error catcher (loads first, hence the "!")
AckisRecipeList/                missing-recipe database (Databases/, Locales/)
AckisRecipeList_QuickScan/      data broker launcher for it
AllStats/                       full stat panel beside the character sheet
Altoholic/                      offline alt browser (Frames/, libs/, locale files)
Altoholic_Achievements/         its achievements tab (load on demand)
AtlasLoot/                      loot browser core (Core/, Locales/, Images/)
AtlasLootFu/                    minimap / FuBar button
AtlasLoot_OriginalWoW/          vanilla loot tables (load on demand)
AtlasLoot_BurningCrusade/       TBC loot tables (load on demand)
AtlasLoot_WrathoftheLichKing/   Wrath loot tables (load on demand)
AtlasLoot_Crafting/             profession output tables (load on demand)
AtlasLoot_WorldEvents/          holiday and event tables (load on demand)
Auc-Advanced/                   Auctioneer core (CoreModules/, Libs/)
Auc-Filter-Basic/               quality / item level / seller filter
Auc-ScanData/                   scan dataset store (load on demand)
Auc-Stat-Histogram/             price model: histogram
Auc-Stat-Purchased/             price model: last-known price
Auc-Stat-Simple/                price model: moving averages
Auc-Stat-StdDev/                price model: outlier-trimmed
Auc-Stat-iLevel/                price model: by quality / type / item level
Auc-Util-FixAH/                 AH browse paging fix
Baggins/                        sectioned bag windows
Bagnon/                         core bag window (components/, localization/, libs/)
Bagnon_Config/                  options panels (panels/, widgets/)
Bagnon_Forever/                 offline character database
Bagnon_GuildBank/               guild bank window
Bagnon_Tooltips/                item ownership tooltips
BankStack/                      sorting and stacking (lib/ holds bundled Ace3)
Carbonite/                      map / quest addon (Gfx/, Snd/)
CarboniteItems/                 item data (load on demand)
CarboniteNodes/                 gathering node data (load on demand)
CarboniteTransfer/              warehouse transfer
_dev/                           verification harness (not an addon; don't install it)
ADDON_TRACKER.md                per-folder status: version, saved variables, what was checked
MODERNIZATION_LOG.md            per-addon log: what was fixed, how to verify, what is left
MODERNIZATION_REPORT.md         write-up for the Bagnon family and BankStack
```

---

## Credits and licenses

| Addon | Original author |
|---|---|
| Bagnon, Bagnon_Config, Bagnon_Forever, Bagnon_GuildBank, Bagnon_Tooltips | Tuller |
| Baggins | Nargiddley |
| BankStack | Kemayo |
| Altoholic, Altoholic_Achievements | Thaoky (EU-Marecages de Zangar) |
| AtlasLoot and its data modules, AtlasLootFu | Hegarol (AtlasLoot Enhanced team) |
| Auc-* (the Auctioneer Suite), !Swatter | Norganna's AddOns |
| AckisRecipeList | Ackis, Zhinjio, Jim-Bim, Torhal, Pompachomp |
| AckisRecipeList_QuickScan | Torhal |
| AllStats | Ganoran |
| Carbonite, CarboniteItems, CarboniteNodes, CarboniteTransfer | Carbon Based Creations, LLC |
| Bundled libraries (Ace2, Ace3, LibStub, CallbackHandler, Dewdrop, Tablet, Waterfall, Configator, LibGratuity, LibDataBroker-1.1, LibItemSearch-1.0, LibDBIcon, the LibBabble family) | their respective authors |

All credit for the addons goes to their original authors. This repository contains fixes and
maintenance for 3.3.5a on top of their work.

Licenses differ per addon, and several are more restrictive than you might expect:

| Addon | License as shipped here |
|---|---|
| Carbonite family | **Proprietary.** [`Carbonite/CarboniteLicenseAgreement.txt`](Carbonite/CarboniteLicenseAgreement.txt) grants personal, non-commercial use and restricts modification and redistribution. Read it before using or sharing those folders |
| Altoholic, Altoholic_Achievements | **All rights reserved** unless stated otherwise — [`Altoholic/LICENSE.txt`](Altoholic/LICENSE.txt) |
| AckisRecipeList | **All rights reserved** unless stated otherwise; the localization entries are public domain — [`AckisRecipeList/LICENSE.txt`](AckisRecipeList/LICENSE.txt) |
| !Swatter | LGPL — [`!Swatter/lgpl.txt`](!Swatter/lgpl.txt) |
| Auc-* (the Auctioneer Suite) | GPL, per each `.toc`'s notes. **The `GPL.txt` those notes point at is not in this repository** — see the upstream Auctioneer distribution for the text |
| Everything else | No license file is included. Refer to the original distribution for terms |
