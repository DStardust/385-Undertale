module intro
(
		input	 logic frame_clk,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_intro1,		// Whether current pixel belongs to background
		output logic is_intro2,
		output logic is_intro3,
		output logic is_intro4,
		output logic is_intro5,
		output logic is_intro6,
		output logic is_intro7,
		output logic is_intro8,
		output logic is_intro9,
		output logic is_intro10,
		output logic is_sub1, is_sub2,
		output logic [3:0] intro_num1, intro_num2,
		output logic [19:0] intro_address		// address for color mapper to figure out what color the logo pixel should be
);

logic [11:0] counter;

always_ff @(posedge frame_clk) begin // counter inside to check if the time reaches 50s and display the animation of the introduction

	if(status == 4'd2)
	begin
		case (counter)
			12'd1:
			begin
				intro_num1 <= 4'd1;
				is_sub1 = 1'b1;
				counter ++;
			end
			12'd300:
			begin
				intro_num2 <= 4'd2;
				is_sub2 = 1'b1;
				counter ++;
			end
			12'd600:
			begin
				intro_num1 <= 4'd3;
				intro_num2 <= 4'd0;
				is_sub1 = 1'b1;
				is_sub2 = 1'b0;
				counter ++;
			end
			12'd900:
			begin
				intro_num2 <= 4'd4;
				counter ++;
				is_sub2 = 1'b1;
			end
			12'd1200:
			begin
				intro_num1 <= 4'd5;
				intro_num2 <= 4'd0;
				counter ++;
				is_sub1 = 1'b1;
				is_sub2 = 1'b0;
			end
			12'd1500:
			begin
				intro_num2 <= 4'd6;
				counter ++;
				is_sub2 = 1'b1;
			end
			12'd1800:
			begin
				intro_num1 <= 4'd7;
				intro_num2 <= 4'd0;
				counter ++;
				is_sub1 = 1'b1;
				is_sub2 = 1'b0;
			end
			12'd2100:
			begin
				intro_num2 <= 4'd8;
				counter ++;
				is_sub2 = 1'b1;
			end
			12'd2400:
			begin
				intro_num1 <= 4'd9;
				intro_num2 <= 4'd0;
				counter ++;
				is_sub1 = 1'b1;
				is_sub2 = 1'b0;
			end
			12'd2700:
			begin
				intro_num2 <= 4'd10;
				counter ++;
				is_sub2 = 1'b1;
			end
			12'd3000:
			begin
				counter <= 12'd3000;
				intro_num1 <= 4'd0;
				intro_num2 <= 4'd0;
				is_sub1 = 1'b0;
				is_sub2 = 1'b0;
			end
			default:
				counter ++;
		endcase
	end
	else begin
		counter <= 12'b0;
		intro_num1 <= 4'd0;
		intro_num2 <= 4'd0;
		is_sub1 = 1'b0;
		is_sub2 = 1'b0;
	end
end

always_comb // using intro_num1 and intro_num2 to display different image of introductions at the same position
	begin
		is_intro1 = 1'b0;
		is_intro2 = 1'b0;
		is_intro3 = 1'b0;
		is_intro4 = 1'b0;
		is_intro5 = 1'b0;
		is_intro6 = 1'b0;
		is_intro7 = 1'b0;
		is_intro8 = 1'b0;
		is_intro9 = 1'b0;
		is_intro10 = 1'b0;
		intro_address = 20'b0;
		if(status == 4'd2)
		begin
			 if (DrawX >= 79 && DrawX < 278 && DrawY >= 80 && DrawY < 187) 
			 begin
				 case(intro_num1)
				 4'd1:
				 begin
					is_intro1 = 1'b1;
					is_intro3 = 1'b0;
					is_intro5 = 1'b0;
					is_intro7 = 1'b0;
					is_intro9 = 1'b0;
				 end
				 4'd3:
				 begin
					is_intro1 = 1'b0;
					is_intro3 = 1'b1;
					is_intro5 = 1'b0;
					is_intro7 = 1'b0;
					is_intro9 = 1'b0;
				 end
				 4'd5:
				 begin
					is_intro1 = 1'b0;
					is_intro3 = 1'b0;
					is_intro5 = 1'b1;
					is_intro7 = 1'b0;
					is_intro9 = 1'b0;
				 end
				 4'd7:
				 begin
					is_intro1 = 1'b0;
					is_intro3 = 1'b0;
					is_intro5 = 1'b0;
					is_intro7 = 1'b1;
					is_intro9 = 1'b0;
				 end
				 4'd9:
				 begin
					is_intro1 = 1'b0;
					is_intro3 = 1'b0;
					is_intro5 = 1'b0;
					is_intro7 = 1'b0;
					is_intro9 = 1'b1;
				 end
				 default:
				 begin
					is_intro1 = 1'b0;
					is_intro3 = 1'b0;
					is_intro5 = 1'b0;
					is_intro7 = 1'b0;
					is_intro9 = 1'b0;
				 end
				 endcase
				 intro_address = DrawX - 79 + (DrawY - 80) * 199;
			 end
			 else if (DrawX >= 360 && DrawX < 559 && DrawY >= 80 && DrawY < 187) 
			 begin
				 case(intro_num2)
				 4'd2:
				 begin
					is_intro2 = 1'b1;
					is_intro4 = 1'b0;
					is_intro6 = 1'b0;
					is_intro8 = 1'b0;
					is_intro10 = 1'b0;
				 end
				 4'd4:
				 begin
					is_intro2 = 1'b0;
					is_intro4 = 1'b1;
					is_intro6 = 1'b0;
					is_intro8 = 1'b0;
					is_intro10 = 1'b0;
				 end
				 4'd6:
				 begin
					is_intro2 = 1'b0;
					is_intro4 = 1'b0;
					is_intro6 = 1'b1;
					is_intro8 = 1'b0;
					is_intro10 = 1'b0;
				 end
				 4'd8:
				 begin
					is_intro2 = 1'b0;
					is_intro4 = 1'b0;
					is_intro6 = 1'b0;
					is_intro8 = 1'b1;
					is_intro10 = 1'b0;
				 end
				 4'd10:
				 begin
					is_intro2 = 1'b0;
					is_intro4 = 1'b0;
					is_intro6 = 1'b0;
					is_intro8 = 1'b0;
					is_intro10 = 1'b1;
				 end
				 default:
				 begin
					is_intro2 = 1'b0;
					is_intro4 = 1'b0;
					is_intro6 = 1'b0;
					is_intro8 = 1'b0;
					is_intro10 = 1'b0;
				 end
				 endcase
				 intro_address = DrawX - 360 + (DrawY - 80) * 199;
			 end
		end
	end

endmodule

module  intro1_rom
(
		input [19:0] intro1_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro1_address]];

initial
begin
	 $readmemh("sprite_bytes/intro1.txt", mem);
end

endmodule

module  intro2_rom
(
		input [19:0] intro2_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro2_address]];

