if ds_list_empty(global.tile_list) || global.KanCalls == 5 {
	draw_set_halign(fa_center);
	instance_deactivate_all(true);
	draw_circle_color(180,180,99999999999,c_black,c_black,false);
	draw_text(180,180,"Draw");
	draw_text_color(180,200,"Press Space to Continue",c_yellow,c_dkgray,c_maroon,c_lime,1);
	draw_text_color(180,220,"Press Escape to go back to menu",c_yellow,c_dkgray,c_maroon,c_lime,1);
	 
	if keyboard_check_pressed(vk_space) {
		draw_set_halign(fa_left);
		instance_destroy(MajGame);
		instance_create_layer(x, y, "Instances", MajGame);
		instance_activate_all();
	}
	if keyboard_check_released(vk_escape){
		draw_set_halign(fa_left);
		room_goto(Title);
	}
}

if global.points <= 0{
	draw_set_halign(fa_center);
	instance_deactivate_all(true);
	draw_circle_color(180,180,99999999999,c_black,c_black,false);
	draw_text(180,180,"Game Over");
	draw_text_color(180,220,"Press Escape to go back to menu",c_yellow,c_dkgray,c_maroon,c_lime,1);
	
	if keyboard_check_released(vk_escape){
		draw_set_halign(fa_left);
		room_goto(Title);
	}
}