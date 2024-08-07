if not PickUpWeapons then
	PickUpWeapons = {}
	PickUpWeapons.mod_instance = ModInstance
	PickUpWeapons.mod_path = ModPath
	PickUpWeapons.required = {}
	PickUpWeapons.weapon_table = blt.vm.dofile(ModPath .. "req/weapons.lua")

	function PickUpWeapons:create_pickup(weapon_unit, factory_id, weapon_id, weapon_data, total_ammo, clip_ammo)
		local weapon_base = weapon_unit:base()

		local unit = World:spawn_unit(Idstring("units/payday2/weapons/pickup_interaction"), weapon_unit:position(), weapon_unit:rotation())

		unit:interaction().weapon_data = {
			factory_id = factory_id,
			localization_id = tweak_data.weapon[weapon_id].name_id,
			blueprint = weapon_base._blueprint or weapon_data and weapon_data.blueprint,
			offsets = not weapon_base._blueprint and weapon_data and weapon_data.offsets,
			cosmetics = weapon_base._cosmetics or weapon_data and weapon_data.cosmetics,
			ammo = {
				total = total_ammo or math.rand(0.2, 0.4),
				clip = clip_ammo or math.rand(0, 1)
			}
		}

		weapon_unit:link(unit)

		weapon_base:add_destroy_listener(unit:key(), function()
			unit:interaction():set_active(false)
			unit:set_slot(0)
		end)
	end

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
