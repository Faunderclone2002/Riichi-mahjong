if (keyboard_check_pressed(vk_delete)) {
    MajSave();
    game_end();
}

// 🀄 Player Ron (manual call)
if (global.can_ron && keyboard_check_pressed(ord("R"))) {
    var riichi_only = (array_length(global.ron_yaku) == 1 && global.ron_yaku[0] == "Riichi");
    global.points += (riichi_only ? 1000 : 32000);
    show_debug_message("Ron! You win with: " + string(global.ron_yaku));
    global.can_ron = false;
    global.game_won = true;
    global.current_turn = -1;
    alarm[0] = -1;
}

// ▶️ Begin player turn
if (global.current_turn == 0) {

    // 🂡 Draw tile
    if (!player_has_drawn_tile && ds_list_size(global.tile_list) > 0) {
        var new_tile = ds_list_find_value(global.tile_list, 0);
        ds_list_add(player_hand, new_tile);
        ds_list_delete(global.tile_list, 0);
        player_has_drawn_tile = true;

        // 🔍 Check for Tsumo
        var tsumo_test = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(tsumo_test, ds_list_find_value(player_hand, i));
        }

        var yaku_win = check_yaku(tsumo_test);
        ds_list_destroy(tsumo_test);

        if (array_length(yaku_win) > 0) {
            var riichi_only = (array_length(yaku_win) == 1 && yaku_win[0] == "Riichi");
            global.points += (riichi_only ? 1000 : 32000);
            show_debug_message("Tsumo! You win with: " + string(yaku_win));
            global.game_won = true;
            global.current_turn = -1;
            alarm[0] = -1;
        }
        // 🀐 Auto-discard after Riichi if hand not winning
        else if (player_riichi_declared) {
            var auto_tile = ds_list_find_value(player_hand, ds_list_size(player_hand) - 1);
            ds_list_add(global.discard_pile, auto_tile);
            ds_list_delete(player_hand, ds_list_size(player_hand) - 1);
            player_has_drawn_tile = false;
            global.current_turn = 1;
            alarm[0] = 30;
        }
    }

    // 🉐 Tile Call Responses
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

        if (keyboard_check_pressed(vk_escape)) {
            global.can_pon = false;
            global.can_kan = false;
            global.can_chi = false;
            ds_list_clear(global.call_pon);
            ds_list_clear(global.call_kan);
            ds_list_clear(global.call_chi);
        }

        // Discard after call
        if (keyboard_check_pressed(vk_enter) && ds_list_size(player_hand) > 0) {
            var discard_tile = ds_list_find_value(player_hand, selected_tile);
            ds_list_add(global.discard_pile, discard_tile);
            ds_list_delete(player_hand, selected_tile);
            selected_tile = max(0, selected_tile - 1);
            player_has_drawn_tile = false;

            // 🀀 Opponent Ron checks
            var opponents = [Opponent1, Opponent2, Opponent3];
            for (var o = 0; o < 3; o++) {
                var ron_test = ds_list_create();
                for (var i = 0; i < ds_list_size(opponents[o]); i++) {
                    ds_list_add(ron_test, ds_list_find_value(opponents[o], i));
                }
                ds_list_add(ron_test, discard_tile);
                var yaku = check_yaku(ron_test);
                ds_list_destroy(ron_test);

                if (array_length(yaku) > 0) {
                    show_debug_message("Opponent" + string(o + 1) + " wins by Ron! Yaku: " + string(yaku));
                    global.points -= 32000;
                    global.game_won = true;
                    global.current_turn = -1;
                    alarm[0] = -1;
                    exit;
                }
            }

            global.current_turn = 1;
            alarm[0] = 30;
        }
    }

    // 🀐 Riichi Declaration
    else if (keyboard_check_pressed(ord("R")) && !player_riichi_declared && player_has_drawn_tile && ds_list_size(player_melds) == 0) {
        var tenpai_test = ds_list_create();
        for (var i = 0; i < ds_list_size(player_hand); i++) {
            ds_list_add(tenpai_test, ds_list_find_value(player_hand, i));
        }

        var valid = false;
        for (var i = 0; i < ds_list_size(tenpai_test); i++) {
            var trial = ds_list_create();
            for (var j = 0; j < ds_list_size(tenpai_test); j++) {
                if (j != i) ds_list_add(trial, ds_list_find_value(tenpai_test, j));
            }
            var yaku = check_yaku(trial);
            ds_list_destroy(trial);
            if (array_length(yaku) > 0) {
                valid = true;
                break;
            }
        }

        ds_list_destroy(tenpai_test);

        if (valid) {
            player_riichi_declared = true;
            global.declared_riichi = true;
            global.points -= 1000;
            show_debug_message("Riichi Declared!");
        }
    }

    // 🕹 Manual Discard
    else {
        if (keyboard_check_pressed(vk_left)) {
            selected_tile = max(0, selected_tile - 1);
        }
        if (keyboard_check_pressed(vk_right)) {
            selected_tile = min(ds_list_size(player_hand) - 1, selected_tile + 1);
        }

        if (keyboard_check_pressed(vk_enter) && ds_list_size(player_hand) > 0) {
            var discard_tile = ds_list_find_value(player_hand, selected_tile);
            ds_list_add(global.discard_pile, discard_tile);
            ds_list_delete(player_hand, selected_tile);
            selected_tile = max(0, selected_tile - 1);
            player_has_drawn_tile = false;

            // 🀀 Opponent Ron checks
            var opponents = [Opponent1, Opponent2, Opponent3];
            for (var o = 0; o < 3; o++) {
                var ron_test = ds_list_create();
                for (var i = 0; i < ds_list_size(opponents[o]); i++) {
                    ds_list_add(ron_test, ds_list_find_value(opponents[o], i));
                }
                ds_list_add(ron_test, discard_tile);
                var yaku = check_yaku(ron_test);
                ds_list_destroy(ron_test);

                if (array_length(yaku) > 0) {
                    show_debug_message("Opponent" + string(o + 1) + " wins by Ron! Yaku: " + string(yaku));
                    global.points -= 32000;
                    global.game_won = true;
                    global.current_turn = -1;
                    alarm[0] = -1;
                    exit;
                }
            }

            global.current_turn = 1;
            alarm[0] = 30;
        }
    }
}