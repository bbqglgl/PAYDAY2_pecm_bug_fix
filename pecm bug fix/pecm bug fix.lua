local pecm_fix__start_jammer_effect = PlayerInventory._start_jammer_effect
local pecm_fix_init = PlayerInventory.init
local pecm_fix_sync_net_event = PlayerInventory.sync_net_event

local _pecm_fix_event_id = 10
local _pecm_fix_server = false

function PlayerInventory:init(unit, ...)
	_pecm_fix_server = false

	pecm_fix_init(self, unit, ...)

	self:_send_net_event_to_host(_pecm_fix_event_id)
end

function PlayerInventory:_start_jammer_effect(...)

	--callback event delay could be rarely cause for host's pocket ecm isn't work when spamming ecm using button
	if Network:is_server() and self._jammer_data and self._jammer_data.effect == "jamming" then
		managers.enemy:remove_delayed_clbk(self._jammer_data.stop_jamming_callback_key, true)
	end

	return pecm_fix__start_jammer_effect(self, ...)
end

function PlayerInventory:sync_net_event(event_id, peer, ...)
	local net_events = self._NET_EVENTS

	if event_id == net_events.jammer_stop then
		--Host don't believe other's stop event.
		-- 1. Network delay(ping) cause to stop pecm when a client who is in the room with other 2-3 players use 2 of pecm in short term(<0.1s) 
		-- 2. Sometimes a client(not host) set that some other players pecm duration is zero. so, the client send another player's pecm stop event after start event immediately.
		-- and managers.network:session()._server_peer and managers.network:session()._server_peer == peer
		if not Network:is_server() then
			if managers.network:session()._server_peer and peer and managers.network:session()._server_peer == peer or not _pecm_fix_server then
				self:_stop_jammer_effect()
			end
		end
	elseif event_id == _pecm_fix_event_id then
		if Network:is_server() then
			self:_send_net_event(_pecm_fix_event_id)
		else
			_pecm_fix_server = true
		end
	else
		pecm_fix_sync_net_event(self, event_id, peer, ...)
	end
end
