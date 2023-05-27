module map1
(
		input  Clk, frame_clk,
		input Reset,
		input [3:0] status,
		input [7:0]	  keycode,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		output logic is_map1,					// Whether current pixel belongs to background
		output logic [19:0] map1_address		// address for color mapper to figure out what color the logo pixel should be
);

//always_comb
//	begin
//		is_map1 = 1'b0;
//		map1_address = 20'b0;
//		if(status == 4'd3)
//		begin
//			 if (DrawX >= 130 && DrawX < 640 && DrawY >= 180 && DrawY < 300) 
//			 begin
//				is_map1 = 1'b1;
//				map1_address = DrawX - 130 + (DrawY - 180) * 750;
//			 end
//		end
//	end
	parameter [9:0] map1_X_Init = 10'd639;  // Center position on the X axis
    parameter [9:0] map1_X_Min = 10'd399;       // Leftmost point on the X axis
    parameter [9:0] map1_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] map1_X_Step = 10'd1;      // Step size on the X axis

	logic [9:0] map1_X_Pos, map1_X_Motion;
    logic [9:0] map1_X_Pos_in, map1_X_Motion_in;
	 logic mark_xmin, mark_xmax;
    
	logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

	always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            map1_X_Pos <= map1_X_Init;
            map1_X_Motion <= 10'd0;
        end
        else
        begin
            map1_X_Pos <= map1_X_Pos_in;
            map1_X_Motion <= map1_X_Motion_in;
        end
    end

	always_comb
    begin
        // By default, keep motion and position unchanged
        map1_X_Pos_in = map1_X_Pos;
        map1_X_Motion_in = map1_X_Motion;
		mark_xmax = 1'b0;
		mark_xmin = 1'b0;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. map1_Y_Pos - map1_Size <= map1_Y_Min 
            // If map1_Y_Pos is 0, then map1_Y_Pos - map1_Size will not be -4, but rather a large positive number.
            
            // TODO: Add other boundary detections and handle keypress here.
             
					case (keycode)
						8'd07:
						begin
							
							if ( map1_X_Pos <= map1_X_Min ) begin// map1 is at the left edge, BOUNCE!
								map1_X_Motion_in = 10'b0;
								mark_xmin = 1'b1;
							end
							else begin
								map1_X_Motion_in = (~(map1_X_Step) + 1'b1);
							end
						end

						8'd04:
						begin
							
							if( map1_X_Pos >= map1_X_Max ) begin// map1 is at the right edge, BOUNCE!
								map1_X_Motion_in = 10'b0;
								mark_xmax = 1'b1;
							end
							else begin
								map1_X_Motion_in = map1_X_Step;
							end
						end
						default: 
						begin
							map1_X_Motion_in = 10'd0;
						end
					endcase
        
            // Update the map1's position with its motion
				if (mark_xmin) begin
					map1_X_Pos_in = map1_X_Min;
				end
				else if (mark_xmax) begin
					map1_X_Pos_in = map1_X_Max;
				end
				else begin
					map1_X_Pos_in = map1_X_Pos + map1_X_Motion;
				end
        end
	end

	int DistX;
    assign DistX = DrawX - map1_X_Pos;
    always_comb begin
        if ( DistX >= -510 && DistX < 240 && DrawY >= 180 && DrawY < 300 && status == 4'd3) begin
            is_map1 = 1'b1;
			map1_address = DistX + 510 + (DrawY - 180) * 750;
			end
        else begin
            is_map1 = 1'b0;
			map1_address = 20'b0;
        /* The map1's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
			  end
    end
endmodule

module  map1_rom
(
		input [19:0] map1_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:131071];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3a3948;
assign col[2] = 24'h5f5e77;
assign col[3] = 24'hc8c2e2;
assign col[4] = 24'h22b14c;
assign col[5] = 24'hf9f000;
assign col[6] = 24'hdbb100;
assign col[7] = 24'h7c6a00;

assign color_out = col[mem[map1_address]];

initial
begin
	 $readmemh("sprite_bytes/map1.txt", mem);
end

endmodule
