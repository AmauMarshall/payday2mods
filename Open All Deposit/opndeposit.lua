local inter_list = {
	"pick_lock_deposit_transport",
	"pick_lock_hard_no_skill"
}

for _, seeked_tweak in ipairs(inter_list) do
	local act_list = {}
	for _, unit in pairs(managers.interaction._interactive_units) do
		local interaction = unit:interaction()
		local tweak = interaction.tweak_data
		if tweak == seeked_tweak then
			table.insert(act_list, unit)
		end
	end

	for _, unit in ipairs(act_list) do
		local player = managers.player:player_unit()
		local interaction = unit:interaction()
		interaction:interact(player)
	end
end