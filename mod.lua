if not PickUpWeapons then
	PickUpWeapons = {}
	PickUpWeapons.mod_instance = ModInstance
	PickUpWeapons.mod_path = ModPath
	PickUpWeapons.required = {}
	PickUpWeapons.weapon_table = blt.vm.dofile(ModPath .. "req/weapons.lua")

	Hooks:Register("PickUpWeaponsCreateWeaponTable")
	Hooks:Call("PickUpWeaponsCreateWeaponTable", PickUpWeapons.weapon_table)

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitPickupWeapons", function(loc)
		if HopLib then
			HopLib:load_localization(PickUpWeapons.mod_path .. "loc/", loc)
		else
			loc:load_localization_file(PickUpWeapons.mod_path .. "loc/english.txt")
		end
	end)

	Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadCompletePickupWeapons", function()
		NetworkHelper:SendToPeers("PickupWeapons", PickUpWeapons.mod_instance:GetVersion())
	end)

	NetworkHelper:AddReceiveHook("PickupWeapons", "PickupWeapons", function(data, sender)
		local peer = managers.network:session():peer(sender)
		if peer then
			peer._has_pickup_weapons_interaction = PickUpWeapons.mod_instance:GetVersion() == data
		end
	end)
end

if RequiredScript and not PickUpWeapons.required[RequiredScript] then
	local fname = PickUpWeapons.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	PickUpWeapons.required[RequiredScript] = true
end
