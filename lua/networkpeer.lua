local send_queued_sync_original = NetworkPeer.send_queued_sync
function NetworkPeer:send_queued_sync(func_name, arg1, arg2, arg3, ...)
	if self._has_pickup_weapons_interaction or func_name ~= "sync_teammate_progress" or arg3 ~= "weapon_pickup" then
		return send_queued_sync_original(self, func_name, arg1, arg2, arg3, ...)
	end
end
