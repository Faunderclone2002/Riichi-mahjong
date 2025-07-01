// Opponent hands
Opponent1 = ds_list_create();
Opponent2 = ds_list_create();
Opponent3 = ds_list_create();
global.opponent1_riichi_declared = false;
global.opponent2_riichi_declared = false;
global.opponent3_riichi_declared = false;

global.game_won = false;
global.opponent1_won = false;
global.opponent2_won = false;
global.opponent3_won = false;

// Player hand and selection
player_hand = ds_list_create();
selected_tile = 0;
player_melds = ds_list_create();
player_has_drawn_tile = false;
player_riichi_declared = false;

// Game turn and discard data
global.can_ron = false;
global.ron_yaku = [];
global.current_turn = 0;
global.last_discarded_tile = undefined;
global.declared_riichi = false;

global.call_chi = ds_list_create();
global.call_pon = ds_list_create();
global.call_kan = ds_list_create();

global.can_chi = false;
global.can_pon = false;
global.can_kan = false;

global.discard_pile = ds_list_create();
global.tile_list = ds_list_create();
global.opponent1_discard = ds_list_create();
global.opponent2_discard = ds_list_create();
global.opponent3_discard = ds_list_create();

function ds_map_keys(the_map) {
    var keys = [];
    var key = ds_map_find_first(the_map);

    while (!is_undefined(key)) {
        array_push(keys, key);
        key = ds_map_find_next(the_map, key);
    }

    return keys;
}

function can_form_four_melds(count_map) {
    var melds = 0;

    while (true) {
        var keys = ds_map_keys(count_map);
        var found_meld = false;

        for (var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            var suit = string_copy(key, 1, 5);
            var value = real(string_delete(key, 1, 5));
            var count = ds_map_find_value(count_map, key);

            // Try triplet
            if (count >= 3) {
                ds_map_replace(count_map, key, count - 3);
                if (ds_map_find_value(count_map, key) == 0) ds_map_delete(count_map, key);
                melds++;
                found_meld = true;
                break;
            }

            // Try sequence (numbered suits only)
            if (suit != "honor" && value <= 7) {
                var k1 = suit + string(value + 1);
                var k2 = suit + string(value + 2);
                if (ds_map_exists(count_map, k1) && ds_map_exists(count_map, k2)) {
                    ds_map_replace(count_map, key, count - 1);
                    ds_map_replace(count_map, k1, ds_map_find_value(count_map, k1) - 1);
                    ds_map_replace(count_map, k2, ds_map_find_value(count_map, k2) - 1);

                    // Clean up zeroed entries
                    if (ds_map_find_value(count_map, key) == 0) ds_map_delete(count_map, key);
                    if (ds_map_find_value(count_map, k1) == 0) ds_map_delete(count_map, k1);
                    if (ds_map_find_value(count_map, k2) == 0) ds_map_delete(count_map, k2);

                    melds++;
                    found_meld = true;
                    break;
                }
            }
        }

        if (!found_meld) break;
    }

    return (melds == 4);
}

function is_standard_hand(hand) {
    var tile_counts = ds_map_create();

    // Count each tile
    for (var i = 0; i < ds_list_size(hand); i++) {
        var t = ds_list_find_value(hand, i);
        var key = t.suit + ":" + string(t.value);
        if (!ds_map_exists(tile_counts, key)) {
            ds_map_add(tile_counts, key, 1);
        } else {
            ds_map_replace(tile_counts, key, ds_map_find_value(tile_counts, key) + 1);
        }
    }

    // Collect all keys manually
    var keys = [];
    var k = ds_map_find_first(tile_counts);
    while (!is_undefined(k)) {
        array_push(keys, k);
        k = ds_map_find_next(tile_counts, k);
    }

    var result = false;

    // Try all possible pairs
    for (var i = 0; i < array_length(keys); i++) {
        var test_map = ds_map_create();
		ds_map_copy(test_map, tile_counts);
        var key = keys[i];

        if (ds_map_find_value(test_map, key) >= 2) {
            ds_map_replace(test_map, key, ds_map_find_value(test_map, key) - 2);
            if (ds_map_find_value(test_map, key) == 0) ds_map_delete(test_map, key);

            if (can_form_four_melds(test_map)) {
                result = true;
                ds_map_destroy(test_map);
                break;
            }
        }
        ds_map_destroy(test_map);
    }

    ds_map_destroy(tile_counts);
    return result;
}

// Utility function to find the index of a value in an array
function array_find_index(array, value) {
    for (var i = 0; i < array_length(array); i++) {
        if (array[i] == value) return i;
    }
    return -1; // Return -1 if not found
}

