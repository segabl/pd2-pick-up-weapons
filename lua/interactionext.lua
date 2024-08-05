PickUpWeaponInteractionExt = PickUpWeaponInteractionExt or class(BaseInteractionExt)

function PickUpWeaponInteractionExt:unselect()
	self.super.unselect(self)
	managers.hud:remove_interact()
end

function PickUpWeaponInteractionExt:_update_interact_position()
	if alive(self._unit:parent()) and self._unit:parent():moving() then
		self._interact_position = self._unit:parent():position()
	end
end

function PickUpWeaponInteractionExt:_add_string_macros(macros)
	self.super._add_string_macros(self, macros)
	macros.WEAPON = managers.localization:text(self.loc_name_id)
end

function PickUpWeaponInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	self.super.interact(self, player)

	local texture_switches = {}
	for _, part_id in pairs(self.blueprint or {}) do
		if tweak_data.gui.part_texture_switches[part_id] then
			texture_switches[part_id] = tweak_data.gui.part_texture_switches[part_id]
		elseif tweak_data.weapon.factory.parts[part_id].texture_switch then
			texture_switches[part_id] = tweak_data.gui.default_part_texture_switch
		end
	end

	PickUpWeapons._picked_up_weapon = true
	player:inventory():add_unit_by_factory_name(self.factory_id, true, false, self.blueprint, self.cosmetics, texture_switches)
	PickUpWeapons._picked_up_weapon = nil

	if alive(self._unit:parent()) then
		self._unit:parent():set_slot(0)
		if alive(self._unit:parent():base()._second_gun) then
			self._unit:parent():base()._second_gun:set_slot(0)
		end
	end
end
