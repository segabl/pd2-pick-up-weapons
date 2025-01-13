Hooks:PreHook(CopInventory, "drop_weapon", "drop_weapon_pickup_weapons", function(self)
	local weapon = self:equipped_unit()
	if not alive(weapon) then
		return
	end

	if not self._unit:character_damage():dead() then
		log("[PickUpWeapons] Unit that's still alive dropped their weapon!")
		return
	end

	local weapon_base = weapon:base()
	local weapon_id = weapon_base.non_npc_name_id and weapon_base:non_npc_name_id() or weapon_base._name_id
	weapon_id = weapon_id and weapon_id:gsub("_smg$", ""):gsub("_lmg$", ""):gsub("_ass$", "")
	local weapon_data = PickUpWeapons.weapon_table[weapon:name():key()] or PickUpWeapons.weapon_table[weapon_id]
	weapon_id = weapon_data and weapon_data.id or weapon_id
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	if factory_id then
		PickUpWeapons:create_pickup(weapon, factory_id, weapon_id, weapon_data, math.rand(0.2, 0.4), math.rand(0, 1), true)
	end
end)