initial
begin
	 $readmemh("sprite_bytes/intro2.txt", mem);
end

endmodule

module  intro3_rom
(
		input [19:0] intro3_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro3_address]];

initial
begin
	 $readmemh("sprite_bytes/intro3.txt", mem);
end

endmodule

module  intro4_rom
(
		input [19:0] intro4_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro4_address]];

initial
begin
	 $readmemh("sprite_bytes/intro4.txt", mem);
end

endmodule

module  intro5_rom
(
		input [19:0] intro5_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro5_address]];

initial
begin
	 $readmemh("sprite_bytes/intro5.txt", mem);
end

endmodule

module  intro6_rom
(
		input [19:0] intro6_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro6_address]];

initial
begin
	 $readmemh("sprite_bytes/intro6.txt", mem);
end

endmodule

module  intro7_rom
(
		input [19:0] intro7_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro7_address]];

initial
begin
	 $readmemh("sprite_bytes/intro7.txt", mem);
end

endmodule

module  intro8_rom
(
		input [19:0] intro8_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro8_address]];

initial
begin
	 $readmemh("sprite_bytes/intro8.txt", mem);
end

endmodule

module  intro9_rom
(
		input [19:0] intro9_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro9_address]];

initial
begin
	 $readmemh("sprite_bytes/intro9.txt", mem);
end

endmodule

module  intro10_rom
(
		input [19:0] intro10_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'hc08226;
assign col[1] = 24'h854a1d;
assign col[2] = 24'h2c1708;
assign col[3] = 24'h643214;
assign col[4] = 24'h4a290b;

assign color_out = col[mem[intro10_address]];

initial
begin
	 $readmemh("sprite_bytes/intro10.txt", mem);
end

endmodule

module  font1_rom
(
		input [6:0] font1_address,
		output logic [5:0] font_out
);

// mem has width of 8 bits and a total of 128 addresses
logic [7:0] mem [0:127];

assign font_out = mem[font1_address];

initial
begin
	 $readmemh("sprite_bytes/font1.txt", mem);
end

endmodule

module  font2_rom
(
		input [6:0] font2_address,
		output logic [5:0] font_out
);

// mem has width of 8 bits and a total of 128 addresses
logic [7:0] mem [0:127];

assign font_out = mem[font2_address];

initial
begin
	 $readmemh("sprite_bytes/font2.txt", mem);
end

endmodule

module  font3_rom
(
		input [6:0] font3_address,
		output logic [5:0] font_out
);

// mem has width of 8 bits and a total of 128 addresses
logic [7:0] mem [0:127];

assign font_out = mem[font3_address];

initial
begin
	 $readmemh("sprite_bytes/font3.txt", mem);
end

endmodule

module  font4_rom
(
		input [6:0] font4_address,
		output logic [5:0] font_out
);

// mem has width of 8 bits and a total of 128 addresses
logic [7:0] mem [0:127];

assign font_out = mem[font4_address];

initial
begin
	 $readmemh("sprite_bytes/font4.txt", mem);
end

endmodule

module  font5_rom
(
		input [6:0] font5_address,
		output logic [5:0] font_out
);

// mem has width of 8 bits and a total of 128 addresses
logic [7:0] mem [0:127];

assign font_out = mem[font5_address];

initial
begin
	 $readmemh("sprite_bytes/font5.txt", mem);
end

endmodule

module  font6_rom
(
		input [6:0] font6_address,
		output logic [5:0] font_out
);

// mem has width of 8 bits and a total of 128 addresses
logic [7:0] mem [0:127];

assign font_out = mem[font6_address];

initial
begin
	 $readmemh("sprite_bytes/font6.txt", mem);
end

endmodule
