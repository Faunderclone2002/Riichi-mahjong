// Show Riichi prompt if allowed
if (!player_riichi_declared && player_has_drawn_tile && ds_list_size(player_melds) == 0) {
    draw_set_color(c_yellow);
    draw_text(MajPlayerHand.x + (ds_list_size(player_hand) * 17) / 2, MajPlayerHand.y - 24, "Press R to declare Riichi");
}

// Display win messages
if (global.game_won) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_set_alpha(1);

    if (global.can_ron == false && global.current_turn == -1) {
        // Player win
        draw_text(room_width / 2, room_height / 2, "You Win!");
		room_goto(Title);
    } else {
        // Opponent win
        if (global.opponent1_won){
			draw_text(room_width / 2, room_height / 2, "Opponent 1 Wins by Tsumo or Ron!");
			room_goto(Title);
		};
        if (global.opponent2_won){
			draw_text(room_width / 2, room_height / 2, "Opponent 2 Wins by Tsumo or Ron!");
			room_goto(Title);
		};
        if (global.opponent3_won){
			draw_text(room_width / 2, room_height / 2, "Opponent 3 Wins by Tsumo or Ron!");
			room_goto(Title);
		};
	}
}
// Visualises the game using sprites
draw_set_halign(fa_center);
var colour = make_color_rgb(250, 250, 150);
global.KanCalls = 1;
var winds = ["east", "south", "west", "north"];
var dragons = ["white", "green", "red"];

if (global.can_ron) {
    draw_text(100, 100, "Press R to call Ron!");
}

// Calculate true dora tiles from indicators
DoraTiles = ds_list_create();

for (var q = 0; q < global.KanCalls; q++) {
    var indicator = ds_list_find_value(global.dora, q);
    var dora_value = indicator.value;

    if (indicator.suit == "honors") {
        var idx = -1;

        // Check if it's a wind
        for (var i = 0; i < array_length(winds); i++) {
            if (winds[i] == dora_value) {
                idx = i;
                dora_value = winds[(idx + 1) mod array_length(winds)];
                break;
            }
        }

        // If not wind, check if it's a dragon
        if (idx == -1) {
            for (var i = 0; i < array_length(dragons); i++) {
                if (dragons[i] == dora_value) {
                    idx = i;
                    dora_value = dragons[(idx + 1) mod array_length(dragons)];
                    break;
                }
            }
        }
    } else {
        // For suited tiles, wrap from 9 to 1
        dora_value = (indicator.value mod 9) + 1;
    }

    var dora_tile = {
        suit: indicator.suit,
        value: dora_value
    };
    ds_list_add(DoraTiles, dora_tile);

    draw_sprite(MajHandSpr2, indicator.sprite_index, (10 + (q * 17)), 15);
    draw_text_transformed(40, 30, "Dora Indicator", 0.6, 0.6, 0);
}

for (var i = 0; i < ds_list_size(player_hand); i++) {
    var tile = ds_list_find_value(player_hand, i);
    var x_pos = MajPlayerHand.x + (i * 17);
    var y_pos = MajPlayerHand.y;

    var is_dora = false;
    for (var j = 0; j < ds_list_size(DoraTiles); j++) {
        var dora = ds_list_find_value(DoraTiles, j);
        if (tile.suit == dora.suit && tile.value == dora.value) {
            is_dora = true;
            break;
        }
    }

    if (i == selected_tile)
        draw_sprite_ext(MajHandSpr2, tile.sprite_index, x_pos, y_pos, 1, 1, 0, colour, 1);
    else if (is_dora)
        draw_sprite_ext(MajHandSpr2, tile.sprite_index, x_pos, y_pos, 1, 1, 0, c_yellow, 1);
    else
        draw_sprite(MajHandSpr2, tile.sprite_index, x_pos, y_pos);
}

var tiles_per_row = 10;
var row_height = 23;

for (var i = 0; i < ds_list_size(global.discard_pile); i++) {
    var tile = ds_list_find_value(global.discard_pile, i);
    var x_pos = 180 - (tiles_per_row * 17)/2 + ((i mod tiles_per_row) * 17);
    var y_pos = 240 + ((i div tiles_per_row) * row_height);
    draw_sprite(MajDiscardSpr, tile.sprite_index, x_pos, y_pos);
}

for (var i = 0; i < ds_list_size(global.opponent1_discard); i++) {
    var tile = ds_list_find_value(global.opponent1_discard, i);
    var x_pos = 70 - ((i div tiles_per_row) * row_height);
    var y_pos = 110 + ((i mod tiles_per_row) * 17);
    draw_sprite_ext(MajDiscardSpr, tile.sprite_index, x_pos, y_pos, 1, 1, 270, c_white, 1);
}

for (var i = 0; i < ds_list_size(global.opponent2_discard); i++) {
    var tile = ds_list_find_value(global.opponent2_discard, i);
    var x_pos = 180 - (tiles_per_row * 17) / 2 + ((i mod tiles_per_row) * 17);
    var y_pos = 80 - ((i div tiles_per_row) * row_height);
    draw_sprite_ext(MajDiscardSpr, tile.sprite_index, x_pos, y_pos, 1, 1, 180, c_white, 1);
}

for (var i = 0; i < ds_list_size(global.opponent3_discard); i++) {
    var tile = ds_list_find_value(global.opponent3_discard, i);
    var x_pos = 280 + ((i div tiles_per_row) * row_height);
    var y_pos = 110 + ((i mod tiles_per_row) * 17);
    draw_sprite_ext(MajDiscardSpr, tile.sprite_index, x_pos, y_pos, 1, 1, 90, c_white, 1);
}

var y_offset = 280; // adjust based on screen layout

if (global.can_pon) {
    draw_text(100, y_offset, "Press P to Pon");
    y_offset += 20;
}
if (global.can_kan) {
    draw_text(100, y_offset, "Press K to Kan");
    y_offset += 20;
}
if (global.can_chi) {
    draw_text(100, y_offset, "Press C to Chi");
}

// Draw player melds
var meld_x = MajPlayerHand.x - 80;
var meld_y = MajPlayerHand.y; 
var meld_spacing = 17;

for (var m = 0; m < ds_list_size(player_melds); m++) {
    var tile = ds_list_find_value(player_melds, m);
    draw_sprite(MajHandSpr2, tile.sprite_index, meld_x + m * meld_spacing, meld_y);
}
