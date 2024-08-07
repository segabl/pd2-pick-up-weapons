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
	macros.WEAPON = managers.localization:text(tweak_data.weapon[self.weapon_data.weapon_id].name_id)
end

function PickUpWeaponInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	self.super.interact(self, player)

	local selection_index = tweak_data.weapon[self.weapon_data.weapon_id].use_data.selection_index
	local replace_weapon = player:inventory():unit_by_selection(selection_index)
	if alive(replace_weapon) then
		replace_weapon:base():on_disabled()
	end

	local texture_switches = {}
	for _, part_id in pairs(self.weapon_data.blueprint or {}) do
		if tweak_data.gui.part_texture_switches[part_id] then
			texture_switches[part_id] = tweak_data.gui.part_texture_switches[part_id]
		elseif tweak_data.weapon.factory.parts[part_id].texture_switch then
			texture_switches[part_id] = tweak_data.gui.default_part_texture_switch
		end
	end

	PickUpWeapons._picked_up_weapon_data = self.weapon_data
	player:inventory():add_unit_by_factory_name(self.weapon_data.factory_id, true, false, self.weapon_data.blueprint, self.weapon_data.cosmetics, texture_switches)
	PickUpWeapons._picked_up_weapon_data = nil

	if alive(self._unit:parent()) then
		self._unit:parent():set_slot(0)
		if alive(self._unit:parent():base()._second_gun) then
			self._unit:parent():base()._second_gun:set_slot(0)
		end
	end
end
