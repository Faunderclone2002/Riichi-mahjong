ds_list_sort(player_hand, function(a, b) {
    var suit_priority = {"manzu": 0, "souzu": 1, "pinzu": 2, "honors": 3}; 
	
    if (suit_priority[a.suit] != suit_priority[b.suit]) 
	{
        return suit_priority[a.suit] - suit_priority[b.suit];
    }
    return a.value - b.value;
});

if (keyboard_check_pressed(vk_space))
{
	instance_create_layer(x,y,"Instances",MajGame);
	instance_destroy();
}

if (keyboard_check_pressed(vk_left)) {
    selected_tile = max(0, selected_tile - 1);
}

if (keyboard_check_pressed(vk_right)) {
    selected_tile = min(ds_list_size(player_hand) - 1, selected_tile + 1);
}

if (keyboard_check_pressed(vk_enter) && ds_list_size(player_hand) > 0) {
    var discarded_tile = ds_list_find_value(player_hand, selected_tile);

    ds_list_add(global.discard_pile, discarded_tile);

    ds_list_delete(player_hand, selected_tile);

    selected_tile = max(0, selected_tile - 1);
	
	if (ds_list_size(global.tile_list) > 0) {
        var new_tile = ds_list_find_value(global.tile_list, 0);
        ds_list_add(player_hand, new_tile);
        ds_list_delete(global.tile_list, 0);
    }
}

