# WoW 3.3.5a Addon Pack — Bagnon, BankStack & Carbonite

A maintained set of **World of Warcraft: Wrath of the Lich King 3.3.5a** addons
(`## Interface: 30300`), with bug fixes, a cleaned-up UI and a verification harness.

| | |
|---|---|
| **Game client** | WotLK **3.3.5a** (build 12340) only. Retail and Classic clients will not work. |
| **Inventory** | Bagnon family: one window for bags, bank, keyring and guild bank, plus offline characters and "who has this item" tooltips |
| **Sorting** | BankStack: sort, stack, compress and fill bags and bank |
| **Map & quests** | Carbonite 3.34: world map, quest helper, guide, gathering nodes |
| **Status** | Static analysis and mock-runtime checks pass. **Not yet tested in a live game client** (see [Testing status](#testing-status)) |

> **Upgrading from the original versions?** Your saved settings and offline character data are
> kept. Nothing is renamed or wiped. See [Saved data](#saved-data).

---

## Contents

- [What's included](#whats-included)
- [Installation](#installation)
- [Usage](#usage)
  - [Bagnon](#bagnon)
  - [BankStack](#bankstack)
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

| Folder | Version | What it does | Loads | Requires |
|---|---|---|---|---|
| `Bagnon` | 2.13.0 | Single-window inventory, bank and keyring | Always | — (BankStack and Bagnon_Forever optional) |
| `Bagnon_Config` | — | Options panels under *Interface → AddOns → Bagnon* | On demand | `Bagnon` |
| `Bagnon_Forever` | 1.2.0 | Remembers every character's bags, bank and equipment for offline viewing | Always | — |
| `Bagnon_GuildBank` | 1.1.0 | Guild bank in the Bagnon style | On demand (at the guild vault) | `Bagnon` |
| `Bagnon_Tooltips` | — | Adds "who owns this item" lines to item tooltips | Always | `Bagnon_Forever` |
| `BankStack` | v17.1 | Sort, stack, compress and fill | Always | — |
| `Carbonite` | 3.34 | Map, quest tracking, guide, warehouse, social | Always | — |
| `CarboniteItems` | 1.00 | Item database for Carbonite | On demand | `Carbonite` |
| `CarboniteNodes` | 1.00 | Herbalism and mining locations to import into Carbonite | On demand | `Carbonite` |
| `CarboniteTransfer` | 1.01 | Moves Carbonite Warehouse data between accounts | Always | `Carbonite` |

Each group works on its own. Install only the Bagnon family, only Carbonite, or all of it.

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
   The Bagnon family and BankStack ship with `DefaultState: disabled`, so tick them the first
   time:

   | Want | Enable |
   |---|---|
   | Bag window | `Bagnon` |
   | Options UI | `Bagnon_Config` (easy to forget: without it the options button only prints a message) |
   | Alts' items and money | `Bagnon_Forever` |
   | "Who has this" tooltips | `Bagnon_Tooltips` (needs `Bagnon_Forever`) |
   | Guild bank window | `Bagnon_GuildBank` |
   | Sort button and `/sort` | `BankStack` |
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

A short list. [MODERNIZATION_LOG.md](MODERNIZATION_LOG.md) has the full per-addon detail, and
[MODERNIZATION_REPORT.md](MODERNIZATION_REPORT.md) has the write-up for the Bagnon family and
BankStack.

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
| BankStack | `BankStackDB` | account |
| Carbonite | `NxData`, `NxCombatOpts`, `NxMapOpts`, `NxCData` | account, per character |
| CarboniteTransfer | `CarboniteTransferData` | account |

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
| Static check: every `.toc`/XML file reference exists, every Lua file parses as Lua 5.1, no retail-only APIs, no undefined globals, no invalid string escapes | 126 files, 0 errors |
| Fresh-install run of the Bagnon family and BankStack against a mocked 3.3.5 client (windows, search, bags, player switch, options, sorting with item conservation, guild bank, logout, options fit inside 413×428) | 111 checks pass |
| Legacy 2.6.0 plus deliberately corrupted SavedVariables, migrated and saved/reloaded | 50 checks pass |
| SavedVariables that are not even tables | 7 checks pass |

What still needs a real client:
- how things look on screen (the mock has no geometry)
- taint
- real guild bank permissions and withdraw limits
- real sorting with server latency
- performance

**Carbonite has only been statically checked:** parsed, globals checked, XML scripts and asset
paths checked. It has not been executed. Bug reports from real play are very welcome (see below).

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
| Lua errors | Type `/console scriptErrors 1`, reproduce, and report the full error text |

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
Bagnon/                 core bag window (components/, localization/, libs/)
Bagnon_Config/          options panels (panels/, widgets/)
Bagnon_Forever/         offline character database
Bagnon_GuildBank/       guild bank window
Bagnon_Tooltips/        item ownership tooltips
BankStack/              sorting and stacking (lib/ holds bundled Ace3)
Carbonite/              map / quest addon (Gfx/, Snd/)
CarboniteItems/         item data (load on demand)
CarboniteNodes/         gathering node data (load on demand)
CarboniteTransfer/      warehouse transfer
_dev/                   verification harness (not an addon; don't install it)
MODERNIZATION_LOG.md    per-addon tracker: what was fixed, how to verify, what is left
MODERNIZATION_REPORT.md write-up for the Bagnon family and BankStack
```

---

## Credits and licenses

| Addon | Original author |
|---|---|
| Bagnon, Bagnon_Config, Bagnon_Forever, Bagnon_GuildBank, Bagnon_Tooltips | Tuller |
| BankStack | Kemayo |
| Carbonite, CarboniteItems, CarboniteNodes, CarboniteTransfer | Carbon Based Creations, LLC |
| Bundled libraries (Ace3, LibStub, CallbackHandler, LibDataBroker-1.1, LibItemSearch-1.0, LibDBIcon) | their respective authors |

All credit for the addons goes to their original authors. This repository contains fixes and
maintenance for 3.3.5a on top of their work.

**Carbonite is proprietary.** It ships with its own end-user license,
[`Carbonite/CarboniteLicenseAgreement.txt`](Carbonite/CarboniteLicenseAgreement.txt), which
grants personal, non-commercial use and restricts modification and redistribution. Read it
before using or sharing the Carbonite folders. The other addons carry no license file in this
repository. Refer to their original distributions for terms.
