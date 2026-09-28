--[[
    A deliberately nasty set of SavedVariables, as if restored from disk after an
    old Bagnon (2.6.0) wrote them and something later corrupted parts of the file.

    Loaded by run.js before any addon, exactly where the client would restore them.
    Mixes three kinds of data on purpose:
      * values the addon must REPAIR   (wrong type / out of range / invalid enum)
      * values the addon must MIGRATE  (old formats)
      * values the addon must PRESERVE (deliberate user choices, unknown keys)
--]]

BagnonGlobalSettings = {
    version = '2.6.0',

    -- deliberate user choices: these must survive untouched
    highlightItemsByQuality = false,
    colorBagSlots = false,
    lockFramePositions = true,

    -- corrupted: wrong type, must fall back to the default (true)
    highlightQuestItems = 'yes please',

    -- corrupted: numeric but out of the 0..1 range, must fall back to 0.5
    highlightOpacity = 5,

    -- corrupted: not a known border style, must fall back to 'thin'
    itemBorderStyle = 'rainbow',

    slotColors = {
        ammo = 'not a color',          -- repaired to the default ammo color
        trade = {0.1, 0.2, 0.3},       -- valid custom color, must be preserved
        bogus = {1, 1, 1},             -- unknown color type, no default: dropped
    },

    -- pre-2.6.3 format: autoDisplayEvents had an array part that must be cleared,
    -- while the keyed part (a real user choice) must be preserved
    autoDisplayEvents = {
        'bank', 'vendor', 'mail',
        inventory = {bank = false},
    },

    enabledFrames = {
        inventory = true,
        bank = false,                  -- user turned the bank window off
        keys = true,
    },

    -- something the current version knows nothing about. It must NOT be discarded:
    -- an older/newer build or a sibling addon may still need it.
    unknownLegacyKey = 'keep me',
}

BagnonFrameSettings = {
    version = '2.6.0',
    frames = {
        inventory = {
            point = 'NOWHERE',             -- invalid anchor: reset point and x/y
            x = 100,
            y = 200,
            scale = 0,                     -- out of range: reset to 1
            opacity = 0,                   -- out of range: reset to 1
            itemFrameColumns = 0.5,        -- fractional and < 1: reset to 8
            frameLayer = 'SUBSPACE',       -- invalid layer: reset to HIGH
            frameColor = {'a', 0.1, 0.2},  -- first component corrupted
            hiddenBags = {[1] = 2},        -- legacy array form: becomes [2] = true
        },

        bank = 'this is not a table',       -- must be replaced, not error

        keys = {                           -- entirely valid: must be preserved
            point = 'TOPLEFT',
            x = 42,
            y = -42,
            scale = 1.5,
        },
    },
}

-- Bagnon_Forever data for a character that no longer exists on this realm,
-- to make sure the offline cache tolerates stale entries.
BagnonForeverDB = {
    version = '1.1.2',
    MockRealm = {
        ['Ghost'] = {
            class = 'MAGE',
            money = 999,
            [0] = {size = 16, count = 0},
        },
    },
}
