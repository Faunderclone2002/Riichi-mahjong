if keyboard_check_pressed(vk_delete) {
    MajSave();
    game_end();
}

// 🀄 Player Ron
if (global.can_ron && keyboard_check_pressed(ord("R"))) {
    var riichi_only = (array_length(global.ron_yaku) == 1 && global.ron_yaku[0] == "Riichi");
    global.points += (riichi_only ? 1000 : 32000);
    show_debug_message("Ron! You win with: " + string(global.ron_yaku));
    global.can_ron = false;
    global.game_won = true;
    global.current_turn = -1;
    alarm[0] = -1;
}

if (global.current_turn == 0) {
    // 🂡 Draw tile
    if (!player_has_drawn_tile && ds_list_size(global.tile_list) > 0) {
        var new_tile = ds_list_find_value(global.tile_list, 0);
        ds_list_add(player_hand, new_tile);
        ds_list_delete(global.tile_list, 0);
        player_has_drawn_tile = true;

        // 🔍 Check for Tsumo (self-draw win)
        var temp_win = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(temp_win, ds_list_find_value(player_hand, i));
        }

        var yaku_win = check_yaku(temp_win);
        if (array_length(yaku_win) > 0) {
            var riichi_only = (array_length(yaku_win) == 1 && yaku_win[0] == "Riichi");
            global.points += (riichi_only ? 1000 : 32000);
            show_debug_message("Tsumo! You win with: " + string(yaku_win));
            global.game_won = true;
            global.current_turn = -1;
            alarm[0] = -1;
        } else if (player_riichi_declared) {
            // 🤖 Auto-discard drawn tile if not winning
            var last_tile = ds_list_find_value(player_hand, ds_list_size(player_hand) - 1);
            ds_list_add(global.discard_pile, last_tile);
            ds_list_delete(player_hand, ds_list_size(player_hand) - 1);
            player_has_drawn_tile = false;
            global.current_turn = 1;
            alarm[0] = 30;
        }

        ds_list_destroy(temp_win);
    }

    // ♻️ Call Responses
    if (global.can_pon || global.can_kan || global.can_chi) {
        if (keyboard_check_pressed(ord("P")) && global.can_pon) {
            var target = global.last_discarded_tile;
            var matched = 0;
            for (var i = 0; i < ds_list_size(player_hand) && matched < 2; i++) {
                var t = ds_list_find_value(player_hand, i);
                if (t.suit == target.suit && t.value == target.value) {
                    ds_list_delete(player_hand, i);
                    matched++;
                    i--;
                }
            }
            ds_list_add(player_melds, target);
            global.can_pon = false;
            global.can_kan = false;
        }
        else if (keyboard_check_pressed(ord("K")) && global.can_kan) {
            var target = global.last_discarded_tile;
            var matched = 0;
            for (var i = 0; i < ds_list_size(player_hand) && matched < 3; i++) {
                var t = ds_list_find_value(player_hand, i);
                if (t.suit == target.suit && t.value == target.value) {
                    ds_list_delete(player_hand, i);
                    matched++;
                    i--;
                }
            }
            ds_list_add(player_melds, target);
            global.KanCalls += 1;
            global.can_kan = false;
            global.can_pon = false;
        }
        else if (keyboard_check_pressed(ord("C")) && global.can_chi) {
            var chi_tile = global.last_discarded_tile;
            for (var i = 0; i < ds_list_size(global.call_chi); i++) {
                var t = ds_list_find_value(global.call_chi, i);
                var idx = ds_list_find_index(player_hand, t);
                if (idx != -1) ds_list_delete(player_hand, idx);
            }
            ds_list_add(player_melds, chi_tile);
            global.can_chi = false;
        }

        if (keyboard_check_pressed(vk_escape) || (!global.can_pon && !global.can_kan && !global.can_chi)) {
            global.can_pon = false;
            global.can_kan = false;
            global.can_chi = false;
            ds_list_clear(global.call_pon);
            ds_list_clear(global.call_kan);
            ds_list_clear(global.call_chi);
        }

        if (keyboard_check_pressed(vk_enter) && ds_list_size(player_hand) > 0) {
            var discarded_tile = ds_list_find_value(player_hand, selected_tile);
            ds_list_add(global.discard_pile, discarded_tile);
            ds_list_delete(player_hand, selected_tile);
            selected_tile = max(0, selected_tile - 1);
            player_has_drawn_tile = false;

            // 🀄 Opponent Ron Check
            var opponents = [Opponent1, Opponent2, Opponent3];
            for (var o = 0; o < 3; o++) {
                var temp = ds_list_create();
                for (var i = 0; i < ds_list_size(opponents[o]); i++) {
                    ds_list_add(temp, ds_list_find_value(opponents[o], i));
                }
                ds_list_add(temp, discarded_tile);
                var yaku = check_yaku(temp);
                if (array_length(yaku) > 0) {
                    show_debug_message("Opponent" + string(o + 1) + " wins by Ron! Yaku: " + string(yaku));
                    global.points -= 32000;
                    global.game_won = true;
                    global.current_turn = -1;
                    alarm[0] = -1;
                    ds_list_destroy(temp);
                    exit;
                }
                ds_list_destroy(temp);
            }

            global.current_turn = 1;
            alarm[0] = 30;
        }
    }

    // 🀐 RIICHI LOGIC
    else if (keyboard_check_pressed(ord("R")) && !player_riichi_declared && player_has_drawn_tile && ds_list_size(player_melds) == 0) {
        var temp_hand = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(temp_hand, ds_list_find_value(player_hand, i));
        }

        var valid = false;
        for (var i = 0; i < ds_list_size(temp_hand); i++) {
            var trial_hand = ds_list_create();
            for (var j = 0; j < ds_list_size(temp_hand); j++) {
                if (j != i) ds_list_add(trial_hand, ds_list_find_value(temp_hand, j));
            }
            var yaku = check_yaku(trial_hand);
            if (array_length(yaku) > 0) {
                valid = true;
                ds_list_destroy(trial_hand);
                break;
            }
            ds_list_destroy(trial_hand);
        }

        if (valid) {
            player_riichi_declared = true;
            global.points -= 1000;
            global.declared_riichi = true;
            show_debug_message("Riichi Declared!");
        }

        ds_list_destroy(temp_hand);
    }

    // 🕹 Tile navigation + discard
    else {
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
            player_has_drawn_tile = false;

            // 🀄 Opponent Ron checks
            var opponents = [Opponent1, Opponent2, Opponent3];
            for (var o = 0; o < 3; o++) {
                var temp = ds_list_create();
                for (var i = 0; i < ds_list_size(opponents[o]); i++) {
                    ds_list_add(temp, ds_list_find_value(opponents[o], i));
                }
                ds_list_add(temp, discarded_tile);
                var yaku = check_yaku(temp);
                if (array_length(yaku) > 0) {
                    show_debug_message("Opponent" + string(o + 1) + " wins by Ron! Yaku: " + string(yaku));
                    global.points -= 32000;
                    global.game_won = true;
                    global.current_turn = -1;
                    alarm[0] = -1;
                    ds_list_destroy(temp);
                    exit;
                }
                ds_list_destroy(temp);
            }

            global.current_turn = 1;
            alarm[0] = 30;
        }
    }
}