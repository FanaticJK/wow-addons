--[[
	tables.lua
		Shared table helpers for saved variable handling
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local Tables = {}
Bagnon.Tables = Tables


--recursively fills in missing values from defaults.
--values whose type does not match the default (ie, corrupted saved variables) are replaced.
function Tables.CopyDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			if type(tbl[k]) ~= 'table' then
				tbl[k] = {}
			end
			Tables.CopyDefaults(tbl[k], v)
		elseif type(tbl[k]) ~= type(v) then
			tbl[k] = v
		end
	end
	return tbl
end

--recursively removes values that are identical to their defaults, so saved variables stay small
--and users automatically pick up improved defaults for anything they never customized
function Tables.RemoveDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(tbl[k]) == 'table' and type(v) == 'table' then
			Tables.RemoveDefaults(tbl[k], v)

			if next(tbl[k]) == nil then
				tbl[k] = nil
			end
		elseif tbl[k] == v then
			tbl[k] = nil
		end
	end
end

function Tables.Wipe(tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
	end
	return tbl
end

--compares two dotted version strings ("2.12.6").  returns true if a < b
function Tables.IsVersionOlder(a, b)
	if type(a) ~= 'string' then
		return true
	end

	local aParts = {strsplit('.', a)}
	local bParts = {strsplit('.', tostring(b))}
	for i = 1, math.max(#aParts, #bParts) do
		local x = tonumber(aParts[i]) or 0
		local y = tonumber(bParts[i]) or 0
		if x ~= y then
			return x < y
		end
	end
	return false
end
