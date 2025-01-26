if not PickUpWeapons then
	PickUpWeapons = {}
	PickUpWeapons.mod_instance = ModInstance
	PickUpWeapons.mod_path = ModPath
	PickUpWeapons.required = {}
	PickUpWeapons.weapon_table = blt.vm.dofile(ModPath .. "req/weapons.lua")

	Hooks:Register("PickUpWeaponsCreateWeaponTable")

	function PickUpWeapons:create_pickup(weapon_unit, factory_id, weapon_id, weapon_data, total_ammo, clip_ammo, is_npc)
		local weapon_base = weapon_unit:base()

		local unit = World:spawn_unit(Idstring("units/payday2/weapons/pickup_interaction"), weapon_unit:position(), weapon_unit:rotation())

		unit:interaction().weapon_data = {
			is_npc = is_npc,
			factory_id = factory_id,
			weapon_id = weapon_id,
			blueprint = weapon_base._blueprint or weapon_data and weapon_data.blueprint,
			offsets = not weapon_base._blueprint and weapon_data and weapon_data.offsets,
			cosmetics = weapon_base._cosmetics or weapon_data and weapon_data.cosmetics,
			ammo = {
				total = total_ammo,
				clip = clip_ammo
			}
		}

		weapon_unit:link(unit)

		weapon_base:add_destroy_listener(unit:key(), function()
			if alive(unit) then
				unit:interaction():set_active(false)
				unit:set_slot(0)
			end
		end)
	end

	function PickUpWeapons:create_player_pickup(weapon_unit)
		local weapon_base = weapon_unit:base()

		local factory_weapon = tweak_data.weapon.factory[weapon_base._factory_id .. "_npc"]
		if not factory_weapon then
			log("[PickUpWeapons] Player weapon without NPC counterpart (" .. weapon_base._factory_id .. ")!")
			return
		end

		local unit_ids = Idstring("unit")
		local weapon_ids = Idstring(factory_weapon.unit)
		if not managers.dyn_resource:has_resource(unit_ids, weapon_ids, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
			managers.dyn_resource:load(unit_ids, weapon_ids, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
		end

		local player_unit = managers.player:local_player()
		local rot = mrotation.copy(player_unit:movement():m_head_rot())
		local pos = mvector3.copy(player_unit:movement():m_head_pos())

		mrotation.set_yaw_pitch_roll(rot, rot:yaw() + math.random(-30, 30), rot:pitch(), rot:roll() + math.random(-90, 90))
		mvector3.add_scaled(pos, player_unit:movement():m_head_fwd(), 25)

		local unit = World:spawn_unit(weapon_ids, pos, rot)
		unit:base():set_factory_data(weapon_base._factory_id)
		unit:base():set_cosmetics_data(weapon_base._cosmetics)
		unit:base():assemble_from_blueprint(weapon_base._factory_id, weapon_base._blueprint)
		unit:base():check_npc()

		call_on_next_update(function()
			if alive(unit) then
				unit:set_enabled(true)
				unit:base():on_enabled()
			end
		end)

		local collider_unit = World:spawn_unit(Idstring("units/payday2/weapons/box_collision/box_collision_dropped_weapon"), pos, rot)

		collider_unit:link(Idstring("rp_box_collision_weapon"), unit)

		unit:base():add_destroy_listener(unit:key(), function()
			if alive(collider_unit) then
				collider_unit:set_slot(0)
			end
		end)

		local total_ammo = weapon_base:get_ammo_total() / weapon_base:get_ammo_max()
		local clip_ammo = weapon_base:get_ammo_remaining_in_clip() / weapon_base:get_ammo_max_per_clip()

		self:create_pickup(unit, weapon_base._factory_id, weapon_base._name_id, nil, total_ammo, clip_ammo)

		collider_unit:push(1, player_unit:movement():m_head_fwd() * 1000)
	end

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
