Hooks:PostHook(WeaponFactoryTweakData, "init", "init_pickup_weapons", function(self)
	self.parts.wpn_fps_upg_o_leupold.stance_mod.wpn_fps_ass_g3 = self.parts.wpn_fps_upg_o_leupold.stance_mod.wpn_fps_ass_g3 or {
		translation = Vector3(0.04, -29, -4.25)
	}
end)
