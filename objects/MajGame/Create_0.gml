function array_find_index(array, value) {
    for (var i = 0; i < array_length(array); i++) {
        if (array[i] == value) return i;
    }
    return -1; 
}

selected_tile = 0;
global.discard_pile = ds_list_create();
global.tile_list = ds_list_create();

var honor_tiles = ["east", "south", "west", "north", "white", "green", "red"];
var suit_order = ["manzu", "souzu", "pinzu", "honors"];

for (var i = 0; i < 136; i++) {
    var tile_number = ((i div 4) mod 9) + 1;
    var tile_suit;

    if (i < 36) tile_suit = "manzu";
    else if (i < 72) tile_suit = "souzu";
    else if (i < 108) tile_suit = "pinzu";
    else tile_suit = "honors";

    var honor_index = -1;

    if (tile_suit == "honors") {
        honor_index = ((i - 108) div 4);
        if (honor_index >= array_length(honor_tiles)) honor_index = (i - 108) mod 7;
    }

    var sprite_x = (tile_suit == "honors") 
        ? 108 + (honor_index * 4) + (i mod 4)
        : (array_find_index(suit_order, tile_suit) * 36) + ((tile_number - 1) * 4) + (i mod 4);

    var tile_data = {
        suit: tile_suit,
        value: (tile_suit == "honors") ? honor_tiles[honor_index] : tile_number,
        sprite_index: sprite_x
    };

    ds_list_add(global.tile_list, tile_data);
}

ds_list_shuffle(global.tile_list);

global.deadwall = ds_list_create();

for (var c = 0; c < 14; c++)
{
	var dead_tile = ds_list_find_value(global.tile_list, 0);
	ds_list_add(global.deadwall, dead_tile);
	ds_list_delete(global.tile_list, 0);
}

global.dora = ds_list_create();

for (var d = 0; d < 10; d++)
{
	var dora = ds_list_find_value(global.deadwall, 5);
	ds_list_add(global.dora, dora);
	ds_list_delete(global.deadwall, 0);
}

player_hand = ds_list_create();
for (var i = 0; i < 13; i++) 
{
    var drawn_tile = ds_list_find_value(global.tile_list, 0); 
    ds_list_add(player_hand, drawn_tile);
    ds_list_delete(global.tile_list, 0); 
}