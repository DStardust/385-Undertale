/************************************************************************
Avalon-MM Interface VGA Text mode display

Modified for DE2-115 board

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register
`define PALETTE_REG 8 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	input  logic [3:0]  status,
	input	 logic [7:0]  keycode,
	output logic [7:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic arrived_door,
	output logic arrived_monster,
	output logic hs, vs,					// VGA HS/VS
	output logic sync, blank, pixel_clk		// Required by DE2-115 video encoder
);

// logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
//put other local variables here
// logic [31:0] ctrl_reg;
//logic [31:0] palette			[`PALETTE_REG];
//logic [31:0] vram_data;
//logic [31:0] vram_read_temp;

logic [19:0] title_address, frisk_address, frisk_address2, intro_address, map1_address, map2_address, door_address, heart_address, field_address, flower_address;
logic [6:0] font_address;
logic [5:0] font_out1, font_out2, font_out3, font_out4, font_out5, font_out6;
logic [3:0] intro_num1, intro_num2;

logic [11:0] char_index;
logic [9:0] font_addr1, font_addr2;
logic [10:0] vram_index;
logic [9:0] DrawX, DrawY;
logic [6:0] row, col;

logic [7:0] font_data1, font_data2;

logic [15:0] vram_code;
logic [6:0] font_num;

logic [5:0] counter;

logic [23:0] color_out_t;
logic [23:0] color_out_m1, color_out_m2;
logic [23:0] color_out_d;
logic [23:0] color_out_h;
logic [23:0] color_out_fi;
logic [23:0] color_out_fl1, color_out_fl2, color_out_fl3;
logic [23:0] color_out_i1, color_out_i2, color_out_i3, color_out_i4, color_out_i5, color_out_i6, color_out_i7, color_out_i8, color_out_i9, color_out_i10;
logic [23:0] color_out_f1, color_out_f2, color_out_f3, color_out_f4, color_out_f5, color_out_f6, color_out_f7, color_out_f8, color_out_f9, color_out_f10;
logic [23:0] color_out_f12, color_out_f22, color_out_f32, color_out_f42, color_out_f52, color_out_f62, color_out_f72, color_out_f82, color_out_f92, color_out_f102;

logic [1:0] direction;

logic is_title;
logic is_map1, is_map2;
logic is_intro1, is_intro2, is_intro3, is_intro4, is_intro5, is_intro6, is_intro7, is_intro8, is_intro9, is_intro10;
logic is_sub1, is_sub2;
logic is_frisk, is_frisk2;
logic is_front;
logic is_press;
logic is_door;
logic is_heart;
logic is_field;
logic is_flower1, is_flower2, is_flower3;


//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller vga_controller_instance(.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), .pixel_clk(pixel_clk), .blank(blank), .sync(sync), .DrawX(DrawX), .DrawY(DrawY));

font_rom font1(.addr(font_addr1), .data(font_data1));
font_rom font2(.addr(font_addr2), .data(font_data2));
font1_rom font1_rom(.font1_address(font_address), .font_out(font_out1));
font2_rom font2_rom(.font2_address(font_address), .font_out(font_out2));
font3_rom font3_rom(.font3_address(font_address), .font_out(font_out3));
font4_rom font4_rom(.font4_address(font_address), .font_out(font_out4));
font5_rom font5_rom(.font5_address(font_address), .font_out(font_out5));
font6_rom font6_rom(.font6_address(font_address), .font_out(font_out6));

title title(.DrawX(DrawX), .DrawY(DrawY), .status(status), .is_title(is_title), .title_address(title_address));
title_rom title_rom(.title_address(title_address), .color_out(color_out_t));

map1 map1(.Clk(CLK), .frame_clk(vs), .Reset(RESET), .keycode(keycode), .DrawX(DrawX), .DrawY(DrawY), .status(status), .is_map1(is_map1), .map1_address(map1_address));
//map1_rom map1_rom(.map1_address(map1_address), .color_out(color_out_m1));

map2 map2(.DrawX(DrawX), .DrawY(DrawY), .status(status), .is_map2(is_map2), .map2_address(map2_address));
map2_rom map2_rom(.map2_address(map2_address), .color_out(color_out_m2));

door door(.Clk(CLK), .frame_clk(vs), .Reset(RESET), .keycode(keycode), .DrawX(DrawX), .DrawY(DrawY), .status(status), .is_door(is_door), .door_address(door_address));
door_rom door_rom(.door_address(door_address), .color_out(color_out_d));

frisk_move friskmove(.Clk(CLK), .frame_clk(vs), .Reset(RESET), .keycode(keycode), .DrawX(DrawX), .DrawY(DrawY), .is_frisk(is_frisk), .status(status), .frisk_address(frisk_address), .arrived_door(arrived_door));
frisk_move2 friskmove2(.Clk(CLK), .frame_clk(vs), .Reset(RESET), .keycode(keycode), .DrawX(DrawX), .DrawY(DrawY), .is_frisk(is_frisk2), .status(status), .frisk_address(frisk_address2), .arrived_monster(arrived_monster));

frisk1_rom frisk1_rom(.frisk1_address(frisk_address), .color_out(color_out_f1));
frisk2_rom frisk2_rom(.frisk2_address(frisk_address), .color_out(color_out_f2));
frisk3_rom frisk3_rom(.frisk3_address(frisk_address), .color_out(color_out_f3));
frisk4_rom frisk4_rom(.frisk4_address(frisk_address), .color_out(color_out_f4));
frisk5_rom frisk5_rom(.frisk5_address(frisk_address), .color_out(color_out_f5));
frisk6_rom frisk6_rom(.frisk6_address(frisk_address), .color_out(color_out_f6));
frisk7_rom frisk7_rom(.frisk7_address(frisk_address), .color_out(color_out_f7));
frisk8_rom frisk8_rom(.frisk8_address(frisk_address), .color_out(color_out_f8));
frisk9_rom frisk9_rom(.frisk9_address(frisk_address), .color_out(color_out_f9));
frisk10_rom frisk10_rom(.frisk10_address(frisk_address), .color_out(color_out_f10));

frisk1_rom frisk1_rom2(.frisk1_address(frisk_address2), .color_out(color_out_f12));
frisk2_rom frisk2_rom2(.frisk2_address(frisk_address2), .color_out(color_out_f22));
frisk3_rom frisk3_rom2(.frisk3_address(frisk_address2), .color_out(color_out_f32));
frisk4_rom frisk4_rom2(.frisk4_address(frisk_address2), .color_out(color_out_f42));
frisk5_rom frisk5_rom2(.frisk5_address(frisk_address2), .color_out(color_out_f52));
frisk6_rom frisk6_rom2(.frisk6_address(frisk_address2), .color_out(color_out_f62));
frisk7_rom frisk7_rom2(.frisk7_address(frisk_address2), .color_out(color_out_f72));
frisk8_rom frisk8_rom2(.frisk8_address(frisk_address2), .color_out(color_out_f82));
frisk9_rom frisk9_rom2(.frisk9_address(frisk_address2), .color_out(color_out_f92));
frisk10_rom frisk10_rom2(.frisk10_address(frisk_address2), .color_out(color_out_f102));

heart_move heartmove(.Clk(CLK), .frame_clk(vs), .Reset(RESET), .keycode(keycode), .DrawX(DrawX), .DrawY(DrawY), .is_heart(is_heart), .status(status), .heart_address(heart_address));
heart_rom heart_rom(.heart_address(heart_address), .color_out(color_out_h));

field field(.DrawX(DrawX), .DrawY(DrawY), .status(status), .is_field(is_field), .field_address(field_address));
field_rom field_rom(.field_address(field_address), .color_out(color_out_fi));

flower flower(.frame_clk(vs), .DrawX(DrawX), .DrawY(DrawY), .status(status), .is_flower1(is_flower1), .is_flower2(is_flower2), .is_flower3(is_flower3), .flower_address(flower_address));
flower1_rom flower1_rom(.flower_address(flower_address), .color_out(color_out_fl1));
flower2_rom flower2_rom(.flower_address(flower_address), .color_out(color_out_fl2));
flower3_rom flower3_rom(.flower_address(flower_address), .color_out(color_out_fl3));

intro intro(.frame_clk(vs), .DrawX(DrawX), .DrawY(DrawY), .status(status), .is_intro1(is_intro1), .is_intro2(is_intro2), .is_intro3(is_intro3), .is_intro4(is_intro4),
.is_intro5(is_intro5), .is_intro6(is_intro6), .is_intro7(is_intro7), .is_intro8(is_intro8), .is_intro9(is_intro9), .is_intro10(is_intro10), .is_sub1(is_sub1), .is_sub2(is_sub2),
.intro_num1(intro_num1), .intro_num2(intro_num2), .intro_address(intro_address));
//intro1_rom intro1_rom(.intro1_address(intro_address), .color_out(color_out_i1));
//intro2_rom intro2_rom(.intro2_address(intro_address), .color_out(color_out_i2));
//intro3_rom intro3_rom(.intro3_address(intro_address), .color_out(color_out_i3));
//intro4_rom intro4_rom(.intro4_address(intro_address), .color_out(color_out_i4));
//intro5_rom intro5_rom(.intro5_address(intro_address), .color_out(color_out_i5));
//intro6_rom intro6_rom(.intro6_address(intro_address), .color_out(color_out_i6));
//intro7_rom intro7_rom(.intro7_address(intro_address), .color_out(color_out_i7));
//intro8_rom intro8_rom(.intro8_address(intro_address), .color_out(color_out_i8));
//intro9_rom intro9_rom(.intro9_address(intro_address), .color_out(color_out_i9));
//intro10_rom intro10_rom(.intro10_address(intro_address), .color_out(color_out_i10));

always_comb
begin
	row = {1'b0, DrawY[9:4]};
	col = DrawX[9:3];
	font_address = 7'b1111111;
	font_addr1 = 10'b0;
	font_addr2 = 10'b0;
	is_front = 1'b0;
	if ((row >= 7'd15) && (row <= 7'd17)) begin
		if ((col >= 7'd10) && (col <= 7'd34)) begin
			font_address = col - 10 + (row - 15) * 25;
			if (is_sub1) 
			begin
				if (intro_num1 == 4'd1) begin
					font_addr1 = (font_out1<<4)+DrawY[3:0];
					is_front = font_data1[7-DrawX[2:0]];
				end
				else if (intro_num1 == 4'd3) begin
					font_addr1 = (font_out3<<4)+DrawY[3:0];
					is_front = font_data1[7-DrawX[2:0]];
				end
				else if (intro_num1 == 4'd5) begin
					font_addr1 = (font_out5<<4)+DrawY[3:0];
					is_front = font_data1[7-DrawX[2:0]];
				end
				
			end
		end
		else if ((col >= 7'd45) && (col <= 7'd69)) begin
			font_address = col - 45 + (row - 15) * 25;
			if (is_sub2) 
			begin
				if (intro_num2 == 4'd2) begin
					font_addr2 = (font_out2<<4)+DrawY[3:0];
					is_front = font_data2[7-DrawX[2:0]];
				end
				else if (intro_num2 == 4'd4) begin
					font_addr2 = (font_out4<<4)+DrawY[3:0];
					is_front = font_data2[7-DrawX[2:0]];
				end
				else if (intro_num2 == 4'd6) begin
					font_addr2 = (font_out6<<4)+DrawY[3:0];
					is_front = font_data2[7-DrawX[2:0]];
				end
			end
		end
	end
end

always_ff @(posedge CLK)
begin
	case (keycode)
	8'd22:
	begin
		direction <= 2'd0;
		is_press <= 1'b1;
	end
	8'd26:
	begin
		direction <= 2'd1;
		is_press <= 1'b1;
	end
	8'd04:
	begin
		direction <= 2'd2;
		is_press <= 1'b1;
	end
	8'd07:
	begin
		direction <= 2'd3;
		is_press <= 1'b1;
	end
	default:
	begin
		is_press <= 1'b0;
	end
	endcase
end

always_ff @(posedge vs)
begin
	if(is_press) 
	begin
		counter ++;
		if (counter == 6'd60) 
		begin
			counter <= 6'b00;
		end
	end
	else 
	begin
		counter <= 6'b0;
	end
end

always_comb
begin
	if (~blank)
	begin
		red <= 8'h0;
		green <= 8'h0;
		blue <= 8'h0;
	end
	else
	begin
		if (is_frisk)
		begin
			case (direction)
			2'd0:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f5 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f5[23:16];
							green <= color_out_f5[15:8];
							blue <= color_out_f5[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f1 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f1[23:16];
							green <= color_out_f1[15:8];
							blue <= color_out_f1[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f6 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f6[23:16];
							green <= color_out_f6[15:8];
							blue <= color_out_f6[7:0];
						end
					end
					else
					begin
						if (color_out_f1 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f1[23:16];
							green <= color_out_f1[15:8];
							blue <= color_out_f1[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f1 == 24'hffffff)
					begin
						if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
						else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f1[23:16];
						green <= color_out_f1[15:8];
						blue <= color_out_f1[7:0];
					end
				end
			end
			2'd1:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f8 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f8[23:16];
							green <= color_out_f8[15:8];
							blue <= color_out_f8[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f2 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f2[23:16];
							green <= color_out_f2[15:8];
							blue <= color_out_f2[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f7 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f7[23:16];
							green <= color_out_f7[15:8];
							blue <= color_out_f7[7:0];
						end
					end
					else
					begin
						if (color_out_f2 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f2[23:16];
							green <= color_out_f2[15:8];
							blue <= color_out_f2[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f2 == 24'hffffff)
					begin
						if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
						else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f2[23:16];
						green <= color_out_f2[15:8];
						blue <= color_out_f2[7:0];
					end
				end
			end
			2'd2:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f9 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f9[23:16];
							green <= color_out_f9[15:8];
							blue <= color_out_f9[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f3 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f3[23:16];
							green <= color_out_f3[15:8];
							blue <= color_out_f3[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f9 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f9[23:16];
							green <= color_out_f9[15:8];
							blue <= color_out_f9[7:0];
						end
					end
					else
					begin
						if (color_out_f3 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f3[23:16];
							green <= color_out_f3[15:8];
							blue <= color_out_f3[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f3 == 24'hffffff)
					begin
						if (is_map1)
						begin
							red <= color_out_m1[23:16];
							green <= color_out_m1[15:8];
							blue <= color_out_m1[7:0];
						end
						else if (is_door)
						begin
							red <= color_out_d[23:16];
							green <= color_out_d[15:8];
							blue <= color_out_d[7:0];
						end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f3[23:16];
						green <= color_out_f3[15:8];
						blue <= color_out_f3[7:0];
					end
				end
			end
			2'd3:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f10 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f10[23:16];
							green <= color_out_f10[15:8];
							blue <= color_out_f10[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f4 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f4[23:16];
							green <= color_out_f4[15:8];
							blue <= color_out_f4[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f10 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f10[23:16];
							green <= color_out_f10[15:8];
							blue <= color_out_f10[7:0];
						end
					end
					else
					begin
						if (color_out_f4 == 24'hffffff)
						begin
							if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
							else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f4[23:16];
							green <= color_out_f4[15:8];
							blue <= color_out_f4[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f4 == 24'hffffff)
					begin
						if (is_map1)
							begin
								red <= color_out_m1[23:16];
								green <= color_out_m1[15:8];
								blue <= color_out_m1[7:0];
							end
						else if (is_door)
							begin
								red <= color_out_d[23:16];
								green <= color_out_d[15:8];
								blue <= color_out_d[7:0];
							end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f4[23:16];
						green <= color_out_f4[15:8];
						blue <= color_out_f4[7:0];
					end
				end
			end
			default:;
			endcase
		end
		else if (is_frisk2)
		begin
			case (direction)
			2'd0:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f52 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f52[23:16];
							green <= color_out_f52[15:8];
							blue <= color_out_f52[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f12 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f12[23:16];
							green <= color_out_f12[15:8];
							blue <= color_out_f12[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f62 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f62[23:16];
							green <= color_out_f62[15:8];
							blue <= color_out_f62[7:0];
						end
					end
					else
					begin
						if (color_out_f12 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f12[23:16];
							green <= color_out_f12[15:8];
							blue <= color_out_f12[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f12 == 24'hffffff)
					begin
						if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f12[23:16];
						green <= color_out_f12[15:8];
						blue <= color_out_f12[7:0];
					end
				end
			end
			2'd1:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f82 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f82[23:16];
							green <= color_out_f82[15:8];
							blue <= color_out_f82[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f22 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f22[23:16];
							green <= color_out_f22[15:8];
							blue <= color_out_f22[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f72 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f72[23:16];
							green <= color_out_f72[15:8];
							blue <= color_out_f72[7:0];
						end
					end
					else
					begin
						if (color_out_f22 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f22[23:16];
							green <= color_out_f22[15:8];
							blue <= color_out_f22[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f22 == 24'hffffff)
					begin
						if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f22[23:16];
						green <= color_out_f22[15:8];
						blue <= color_out_f22[7:0];
					end
				end
			end
			2'd2:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f92 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f92[23:16];
							green <= color_out_f92[15:8];
							blue <= color_out_f92[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f32 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f32[23:16];
							green <= color_out_f32[15:8];
							blue <= color_out_f32[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f92 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f92[23:16];
							green <= color_out_f92[15:8];
							blue <= color_out_f92[7:0];
						end
					end
					else
					begin
						if (color_out_f32 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f32[23:16];
							green <= color_out_f32[15:8];
							blue <= color_out_f32[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f32 == 24'hffffff)
					begin
						if (is_map2)
						begin
							red <= color_out_m2[23:16];
							green <= color_out_m2[15:8];
							blue <= color_out_m2[7:0];
						end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f32[23:16];
						green <= color_out_f32[15:8];
						blue <= color_out_f32[7:0];
					end
				end
			end
			2'd3:
			begin
				if (is_press)
				begin
					if (counter <= 6'd15) 
					begin
						if (color_out_f102 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f102[23:16];
							green <= color_out_f102[15:8];
							blue <= color_out_f102[7:0];
						end
					end
					else if (counter <= 6'd30) 
					begin
						if (color_out_f42 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f42[23:16];
							green <= color_out_f42[15:8];
							blue <= color_out_f42[7:0];
						end
					end
					else if (counter <= 6'd45) 
					begin
						if (color_out_f102 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f102[23:16];
							green <= color_out_f102[15:8];
							blue <= color_out_f102[7:0];
						end
					end
					else
					begin
						if (color_out_f42 == 24'hffffff)
						begin
							if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
							else
							begin
								red <= 8'h0;
								green <= 8'h0;
								blue <= 8'h0;
							end
						end
						else
						begin
							red <= color_out_f42[23:16];
							green <= color_out_f42[15:8];
							blue <= color_out_f42[7:0];
						end
					end
				end
				else
				begin
					if (color_out_f42 == 24'hffffff)
					begin
						if (is_map2)
							begin
								red <= color_out_m2[23:16];
								green <= color_out_m2[15:8];
								blue <= color_out_m2[7:0];
							end
						else
						begin
							red <= 8'h0;
							green <= 8'h0;
							blue <= 8'h0;
						end
					end
					else
					begin
						red <= color_out_f42[23:16];
						green <= color_out_f42[15:8];
						blue <= color_out_f42[7:0];
					end
				end
			end
			default:;
			endcase
		end
		else if (is_title)
		begin
			red <= color_out_t[23:16];
			green <= color_out_t[15:8];
			blue <= color_out_t[7:0];
		end
		else if (is_intro1)
		begin
			red <= color_out_i1[23:16];
			green <= color_out_i1[15:8];
			blue <= color_out_i1[7:0];
		end
		else if (is_intro2)
		begin
			red <= color_out_i2[23:16];
			green <= color_out_i2[15:8];
			blue <= color_out_i2[7:0];
		end
		else if (is_intro3)
		begin
			red <= color_out_i3[23:16];
			green <= color_out_i3[15:8];
			blue <= color_out_i3[7:0];
		end
		else if (is_intro4)
		begin
			red <= color_out_i4[23:16];
			green <= color_out_i4[15:8];
			blue <= color_out_i4[7:0];
		end
			else if (is_intro5)
		begin
			red <= color_out_i5[23:16];
			green <= color_out_i5[15:8];
			blue <= color_out_i5[7:0];
		end
		else if (is_intro6)
		begin
			red <= color_out_i6[23:16];
			green <= color_out_i6[15:8];
			blue <= color_out_i6[7:0];
		end
		else if (is_intro7)
		begin
			red <= color_out_i7[23:16];
			green <= color_out_i7[15:8];
			blue <= color_out_i7[7:0];
		end
		else if (is_intro8)
		begin
			red <= color_out_i8[23:16];
			green <= color_out_i8[15:8];
			blue <= color_out_i8[7:0];
		end
		else if (is_intro9)
		begin
			red <= color_out_i9[23:16];
			green <= color_out_i9[15:8];
			blue <= color_out_i9[7:0];
		end
		else if (is_intro10)
		begin
			red <= color_out_i10[23:16];
			green <= color_out_i10[15:8];
			blue <= color_out_i10[7:0];
		end
		else if (is_front)
		begin
			red <= 8'hff;
			green <= 8'hff;
			blue <= 8'hff;
		end
		else if (is_map1)
		begin
			red <= color_out_m1[23:16];
			green <= color_out_m1[15:8];
			blue <= color_out_m1[7:0];
		end
		else if (is_door)
		begin
			red <= color_out_d[23:16];
			green <= color_out_d[15:8];
			blue <= color_out_d[7:0];
		end
		else if (is_map2)
		begin
			red <= color_out_m2[23:16];
			green <= color_out_m2[15:8];
			blue <= color_out_m2[7:0];
		end
		else if (is_heart)
		begin
			red <= color_out_h[23:16];
			green <= color_out_h[15:8];
			blue <= color_out_h[7:0];
		end
		else if (is_field)
		begin
			red <= color_out_fi[23:16];
			green <= color_out_fi[15:8];
			blue <= color_out_fi[7:0];
		end
		else if (is_flower1)
		begin
			red <= color_out_fl1[23:16];
			green <= color_out_fl1[15:8];
			blue <= color_out_fl1[7:0];
		end
		else if (is_flower2)
		begin
			red <= color_out_fl2[23:16];
			green <= color_out_fl2[15:8];
			blue <= color_out_fl2[7:0];
		end
		else if (is_flower3)
		begin
			red <= color_out_fl3[23:16];
			green <= color_out_fl3[15:8];
			blue <= color_out_fl3[7:0];
		end
		else
		begin
			red <= 8'h0;
			green <= 8'h0;
			blue <= 8'h0;
		end
	end
end

endmodule
