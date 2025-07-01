var points = global.points;
if (points <= 0) exit;

var tenthousands = floor(points / 10000); points -= tenthousands * 10000;
var fivethousands = floor(points / 5000); points -= fivethousands * 5000;
var thousands = floor(points / 1000); points -= thousands * 1000;
var hundreds = floor(points / 100); points -= hundreds * 100;

var x_offset = 0;

for (var i = 0; i < tenthousands; i++) {
    draw_sprite(MajPointSpr, 3, x + x_offset, y);
    x_offset += 17;
}

for (var a = 0; a < fivethousands; a++) {
    draw_sprite(MajPointSpr, 2, x + x_offset, y);
    x_offset += 17;
}

for (var b = 0; b < thousands; b++) {
    draw_sprite(MajPointSpr, 0, x + x_offset, y);
    x_offset += 17;
}

for (var c = 0; c < hundreds; c++) {
    draw_sprite(MajPointSpr, 1, x + x_offset, y);
    x_offset += 17;
}