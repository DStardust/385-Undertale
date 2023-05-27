module map2
(
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_map2,					// Whether current pixel belongs to background
		output logic [19:0] map2_address		// address for color mapper to figure out what color the logo pixel should be
);

always_comb
	begin
		is_map2 = 1'b0;
		map2_address = 20'b0;
		if(status == 4'd4)
		begin
			 if (DrawX >= 162 && DrawX < 478 && DrawY >= 204 && DrawY < 304) 
			 begin
				is_map2 = 1'b1;
				map2_address = DrawX - 162 + (DrawY - 204) * 316;
			 end
		end
	end

endmodule

module  map2_rom
(
		input [19:0] map2_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hfff200;
assign col[2] = 24'hfeffdf;
assign col[3] = 24'hfafefe;
assign col[4] = 24'h9bfd71;
assign col[5] = 24'h3a3948;
assign col[6] = 24'h5f5e77;
assign col[7] = 24'hc8c2e2;
assign col[8] = 24'h22b14c;

assign color_out = col[mem[map2_address]];

initial
begin
	 $readmemh("sprite_bytes/map2.txt", mem);
end

endmodule
