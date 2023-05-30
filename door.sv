module door
(
		input  Clk, frame_clk,
		input Reset,
		input [3:0] status,
		input [7:0]	  keycode,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		output logic is_door,					// Whether current pixel belongs to background
		output logic [19:0] door_address		// address for color mapper to figure out what color the logo pixel should be
);

//always_comb
//	begin
//		is_door = 1'b0;
//		door_address = 20'b0;
//		if(status == 4'd3)
//		begin
//			 if (DrawX >= 130 && DrawX < 640 && DrawY >= 180 && DrawY < 300) 
//			 begin
//				is_door = 1'b1;
//				door_address = DrawX - 130 + (DrawY - 180) * 750;
//			 end
//		end
//	end
	parameter [9:0] door_X_Init = 10'd698;  // Center position on the X axis
    parameter [9:0] door_X_Min = 10'd458;       // Leftmost point on the X axis
    parameter [9:0] door_X_Max = 10'd698;     // Rightmost point on the X axis
    parameter [9:0] door_X_Step = 10'd1;      // Step size on the X axis

	logic [9:0] door_X_Pos, door_X_Motion;
    logic [9:0] door_X_Pos_in, door_X_Motion_in;
	 logic mark_xmin, mark_xmax;
    
	logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

	always_ff @ (posedge Clk)
    begin
        if (status != 4'd3)
        begin
            door_X_Pos <= door_X_Init;
            door_X_Motion <= 10'd0;
        end
        else
        begin
            door_X_Pos <= door_X_Pos_in;
            door_X_Motion <= door_X_Motion_in;
        end
    end

	always_comb
    begin
        // By default, keep motion and position unchanged
        door_X_Pos_in = door_X_Pos;
        door_X_Motion_in = door_X_Motion;
		mark_xmax = 1'b0;
		mark_xmin = 1'b0;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. door_Y_Pos - door_Size <= door_Y_Min 
            // If door_Y_Pos is 0, then door_Y_Pos - door_Size will not be -4, but rather a large positive number.
				
					case (keycode)
						8'd07:
						begin
							
							if ( door_X_Pos <= door_X_Min ) begin// door is at the left edge!
								door_X_Motion_in = 10'b0;
								mark_xmin = 1'b1;
							end
							else begin
								door_X_Motion_in = (~(door_X_Step) + 1'b1);
							end
						end

						8'd04:
						begin
							
							if( door_X_Pos >= door_X_Max ) begin// door is at the right edge!
								door_X_Motion_in = 10'b0;
								mark_xmax = 1'b1;
							end
							else begin
								door_X_Motion_in = door_X_Step;
							end
						end
						default: 
						begin
							door_X_Motion_in = 10'd0;
						end
					endcase
        
            // Update the door's position with its motion
				if (mark_xmin) begin
					door_X_Pos_in = door_X_Min;
				end
				else if (mark_xmax) begin
					door_X_Pos_in = door_X_Max;
				end
				else begin
					door_X_Pos_in = door_X_Pos + door_X_Motion;
				end
        end
	end

	int DistX;
    assign DistX = DrawX - door_X_Pos;
    always_comb begin
        if ( DistX >= 0 && DistX < 182 && DrawY >= 22 && DrawY < 180 && status == 4'd3) begin
            is_door = 1'b1;
			door_address = DistX + (DrawY - 22) * 182;
			end
        else begin
            is_door = 1'b0;
			door_address = 20'b0;
        /* The door's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
			  end
    end
endmodule

module  door_rom
(
		input [19:0] door_address,
		output logic [23:0] color_out
);

// mem has width of 4 bits and a total of 32768 addresses
logic [3:0] mem [0:32767];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3a3948;

assign color_out = col[mem[door_address]];

initial
begin
	 $readmemh("sprite_bytes/door.txt", mem);
end

endmodule