function array_contains(arr, val) {
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i] == val) return true;
    }
    return false;
}

function is_kokushi(hand) {
    var terminals = [
        {suit:"manzu", value:1}, {suit:"manzu", value:9},
        {suit:"pinzu", value:1}, {suit:"pinzu", value:9},
        {suit:"souzu", value:1}, {suit:"souzu", value:9},
        {suit:"honors", value:"east"}, {suit:"honors", value:"south"},
        {suit:"honors", value:"west"}, {suit:"honors", value:"north"},
        {suit:"honors", value:"white"}, {suit:"honors", value:"green"}, {suit:"honors", value:"red"}
    ];
    var match = 0;
    var pair_found = false;
    for (var i = 0; i < array_length(terminals); i++) {
        var count = 0;
        for (var j = 0; j < ds_list_size(hand); j++) {
            var t = ds_list_find_value(hand, j);
            if (t.suit == terminals[i].suit && t.value == terminals[i].value) count++;
        }
        if (count > 0) match++;
        if (count > 1) pair_found = true;
    }
    return match == 13 && pair_found;
}
function is_daisangen(hand) {
    var dragons = ["white", "green", "red"], matches = 0;
    for (var d = 0; d < 3; d++) {
        var count = 0;
        for (var i = 0; i < ds_list_size(hand); i++) {
            var t = ds_list_find_value(hand, i);
            if (t.suit == "honors" && t.value == dragons[d]) count++;
        }
        if (count >= 3) matches++;
    }
    return matches == 3;
}

function is_shousuushii(hand) {
    var winds = ["east", "south", "west", "north"];
    var trip = 0, pair = 0;
    for (var w = 0; w < 4; w++) {
        var count = 0;
        for (var i = 0; i < ds_list_size(hand); i++) {
            var t = ds_list_find_value(hand, i);
            if (t.suit == "honors" && t.value == winds[w]) count++;
        }
        if (count >= 3) trip++;
        else if (count == 2) pair++;
    }
    return (trip == 3 && pair == 1);
}

function is_daisuushii(hand) {
    var winds = ["east", "south", "west", "north"];
    var trip = 0;
    for (var w = 0; w < 4; w++) {
        var count = 0;
        for (var i = 0; i < ds_list_size(hand); i++) {
            var t = ds_list_find_value(hand, i);
            if (t.suit == "honors" && t.value == winds[w]) count++;
        }
        if (count >= 3) trip++;
    }
    return trip == 4;
}

function is_chinroutou(hand) {
    for (var i = 0; i < ds_list_size(hand); i++) {
        var t = ds_list_find_value(hand, i);
        if (t.suit == "honors" || (t.value != 1 && t.value != 9)) return false;
    }
    return true;
}

function is_tsuuiisou(hand) {
    for (var i = 0; i < ds_list_size(hand); i++) {
        if (ds_list_find_value(hand, i).suit != "honors") return false;
    }
    return true;
}

function is_ryuisou(hand) {
    var green_vals = [2, 3, 4, 6, 8];
    for (var i = 0; i < ds_list_size(hand); i++) {
        var t = ds_list_find_value(hand, i);
        if (t.suit == "souzu") {
            if (array_find_index(green_vals, t.value) == -1) return false;
        } else if (!(t.suit == "honors" && t.value == "green")) {
            return false;
        }
    }
    return true;
}

function is_suuankou(hand) {
    var keys = [];
    var values = [];

    // Count how many of each tile appears
    for (var i = 0; i < ds_list_size(hand); i++) {
        var tile = ds_list_find_value(hand, i);
        var key = tile.suit + string(tile.value);

        var index = array_find_index(keys, key);
        if (index == -1) {
            array_push(keys, key);
            array_push(values, 1);
        } else {
            values[index] += 1;
        }
    }

    // Count triplets
    var triples = 0;
    for (var j = 0; j < array_length(values); j++) {
        if (values[j] >= 3) triples++;
    }

    return triples >= 4;
}

function is_suu_kantsu(hand) {
    var keys = [];
    var values = [];

    // Count how many times each tile appears
    for (var i = 0; i < ds_list_size(hand); i++) {
        var t = ds_list_find_value(hand, i);
        var key = t.suit + string(t.value);

        var index = array_find_index(keys, key);
        if (index == -1) {
            array_push(keys, key);
            array_push(values, 1);
        } else {
            values[index] += 1;
        }
    }

    // Count quads (kan)
    var kans = 0;
    for (var j = 0; j < array_length(values); j++) {
        if (values[j] == 4) kans++;
    }

    return kans == 4;
}


