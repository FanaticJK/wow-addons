# Quest Item Helper

Highlights quest items in your bags that belong to quests you no longer have, so you can clean
them up without guessing. **It only shows information.** It never deletes, sells, moves, mails or
vendors items, and never abandons quests.

- **Client:** World of Warcraft 3.3.5a (WotLK, build 12340), `## Interface: 30300`
- **Dependencies:** none. Bagnon and Baggins are supported when installed but are not required.

## Installation

Copy the `QuestItemHelper` folder to `World of Warcraft/Interface/AddOns/QuestItemHelper/`,
restart the game, and make sure the addon is enabled on the character select screen.

## What you see

| Item | Shown as |
|---|---|
| Normal item | nothing |
| Quest item for a quest in your log | nothing. Its tooltip says which quest needs it |
| Quest item whose quest is gone | colored border (orange by default) and a warning icon in the corner |
| Quest item the addon cannot link to a quest | nothing by default (see *Options*) |

Hover a flagged item to see why it was flagged, which quest or quests it belongs to, and whether
each quest was turned in or just isn't in your log.

## Commands

| Command | Effect |
|---|---|
| `/qih` or `/questitemhelper` | status and a list of flagged items |
| `/qih scan` | rescan your bags now |
| `/qih list` | list flagged items in chat |
| `/qih config` | open the options (also: Esc > Interface > AddOns) |
| `/qih debug` | toggle debug output that shows how each quest item was judged |
| `/qih reset` | restore the default settings (learned links are kept) |
| `/qih forget` | forget the learned item/quest links |

## Options

- Enable the addon
- Highlight items in bags
- Show warning icon
- Add tooltip information
- Highlight color
- **Only flag when the quest is completely inactive (turned in):** items of quests that only left
  your log (for example abandoned quests, which you can pick up again) are not flagged. Only items
  of quests the server reports as completed are flagged.
- **Also flag quest items no current quest uses:** also flags *Quest Item* items that are not linked
  to any known quest. This is less certain, so it is off by default.
- Debug output

## How detection works

The 3.3.5 API has no "which quest needs this item" function, so the addon combines what the
client does provide:

1. **Quest starters** ("This Item Begins a Quest"): `GetContainerItemQuestInfo` gives the quest the
   item starts. If that quest is in your log, the item is not flagged. If the server's completed-quest
   history (`QueryQuestsCompleted` / `GetQuestsCompleted`) shows it was turned in, the item is
   flagged. Otherwise the item can still start its quest and is left alone.
2. **Quest items** are items with the *Quest Item* binding (`GetContainerItemQuestInfo`) or the
   *Quest* item class (`GetItemInfo`). Any other item is never flagged.
3. **Links between items and quests** are learned while a quest is in your log, from:
   - its item objectives (`GetQuestLogLeaderBoard`, type `item`, text `<item name>: x/y`), and
   - its "use" item (`GetQuestLogSpecialItemInfo`).

   Links are stored by **item ID and quest ID**, not by name, and are kept in SavedVariables. One
   item can be linked to several quests.
4. **Decision:** if any linked quest is in your log, the item is not flagged. If none is, the item is
   flagged, with these exceptions:
   - A linked quest is a daily quest. You may need the item again.
   - The *only turned in* option is on and the quest is not confirmed completed.

   An item with no known link counts as **unknown** and is not flagged (unless you turn on that option).

The whole quest log is read, including quests under collapsed headers. Headers are expanded for the
read and then collapsed again, and your selected quest is kept.

## Limitations caused by the 3.3.5 API

- **Items from quests finished before you installed the addon** have no learned link, so they show
  as *unknown* and are not flagged. Turn on *Also flag quest items no current quest uses* to see them.
  Read their tooltip before you delete anything: some may be for quests you have not picked up yet.
- Links are learned by matching the item name against objective text in your own client language.
  Name matching only ever *protects* an item. It can mark an item as needed, but it never flags one.
- Quest-provided items without an objective (letters to deliver, for example) cannot be linked. The
  server usually removes them when the quest ends anyway.
- A quest that disappears from your log counts as turned in only if its reward window was just
  closed, or if the server's completed-quest history says so (requested at every login). Otherwise
  it counts as *not in your quest log*.
- `BAG_UPDATE_DELAYED`, `QUEST_ACCEPTED`, `QUEST_REMOVED`, `QUEST_TURNED_IN` and `C_Timer` do not exist in 3.3.5. The
  addon debounces `BAG_UPDATE` / `QUEST_LOG_UPDATE` / `UNIT_QUEST_LOG_CHANGED` instead, with a hidden
  frame whose `OnUpdate` only runs while a refresh is pending. Bags are never scanned every frame.
- Bank slots are flagged when the bank is open in Blizzard's bank bags or in Bagnon. The addon's own
  bag scan (`/qih list`) covers the backpack, bags 1 to 4 and the keyring.

## Bag addons

Each integration is an adapter that calls `QuestItemHelper:UpdateButton(button, bag, slot)` when a
slot is redrawn:

- **Blizzard bags:** hook on `ContainerFrame_Update`
- **Bagnon 2.x:** hook on `Bagnon.ItemSlot.Update` (offline/cached views are skipped)
- **Baggins:** hook on `Baggins:UpdateItemButton`

Another bag addon can be supported without changing this addon:

```lua
QuestItemHelper:RegisterBagAdapter('MyBags', 'MyBags', function()
	hooksecurefunc(MyBags, 'UpdateSlot', function(self, button, bag, slot)
		QuestItemHelper:UpdateButton(button, bag, slot)
	end)
end)
```

ArkInventory, BaudBag and AdiBags have no adapter yet, because their internals could not be checked
against a 3.3.5 copy here. With them the addon still works in Blizzard's bags and in tooltips.

## Libraries

None are bundled. LibStub, CallbackHandler and Ace3 would only add weight to five small files. The
options panel uses Blizzard's Interface Options widgets. None of the item/quest libraries in this
pack can answer "which quest needs this item":

- **LibItemSearch** (in Bagnon) only matches items against search text.
- **LibPeriodicTable-3.1** (in Baggins) has quest-starter and reputation turn-in sets, but no
  quest IDs.
- **LibGratuity** scans tooltips, which `GetContainerItemQuestInfo` makes unnecessary.
- **Carbonite's** quest database is internal to Carbonite and is not a library.

## Saved data

- `QuestItemHelperDB` (account): settings plus `knowledge` (learned item → quest links, quest
  titles, daily flags). Missing keys are filled with defaults. Existing values are never overwritten.
- `QuestItemHelperCharDB` (character): cached completed-quest IDs from the server.
