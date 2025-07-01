// Opponent 1 Turn
if (global.current_turn == 1) {
    // Draw tile
    if (ds_list_size(global.tile_list) > 0) {
        ds_list_add(Opponent1, ds_list_find_value(global.tile_list, 0));
        ds_list_delete(global.tile_list, 0);
    }

    // Check for tsumo (self-draw win)
    if (ds_list_size(Opponent1) >= 14) {
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(Opponent1); i++) {
            ds_list_add(temp_win, ds_list_find_value(Opponent1, i));
        }
        var win_yaku = check_yaku(temp_win);
        if (array_length(win_yaku) > 0) {
            show_debug_message("Opponent1 wins by Tsumo! Yaku: " + string(win_yaku));
            global.opponent1_won = true;
            global.points -= 1000;
            global.current_turn = -1;
            alarm[0] = -1;
            ds_list_destroy(temp_win);
            exit;
        }
        ds_list_destroy(temp_win);
    }

    // Check for riichi if hand size is 14
    if (!global.opponent1_riichi_declared && ds_list_size(Opponent1) == 14) {
        for (var d = 0; d < ds_list_size(Opponent1); d++) {
            var test_hand = ds_list_create();
            for (var c = 0; c < ds_list_size(Opponent1); c++) {
                if (c != d) ds_list_add(test_hand, ds_list_find_value(Opponent1, c));
            }
            var yaku = check_yaku(test_hand);
            if (array_length(yaku) > 0) {
                global.opponent1_riichi_declared = true;
                global.points -= 1000;
                show_debug_message("Opponent1 declares Riichi!");
                ds_list_destroy(test_hand);
                break;
            }
            ds_list_destroy(test_hand);
        }
    }

    // Discard tile
    if (ds_list_size(Opponent1) > 0) {
        var discard_index = irandom(ds_list_size(Opponent1) - 1);
        var discarded_tile = ds_list_find_value(Opponent1, discard_index);
        ds_list_add(global.opponent1_discard, discarded_tile);
        ds_list_delete(Opponent1, discard_index);
        global.last_discarded_tile = discarded_tile;

        // Ron check for player
        var ron_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(ron_hand, ds_list_find_value(player_hand, i));
        }
        ds_list_add(ron_hand, discarded_tile);
        var ron_yaku = check_yaku(ron_hand);
        if (array_length(ron_yaku) > 0) {
            global.can_ron = true;
            global.ron_yaku = ron_yaku;
        } else {
            global.can_ron = false;
        }
        ds_list_destroy(ron_hand);

        // Tile call checks
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

        // Chi check (numbered suits only)
        if (discarded_tile.suit != "honors") {
            var val = discarded_tile.value;
            var suits = ["manzu", "souzu", "pinzu"];
            if (array_contains(suits, discarded_tile.suit)) {
                for (var offset = -2; offset <= 0; offset++) {
                    var a = val + offset;
                    var b = val + offset + 1;
                    var c = val + offset + 2;
                    if (a >= 1 && c <= 9) {
                        var found_a = -1, found_b = -1;
                        for (var i = 0; i < ds_list_size(player_hand); i++) {
                            var t = ds_list_find_value(player_hand, i);
                            if (t.suit == discarded_tile.suit && t.value == a && found_a == -1) found_a = i;
                            else if (t.suit == discarded_tile.suit && t.value == b && found_b == -1) found_b = i;
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
        }

        // Let player respond or continue
        global.current_turn = (global.can_ron || global.can_pon || global.can_kan || global.can_chi) ? 0 : 2;
        if (global.current_turn != 0) alarm[0] = 30;
    }
}

// Opponent 2 Turn
else if (global.current_turn == 2) {
    // Draw tile
    if (ds_list_size(global.tile_list) > 0) {
        ds_list_add(Opponent2, ds_list_find_value(global.tile_list, 0));
        ds_list_delete(global.tile_list, 0);
    }

    // Check for Tsumo (self-draw win)
    if (ds_list_size(Opponent2) >= 14) {
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(Opponent2); i++) {
            ds_list_add(temp_win, ds_list_find_value(Opponent2, i));
        }
        var win_yaku = check_yaku(temp_win);
        if (array_length(win_yaku) > 0) {
            show_debug_message("Opponent2 wins by Tsumo! Yaku: " + string(win_yaku));
            global.opponent2_won = true;
            global.points -= 1000;
            global.current_turn = -1;
            alarm[0] = -1;
            ds_list_destroy(temp_win);
            exit;
        }
        ds_list_destroy(temp_win);
    }

    // Check for Riichi
    if (!global.opponent2_riichi_declared && ds_list_size(Opponent2) == 14) {
        for (var d = 0; d < ds_list_size(Opponent2); d++) {
            var test_hand = ds_list_create();
            for (var c = 0; c < ds_list_size(Opponent2); c++) {
                if (c != d) ds_list_add(test_hand, ds_list_find_value(Opponent2, c));
            }
            var yaku = check_yaku(test_hand);
            if (array_length(yaku) > 0) {
                global.opponent2_riichi_declared = true;
                global.points -= 1000;
                show_debug_message("Opponent2 declares Riichi!");
                ds_list_destroy(test_hand);
                break;
            }
            ds_list_destroy(test_hand);
        }
    }

    // Discard
    if (ds_list_size(Opponent2) > 0) {
        var discard_index = irandom(ds_list_size(Opponent2) - 1);
        var discarded_tile = ds_list_find_value(Opponent2, discard_index);
        ds_list_add(global.opponent2_discard, discarded_tile);
        ds_list_delete(Opponent2, discard_index);
        global.last_discarded_tile = discarded_tile;

        // Ron check for player
        var ron_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(ron_hand, ds_list_find_value(player_hand, i));
        }
        ds_list_add(ron_hand, discarded_tile);
        var ron_yaku = check_yaku(ron_hand);
        if (array_length(ron_yaku) > 0) {
            global.can_ron = true;
            global.ron_yaku = ron_yaku;
        } else {
            global.can_ron = false;
        }
        ds_list_destroy(ron_hand);

        // Tile call checks
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

        global.current_turn = (global.can_ron || global.can_pon || global.can_kan) ? 0 : 3;
        if (global.current_turn != 0) alarm[0] = 30;
    }
}
// Opponent 3 Turn
else if (global.current_turn == 3) {
    // Draw tile
    if (ds_list_size(global.tile_list) > 0) {
        ds_list_add(Opponent3, ds_list_find_value(global.tile_list, 0));
        ds_list_delete(global.tile_list, 0);
    }

    // Check for Tsumo (self-draw win)
    if (ds_list_size(Opponent3) >= 14) {
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(Opponent3); i++) {
            ds_list_add(temp_win, ds_list_find_value(Opponent3, i));
        }
        var win_yaku = check_yaku(temp_win);
        if (array_length(win_yaku) > 0) {
            show_debug_message("Opponent3 wins by Tsumo! Yaku: " + string(win_yaku));
            global.opponent3_won = true;
            global.points -= 1000;
            global.current_turn = -1;
            alarm[0] = -1;
            ds_list_destroy(temp_win);
            exit;
        }
        ds_list_destroy(temp_win);
    }

    // Riichi logic
    if (!global.opponent3_riichi_declared && ds_list_size(Opponent3) == 14) {
        for (var d = 0; d < ds_list_size(Opponent3); d++) {
            var test_hand = ds_list_create();
            for (var c = 0; c < ds_list_size(Opponent3); c++) {
                if (c != d) ds_list_add(test_hand, ds_list_find_value(Opponent3, c));
            }
            var yaku = check_yaku(test_hand);
            if (array_length(yaku) > 0) {
                global.opponent3_riichi_declared = true;
                global.points -= 1000;
                show_debug_message("Opponent3 declares Riichi!");
                ds_list_destroy(test_hand);
                break;
            }
            ds_list_destroy(test_hand);
        }
    }

    // Discard logic
    if (ds_list_size(Opponent3) > 0) {
        var discard_index = irandom(ds_list_size(Opponent3) - 1);
        var discarded_tile = ds_list_find_value(Opponent3, discard_index);
        ds_list_add(global.opponent3_discard, discarded_tile);
        ds_list_delete(Opponent3, discard_index);
        global.last_discarded_tile = discarded_tile;

        // Ron check for player
        var ron_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(ron_hand, ds_list_find_value(player_hand, i));
        }
        ds_list_add(ron_hand, discarded_tile);
        var ron_yaku = check_yaku(ron_hand);
        if (array_length(ron_yaku) > 0) {
            global.can_ron = true;
            global.ron_yaku = ron_yaku;
        } else {
            global.can_ron = false;
        }
        ds_list_destroy(ron_hand);

        // Pon/Kan checks
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

        global.current_turn = (global.can_ron || global.can_pon || global.can_kan) ? 0 : 0;
        alarm[0] = 30;
    }
}