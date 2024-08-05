Hooks:PreHook(CopInventory, "drop_weapon", "drop_weapon_pickup_weapons", function(self)
	local weapon = self:equipped_unit()
	if not alive(weapon) then
		return
	end

	local name_id = weapon:base().non_npc_name_id and weapon:base():non_npc_name_id() or weapon:base()._name_id
	name_id = name_id and name_id:gsub("_smg$", ""):gsub("_lmg$", ""):gsub("_ass$", "")
	local weapon_data = PickUpWeapons.weapon_table[weapon:name():key()] or PickUpWeapons.weapon_table[name_id]
	name_id = weapon_data and weapon_data.id or name_id
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name_id)
	if not factory_id then
		return
	end

	local unit = World:spawn_unit(Idstring("units/payday2/weapons/pickup_interaction"), weapon:position(), weapon:rotation())

	local interaction = unit:interaction()
	interaction.loc_name_id = tweak_data.weapon[name_id].name_id
	interaction.factory_id = factory_id
	interaction.blueprint = weapon_data and weapon_data.blueprint
	interaction.cosmetics = weapon_data and weapon_data.cosmetics

	weapon:link(unit)

	weapon:base():add_destroy_listener(unit:key(), function()
		unit:interaction():set_active(false)
		unit:set_slot(0)
	end)
end)
