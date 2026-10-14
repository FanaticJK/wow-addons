-- -------------------------------------------------------------------------- --
-- GridStatusSearing DEFAULT (english) Localization                         --
-- Please make sure to save this file as UTF-8. ¶                             --
-- -------------------------------------------------------------------------- --

GridStatusSearing_Locales =

{
	["Opacity"] = true,
	["Sets the opacity for the raid icons."] = true,
}

function GridStatusSearing_Locales:CreateLocaleTable(t)
	for k,v in pairs(t) do
		self[k] = (v == true and k) or v
	end
end

GridStatusSearing_Locales:CreateLocaleTable(GridStatusSearing_Locales)