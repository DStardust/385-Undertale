module flower
(
		input logic frame_clk,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input	 logic [3:0] status,
		output logic is_flower1,					// Whether current pixel belongs to background
		output logic is_flower2,
		output logic is_flower3,
		output logic time_up,
		output logic start_bullet,
		output logic [19:0] flower_address		// address for color mapper to figure out what color the logo pixel should be
);

logic [2:0] flower_num;
logic [11:0] counter;

always_ff @(posedge frame_clk) begin // counter inside to check if the time reaches 1min and display the animation of the flower
	if(status == 4'd5)
	begin
		case (counter)
			12'd1:
			begin
				flower_num <= 3'd1;
				start_bullet <= 1'b0;
				counter ++;
			end
			12'd120:
			begin
				flower_num <= 3'd2;
				start_bullet <= 1'b0;
				counter ++;
			end
			12'd240:
			begin
				flower_num <= 3'd3;
				start_bullet <= 1'b1;
				counter ++;
			end
			12'd3840:
			begin
				time_up = 1'b1;
			end
			default:
			begin
				time_up = 1'b0;
				counter ++;
			end
		endcase
	end
	else begin
		time_up = 1'b0;
		counter <= 12'b0;
		flower_num <= 3'd0;
		start_bullet <= 1'b0;
	end
end

always_comb // using flower_num to display different image of flower at the same position
	begin
		is_flower1 = 1'b0;
		is_flower2 = 1'b0;
		is_flower3 = 1'b0;
		flower_address = 20'b0;
		if(status == 4'd5) // at scene 5
		begin
			 if (DrawX >= 279 && DrawX < 361 && DrawY >= 124 && DrawY < 210) 
			 begin
				case (flower_num)
				3'd1:
				begin
					is_flower1 = 1'b1;
					is_flower2 = 1'b0;
					is_flower3 = 1'b0;
				end
				3'd2:
				begin
					is_flower1 = 1'b0;
					is_flower2 = 1'b1;
					is_flower3 = 1'b0;
				end
				3'd3:
				begin
					is_flower1 = 1'b0;
					is_flower2 = 1'b0;
					is_flower3 = 1'b1;
				end
				default: 
				begin
					is_flower1 = 1'b0;
					is_flower2 = 1'b0;
					is_flower3 = 1'b0;
				end
				endcase
				flower_address = DrawX - 279 + (DrawY - 124) * 82;
			 end
		end
	end

endmodule

module  flower1_rom
(
		input [19:0] flower_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 8192 addresses
logic [3:0] mem [0:8191];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hffffff;

assign color_out = col[mem[flower_address]];

initial
begin
	 $readmemh("sprite_bytes/flower1.txt", mem);
end

endmodule

module  flower2_rom
(
		input [19:0] flower_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 8192 addresses
logic [3:0] mem [0:8191];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hffffff;

assign color_out = col[mem[flower_address]];

initial
begin
	 $readmemh("sprite_bytes/flower2.txt", mem);
end

endmodule

module  flower3_rom
(
		input [19:0] flower_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 8192 addresses
logic [3:0] mem [0:8191];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hffffff;

assign color_out = col[mem[flower_address]];

initial
begin
	 $readmemh("sprite_bytes/flower3.txt", mem);
end

endmodule