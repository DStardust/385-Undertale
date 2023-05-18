module title
(
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_title,					// Whether current pixel belongs to background
		output logic [19:0] title_address		// address for color mapper to figure out what color the logo pixel should be
);

always_comb
	begin
		is_title = 1'b0;
		title_address = 20'b0;
		if(status == 4'd1)
		begin
			 if (DrawX >= 224 && DrawX < 416 && DrawY >= 224 && DrawY < 256) 
			 begin
				is_title = 1'b1;
				title_address = DrawX - 224 + (DrawY - 224) * 192;
			 end
		end
	end

endmodule

module  title_rom
(
		input [19:0] title_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:8191];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h818181;
assign col[2] = 24'hff0000;
assign col[3] = 24'hffffff;

assign color_out = col[mem[title_address]];

initial
begin
	 $readmemh("sprite_bytes/title.txt", mem);
end

endmodule
