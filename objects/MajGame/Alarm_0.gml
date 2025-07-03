// 🀄 Opponent 1 Turn
if (global.current_turn == 1) {

    // 🂡 Draw tile
    if (ds_list_size(global.tile_list) > 0) {
        var tile = ds_list_find_value(global.tile_list, 0);
        ds_list_add(Opponent1, tile);
        ds_list_delete(global.tile_list, 0);
    }

    // 🀄 Check for Tsumo (self-draw win)
    if (ds_list_size(Opponent1) >= 14) {
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(Opponent1); i++) {
            ds_list_add(temp_win, ds_list_find_value(Opponent1, i));
        }
        var win_yaku = check_yaku(temp_win);
        ds_list_destroy(temp_win);

        if (array_length(win_yaku) > 0) {
            show_debug_message("Opponent1 wins by Tsumo! Yaku: " + string(win_yaku));
            global.opponent1_won = true;
            global.points -= 1000;
            global.current_turn = -1;
            alarm[0] = -1;
            exit;
        }
    }

    // 🀐 Check for Riichi declaration
    if (!global.opponent1_riichi_declared && ds_list_size(Opponent1) == 14) {
        for (var d = 0; d < ds_list_size(Opponent1); d++) {
            var test_hand = ds_list_create();
            for (var c = 0; c < ds_list_size(Opponent1); c++) {
                if (c != d) ds_list_add(test_hand, ds_list_find_value(Opponent1, c));
            }
            var yaku = check_yaku(test_hand);
            ds_list_destroy(test_hand);
            if (array_length(yaku) > 0) {
                global.opponent1_riichi_declared = true;
                global.points -= 1000;
                show_debug_message("Opponent1 declares Riichi!");
                break;
            }
        }
    }

    // 🀘 Discard tile
    if (ds_list_size(Opponent1) > 0) {
        var discard_index = irandom(ds_list_size(Opponent1) - 1);
        var discarded_tile = ds_list_find_value(Opponent1, discard_index);
        ds_list_add(global.opponent1_discard, discarded_tile);
        ds_list_delete(Opponent1, discard_index);
        global.last_discarded_tile = discarded_tile;

        // 🀀 Ron check for player
        var ron_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(ron_hand, ds_list_find_value(player_hand, i));
        }
        ds_list_add(ron_hand, discarded_tile);
        var ron_yaku = check_yaku(ron_hand);
        ds_list_destroy(ron_hand);

        global.can_ron = array_length(ron_yaku) > 0;
        global.ron_yaku = ron_yaku;

        // 🔍 Call check: Pon / Kan / Chi
        global.can_pon = false;
        global.can_kan = false;
        global.can_chi = false;
        ds_list_clear(global.call_pon);
        ds_list_clear(global.call_kan);
        ds_list_clear(global.call_chi);

        // Pon & Kan candidates
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            var tile = ds_list_find_value(player_hand, i);
            if (tile.suit == discarded_tile.suit && tile.value == discarded_tile.value) {
                ds_list_add(global.call_pon, tile);
                ds_list_add(global.call_kan, tile);
            }
        }

        if (ds_list_size(global.call_pon) >= 2) global.can_pon = true;
        if (ds_list_size(global.call_kan) >= 3) global.can_kan = true;

        // Chi logic (numbered suits only)
        if (discarded_tile.suit != "honors" && array_contains(["manzu", "souzu", "pinzu"], discarded_tile.suit)) {
            var val = discarded_tile.value;
            for (var offset = -2; offset <= 0; offset++) {
                var a = val + offset;
                var b = val + offset + 1;
                var c = val + offset + 2;
                if (a >= 1 && c <= 9) {
                    var found_a = -1, found_b = -1;
                    for (var j = 0; j < ds_list_size(player_hand); j++) {
                        var t = ds_list_find_value(player_hand, j);
                        if (t.suit == discarded_tile.suit && t.value == a && found_a == -1) found_a = j;
                        else if (t.suit == discarded_tile.suit && t.value == b && found_b == -1) found_b = j;
                    }
                    if (found_a != -1 && found_b != -1) {
                        global.can_chi = true;
                        ds_list_add(global.call_chi, ds_list_find_value(player_hand, found_a));
                        ds_list_add(global.call_chi, ds_list_find_value(player_hand, found_b));
                        break;
                    }
                }
            }
        }

        // 🔔 Next turn (wait for player response if applicable)
        global.current_turn = (global.can_ron || global.can_pon || global.can_kan || global.can_chi) ? 0 : 2;
        if (global.current_turn != 0) alarm[0] = 30;
    }
}

