-- The worst case: the SavedVariables file survived but the values are the wrong
-- type entirely (a truncated or hand-edited file). Nothing here is recoverable,
-- so the addon must say so and start clean rather than error on every frame.
BagnonGlobalSettings = 'this used to be a table'
BagnonFrameSettings = 42
BagnonForeverDB = false
