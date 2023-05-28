module win
(
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_win,					// Whether current pixel belongs to background
		output logic [19:0] win_address		// address for color mapper to figure out what color the logo pixel should be
);

always_comb
	begin
		is_win = 1'b0;
		win_address = 20'b0;
		if(status == 4'd6)
		begin
			 if (DrawX >= 174 && DrawX < 466 && DrawY >= 222 && DrawY < 258) 
			 begin
				is_win = 1'b1;
				win_address = DrawX - 174 + (DrawY - 222) * 292;
			 end
		end
	end

endmodule

module  win_rom
(
		input [19:0] win_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:16383];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h818181;
assign col[2] = 24'hff0000;
assign col[3] = 24'hffffff;

assign color_out = col[mem[win_address]];

initial
begin
	 $readmemh("sprite_bytes/win.txt", mem);
end

endmodule

module lose
(
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_lose,					// Whether current pixel belongs to background
		output logic [19:0] lose_address		// address for color mapper to figure out what color the logo pixel should be
);

always_comb
	begin
		is_lose = 1'b0;
		lose_address = 20'b0;
		if(status == 4'd7)
		begin
			 if (DrawX >= 164 && DrawX < 476 && DrawY >= 222 && DrawY < 258) 
			 begin
				is_lose = 1'b1;
				lose_address = DrawX - 164 + (DrawY - 222) * 312;
			 end
		end
	end

endmodule

module  lose_rom
(
		input [19:0] lose_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:16383];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h818181;
assign col[2] = 24'hff0000;
assign col[3] = 24'hffffff;

assign color_out = col[mem[lose_address]];

initial
begin
	 $readmemh("sprite_bytes/lose.txt", mem);
end

endmodule