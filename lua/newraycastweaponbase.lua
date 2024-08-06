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
	if not self._picked_up_weapon_data then
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
end)