// 🀄 Opponent 2 Turn
else if (global.current_turn == 2) {

    // 🂡 Draw tile
    if (ds_list_size(global.tile_list) > 0) {
        var tile = ds_list_find_value(global.tile_list, 0);
        ds_list_add(Opponent2, tile);
        ds_list_delete(global.tile_list, 0);
    }

    // 🀄 Tsumo check
    if (ds_list_size(Opponent2) >= 14) {
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(Opponent2); i++) {
            ds_list_add(temp_win, ds_list_find_value(Opponent2, i));
        }
        var win_yaku = check_yaku(temp_win);
        ds_list_destroy(temp_win);

        if (array_length(win_yaku) > 0) {
            show_debug_message("Opponent2 wins by Tsumo! Yaku: " + string(win_yaku));
            global.opponent2_won = true;
            global.points -= 1000;
            global.current_turn = -1;
            alarm[0] = -1;
            exit;
        }
    }

    // 🀐 Riichi check
    if (!global.opponent2_riichi_declared && ds_list_size(Opponent2) == 14) {
        for (var d = 0; d < ds_list_size(Opponent2); d++) {
            var test_hand = ds_list_create();
            for (var c = 0; c < ds_list_size(Opponent2); c++) {
                if (c != d) ds_list_add(test_hand, ds_list_find_value(Opponent2, c));
            }
            var yaku = check_yaku(test_hand);
            ds_list_destroy(test_hand);

            if (array_length(yaku) > 0) {
                global.opponent2_riichi_declared = true;
                global.points -= 1000;
                show_debug_message("Opponent2 declares Riichi!");
                break;
            }
        }
    }

    // 🂽 Discard tile
    if (ds_list_size(Opponent2) > 0) {
        var discard_index = irandom(ds_list_size(Opponent2) - 1);
        var discarded_tile = ds_list_find_value(Opponent2, discard_index);
        ds_list_add(global.opponent2_discard, discarded_tile);
        ds_list_delete(Opponent2, discard_index);
        global.last_discarded_tile = discarded_tile;

        // 🀀 Ron check for player
        var ron_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(ron_hand, ds_list_find_value(player_hand, i));
        }
        ds_list_add(ron_hand, discarded_tile);
        var ron_yaku = check_yaku(ron_hand);
        ds_list_destroy(ron_hand);

        global.can_ron = array_length(ron_yaku) > 0;
        global.ron_yaku = ron_yaku;

        // ♟️ Tile call checks
        global.can_pon = false;
        global.can_kan = false;
        global.can_chi = false;
        ds_list_clear(global.call_pon);
        ds_list_clear(global.call_kan);
        ds_list_clear(global.call_chi);

        for (var i = 0; i < ds_list_size(player_hand); i++) {
            var tile = ds_list_find_value(player_hand, i);
            if (tile.suit == discarded_tile.suit && tile.value == discarded_tile.value) {
                ds_list_add(global.call_pon, tile);
                ds_list_add(global.call_kan, tile);
            }
        }

        if (ds_list_size(global.call_pon) >= 2) global.can_pon = true;
        if (ds_list_size(global.call_kan) >= 3) global.can_kan = true;

        // 🔄 Turn handling
        global.current_turn = (global.can_ron || global.can_pon || global.can_kan) ? 0 : 3;
        if (global.current_turn != 0) alarm[0] = 30;
    }
}
// 🀄 Opponent 3 Turn
else if (global.current_turn == 3) {

    // 🂡 Draw tile
    if (ds_list_size(global.tile_list) > 0) {
        var tile = ds_list_find_value(global.tile_list, 0);
        ds_list_add(Opponent3, tile);
        ds_list_delete(global.tile_list, 0);
    }

    // 🀄 Tsumo check
    if (ds_list_size(Opponent3) >= 14) {
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(Opponent3); i++) {
            ds_list_add(temp_win, ds_list_find_value(Opponent3, i));
        }
        var win_yaku = check_yaku(temp_win);
        ds_list_destroy(temp_win);

        if (array_length(win_yaku) > 0) {
            show_debug_message("Opponent3 wins by Tsumo! Yaku: " + string(win_yaku));
            global.opponent3_won = true;
            global.points -= 1000;
            global.current_turn = -1;
            alarm[0] = -1;
            exit;
        }
    }

    // 🀐 Riichi check
    if (!global.opponent3_riichi_declared && ds_list_size(Opponent3) == 14) {
        for (var d = 0; d < ds_list_size(Opponent3); d++) {
            var test_hand = ds_list_create();
            for (var c = 0; c < ds_list_size(Opponent3); c++) {
                if (c != d) ds_list_add(test_hand, ds_list_find_value(Opponent3, c));
            }
            var yaku = check_yaku(test_hand);
            ds_list_destroy(test_hand);

            if (array_length(yaku) > 0) {
                global.opponent3_riichi_declared = true;
                global.points -= 1000;
                show_debug_message("Opponent3 declares Riichi!");
                break;
            }
        }
    }

    // 🂽 Discard tile
    if (ds_list_size(Opponent3) > 0) {
        var discard_index = irandom(ds_list_size(Opponent3) - 1);
        var discarded_tile = ds_list_find_value(Opponent3, discard_index);
        ds_list_add(global.opponent3_discard, discarded_tile);
        ds_list_delete(Opponent3, discard_index);
        global.last_discarded_tile = discarded_tile;

        // 🀀 Ron check for player
        var ron_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(ron_hand, ds_list_find_value(player_hand, i));
        }
        ds_list_add(ron_hand, discarded_tile);
        var ron_yaku = check_yaku(ron_hand);
        ds_list_destroy(ron_hand);

        global.can_ron = array_length(ron_yaku) > 0;
        global.ron_yaku = ron_yaku;

        // ♟️ Tile call checks
        global.can_pon = false;
        global.can_kan = false;
        global.can_chi = false;
        ds_list_clear(global.call_pon);
        ds_list_clear(global.call_kan);
        ds_list_clear(global.call_chi);

        for (var i = 0; i < ds_list_size(player_hand); i++) {
            var tile = ds_list_find_value(player_hand, i);
            if (tile.suit == discarded_tile.suit && tile.value == discarded_tile.value) {
                ds_list_add(global.call_pon, tile);
                ds_list_add(global.call_kan, tile);
            }
        }

        if (ds_list_size(global.call_pon) >= 2) global.can_pon = true;
        if (ds_list_size(global.call_kan) >= 3) global.can_kan = true;

        // 🔄 Next turn or player response
        global.current_turn = (global.can_ron || global.can_pon || global.can_kan) ? 0 : 0;
        alarm[0] = 30;
    }
}