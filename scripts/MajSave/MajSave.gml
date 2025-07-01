function MajSave(){
	var _file = file_text_open_write("PlayerData.txt");
	
	file_text_write_real(_file, global.points);
	
	file_text_close(_file);
}

function MajLoad(){
	
	if file_exists("PlayerData.txt"){
		
		var _file = file_text_open_read("PlayerData.txt");
		
		global.points = file_text_read_real(_file);
		
		file_text_close(_file)
	}
	
}