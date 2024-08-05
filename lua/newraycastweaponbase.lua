Hooks:PreHook(NewRaycastWeaponBase, "assemble", "assemble_pickup_weapons", function(self)
	self._picked_up_weapon = PickUpWeapons._picked_up_weapon
end)

Hooks:PreHook(NewRaycastWeaponBase, "assemble_from_blueprint", "assemble_from_blueprint_pickup_weapons", function(self)
	self._picked_up_weapon = PickUpWeapons._picked_up_weapon
end)

Hooks:PostHook(NewRaycastWeaponBase, "replenish", "replenish_pickup_weapons", function(self)
	if not self._picked_up_weapon then
		return
	end

	if not self._random_ammo_data then
		self._random_ammo_data = {
			total = math.round(self:get_ammo_max() * math.rand(0.2, 0.4)),
			clip = math.round(self:get_ammo_max_per_clip() * math.rand(0, 1))
		}
	end

	self:set_ammo_total(math.min(self._random_ammo_data.total, self:get_ammo_max()))
	self:set_ammo_remaining_in_clip(math.min(self._random_ammo_data.total, self._random_ammo_data.clip, self:get_ammo_remaining_in_clip()))
end)

Hooks:PostHook(NewRaycastWeaponBase, "clbk_assembly_complete", "clbk_assembly_complete_pickup_weapons", function(self)
	if not self._picked_up_weapon then
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
