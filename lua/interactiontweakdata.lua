Hooks:PostHook(InteractionTweakData, "init", "init_pickup_weapons", function(self)
	self.weapon_pickup = {
		icon = "develop",
		text_id = "hud_int_pickup_weapon",
		action_text_id = "hud_action_pickup_weapon",
		timer = 0.75
	}
end)
