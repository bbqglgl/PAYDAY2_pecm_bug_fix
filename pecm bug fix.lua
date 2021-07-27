local pecm_fix__start_jammer_effect = PlayerInventory._start_jammer_effect
function PlayerInventory:_start_jammer_effect(...)

	--callback event delay could be rarely cause for host's pocket ecm isn't work when spamming ecm using button
	if Network:is_server() and self._jammer_data and self._jammer_data.effect == "jamming" then
		managers.enemy:remove_delayed_clbk(self._jammer_data.stop_jamming_callback_key, true)
	end

	return pecm_fix__start_jammer_effect(self, ...)
end

function PlayerInventory:sync_net_event(event_id, peer, ...)
	local net_events = self._NET_EVENTS

	if event_id == net_events.jammer_start then
		self:_start_jammer_effect()
	elseif event_id == net_events.jammer_stop then
		--Host don't believe other's stop event.
		-- 1. Network delay(ping) cause to stop pecm when a client who is in the room with other 2-3 players use 2 of pecm in short term(<0.1s) 
		-- 2. Sometimes a client(not host) set that some other players pecm duration is zero. so, the client send another player's pecm stop event after start event immediately.
		if not Network:is_server() then
			self:_stop_jammer_effect()
		end
		----------------------------------------------
	elseif event_id == net_events.feedback_start then
		if Network:is_server() then
			self:start_feedback_effect()
		else
			self:_start_feedback_effect()
		end
	elseif event_id == net_events.feedback_stop then
		self:_stop_feedback_effect()
	end
end