function check_yaku(hand_list) {
    var yaku_found = [];

    // Yakuman
    if (is_kokushi(hand_list))            array_push(yaku_found, "Kokushi Musou (Thirteen Orphans)");
    if (is_suuankou(hand_list))           array_push(yaku_found, "Suuankou (4 Concealed Triplets)");
    if (is_daisangen(hand_list))          array_push(yaku_found, "Daisangen (Big Three Dragons)");
    if (is_shousuushii(hand_list))        array_push(yaku_found, "Shousuushii (Little Four Winds)");
    if (is_daisuushii(hand_list))         array_push(yaku_found, "Daisuushii (Big Four Winds)");
    if (is_chinroutou(hand_list))         array_push(yaku_found, "Chinroutou (All Terminals)");
    if (is_tsuuiisou(hand_list))          array_push(yaku_found, "Tsuuiisou (All Honors)");
    if (is_ryuisou(hand_list))            array_push(yaku_found, "Ryuuiisou (All Green)");
    if (is_suu_kantsu(hand_list))         array_push(yaku_found, "Suu Kantsu (Four Kans)");

    // Add standard Riichi if declared and the hand is a standard 4 meld + 1 pair
    if (is_standard_hand(hand_list)) {
        array_push(yaku_found, "Riichi");
    }

    return yaku_found;
}

// Define honors and suit order to map data and sprite logic
var honor_tiles = ["east", "south", "west", "north", "white", "green", "red"];
var suit_order = ["manzu", "souzu", "pinzu", "honors"];

// Tile initialization loop (136 tiles = 34 types × 4 copies)
for (var i = 0; i < 136; i++) {
    tile_number = ((i div 4) mod 9) + 1; // For numbered suits: 1–9
    var tile_suit;

    // Determine the tile's suit based on index range
    if (i < 36) tile_suit = "manzu";
    else if (i < 72) tile_suit = "souzu";
    else if (i < 108) tile_suit = "pinzu";
    else tile_suit = "honors";

    var honor_index = -1;

    // For honors, compute the proper index in the honor array
    if (tile_suit == "honors") {
        honor_index = ((i - 108) div 4);
        if (honor_index >= array_length(honor_tiles))
            honor_index = (i - 108) mod 7; // Fallback in case of overflow
    }

    // Calculate sprite index for rendering based on suit and order
    var sprite_x = (tile_suit == "honors")
        ? 108 + (honor_index * 4) + (i mod 4)  // Honors follow a different mapping
        : (array_find_index(suit_order, tile_suit) * 36) + ((tile_number - 1) * 4) + (i mod 4);

    // Pack tile data into a struct
    var tile_data = {
        suit: tile_suit,
        value: (tile_suit == "honors") ? honor_tiles[honor_index] : tile_number,
        sprite_index: sprite_x
    };

    // Add the tile to the global tile list
    ds_list_add(global.tile_list, tile_data);
}

// Shuffle the complete tile wall
ds_list_shuffle(global.tile_list);

// Create Opponent1 hand
Opponent1 = ds_list_create();
for (var i = 0; i < 13; i++) {
    var drawn_tile1 = ds_list_find_value(global.tile_list, 0);
    ds_list_add(Opponent1, drawn_tile1);
    ds_list_delete(global.tile_list, 0);
}

// Create Opponent2 hand
Opponent2 = ds_list_create();
for (var i = 0; i < 13; i++) {
    var drawn_tile2 = ds_list_find_value(global.tile_list, 0);
    ds_list_add(Opponent2, drawn_tile2);
    ds_list_delete(global.tile_list, 0);
}

// Create Opponent3 hand
Opponent3 = ds_list_create();
for (var i = 0; i < 13; i++) {
    var drawn_tile3 = ds_list_find_value(global.tile_list, 0);
    ds_list_add(Opponent3, drawn_tile3);
    ds_list_delete(global.tile_list, 0);
}

// Reserve tiles for the dead wall (not draw-able in normal turns)
global.deadwall = ds_list_create();
for (var c = 0; c < 16; c++) {
    var dead_tile = ds_list_find_value(global.tile_list, 0);
    ds_list_add(global.deadwall, dead_tile);
    ds_list_delete(global.tile_list, 0);
}

// Draw dora indicators from the dead wall
global.dora = ds_list_create();
for (var d = 0; d < 5; d++) {
    var dora = ds_list_find_value(global.deadwall, 0);
    ds_list_add(global.dora, dora);
    ds_list_delete(global.deadwall, 0);
}

// Create the player’s hand
player_hand = ds_list_create();
for (var i = 0; i < 13; i++) {
    var drawn_tile = ds_list_find_value(global.tile_list, 0);
    ds_list_add(player_hand, drawn_tile);
    ds_list_delete(global.tile_list, 0);
}
