Hooks:PreHook(NewRaycastWeaponBase, "assemble", "assemble_pickup_weapons", function(self)
	self._picked_up_weapon_data = PickUpWeapons._picked_up_weapon_data
end)

Hooks:PreHook(NewRaycastWeaponBase, "assemble_from_blueprint", "assemble_from_blueprint_pickup_weapons", function(self)
	self._picked_up_weapon_data = PickUpWeapons._picked_up_weapon_data
end)

Hooks:PostHook(NewRaycastWeaponBase, "replenish", "replenish_pickup_weapons", function(self)
	if not self._picked_up_weapon_data then
		return
	end

	local total = math.round(self._picked_up_weapon_data.ammo.total * self:get_ammo_max())
	local clip = math.round(self._picked_up_weapon_data.ammo.clip * self:get_ammo_remaining_in_clip())

	self:set_ammo_total(math.min(total, self:get_ammo_max()))
	self:set_ammo_remaining_in_clip(math.min(total, clip, self:get_ammo_remaining_in_clip()))
end)

Hooks:PostHook(NewRaycastWeaponBase, "clbk_assembly_complete", "clbk_assembly_complete_pickup_weapons", function(self)
	if not self._picked_up_weapon_data or not self._picked_up_weapon_data.is_npc then
		return
	end

	local colors = {
		laser = Color(1, 0, 0),
		flashlight = Color(1, 1, 1)
	}

	for _, part_data in pairs(self._parts) do
		local gadget_type = alive(part_data.unit) and part_data.unit:base() and part_data.unit:base().GADGET_TYPE
		if colors[gadget_type] then
			part_data.unit:base():set_color(colors[gadget_type])
		end
	end

	if not self._picked_up_weapon_data.offsets then
		return
	end

	for part_id, offset_data in pairs(self._picked_up_weapon_data.offsets) do
		local part_unit = self._parts[part_id] and self._parts[part_id].unit
		if alive(part_unit) then
			if offset_data.translation then
				part_unit:set_local_position(offset_data.translation)
			end
			if offset_data.rotation then
				part_unit:set_local_rotation(offset_data.rotation)
			end
		end
	end
end)

Hooks:PostHook(NewRaycastWeaponBase, "_get_spread", "_get_spread_weapons", function(self)
	if self._picked_up_weapon_data and self._picked_up_weapon_data.is_npc and not self._rays then
		local spread_x, spread_y = Hooks:GetReturn()
		return spread_x * 0.65, spread_y * 0.65
	end
end)
