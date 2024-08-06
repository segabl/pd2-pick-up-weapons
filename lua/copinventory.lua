Hooks:PreHook(CopInventory, "drop_weapon", "drop_weapon_pickup_weapons", function(self)
	local weapon = self:equipped_unit()
	if not alive(weapon) then
		return
	end

	local weapon_base = weapon:base()
	local name_id = weapon_base.non_npc_name_id and weapon_base:non_npc_name_id() or weapon_base._name_id
	name_id = name_id and name_id:gsub("_smg$", ""):gsub("_lmg$", ""):gsub("_ass$", "")
	local weapon_data = PickUpWeapons.weapon_table[weapon:name():key()] or PickUpWeapons.weapon_table[name_id]
	name_id = weapon_data and weapon_data.id or name_id
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name_id)
	if not factory_id then
		return
	end

	local unit = World:spawn_unit(Idstring("units/payday2/weapons/pickup_interaction"), weapon:position(), weapon:rotation())
	local interaction = unit:interaction()
	interaction.weapon_data = {
		factory_id = factory_id,
		localization_id = tweak_data.weapon[name_id].name_id,
		blueprint = weapon_base._blueprint or weapon_data and weapon_data.blueprint,
		cosmetics = weapon_base._cosmetics or weapon_data and weapon_data.cosmetics,
		ammo = {
			total = math.rand(0.2, 0.4),
			clip = math.rand(0, 1)
		}
	}

	weapon:link(unit)

	weapon_base:add_destroy_listener(unit:key(), function()
		unit:interaction():set_active(false)
		unit:set_slot(0)
	end)
end)
