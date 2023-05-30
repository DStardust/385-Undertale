module field
(
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_field,					// Whether current pixel belongs to background
		output logic [19:0] field_address		// address for color mapper to figure out what color the logo pixel should be
);

always_comb // display the battlefield at the specific position
	begin
		is_field = 1'b0;
		field_address = 20'b0;
		if(status == 4'd5)
		begin
			 if (DrawX >= 238 && DrawX < 403 && DrawY >= 239 && DrawY < 379) 
			 begin
				is_field = 1'b1;
				field_address = DrawX - 238 + (DrawY - 239) * 165;
			 end
		end
	end

endmodule

module  field_rom
(
		input [19:0] field_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hffffff;

assign color_out = col[mem[field_address]];

initial
begin
	 $readmemh("sprite_bytes/field.txt", mem);
end

endmodule
