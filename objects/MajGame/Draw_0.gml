var colour = make_color_rgb(250, 250, 150);

KanCalls = 1

for (var q = 0; q < KanCalls; q++)
{
	var dora = ds_list_find_value(global.dora, 0);
	draw_sprite(MajHandSpr, dora.sprite_index, 10,  15);
} 


for (var i = 0; i < ds_list_size(player_hand); i++)
{
    var tile = ds_list_find_value(player_hand, i);

    var x_pos = MajPlayerHand.x + (i * 17); 
    var y_pos = MajPlayerHand.y;

    if (i == selected_tile)
        draw_sprite_ext(MajHandSpr, tile.sprite_index, x_pos, y_pos, 1, 1, 0, colour, 1);
    else
        draw_sprite(MajHandSpr, tile.sprite_index, x_pos, y_pos);
}

var tiles_per_row = 13; 
var row_height = 23; 

for (var i = 0; i < ds_list_size(global.discard_pile); i++)
{
    var tile = ds_list_find_value(global.discard_pile, i);

    var x_pos = 65 + ((i mod tiles_per_row) * 17); 
    var y_pos = 0 + ((i div tiles_per_row) * row_height); 

    draw_sprite(MajDiscardSpr, tile.sprite_index, x_pos, y_pos);
}