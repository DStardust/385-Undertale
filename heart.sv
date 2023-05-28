module heart_move
(
		input  Clk, frame_clk,
		input Reset,
		input [3:0] status,
		input [7:0]	  keycode,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		output logic [9:0] PosXH, PosYH,
		output logic is_heart,					// Whether current pixel belongs to background
		output logic [19:0] heart_address		// address for color mapper to figure out what color the logo pixel should be
);

	 parameter [9:0] heart_X_Init = 10'd319;  // Center position on the X axis
    parameter [9:0] heart_Y_Init = 10'd317;  // Center position on the Y axis
    parameter [9:0] heart_X_Min = 10'd251;       // Leftmost point on the X axis
    parameter [9:0] heart_X_Max = 10'd390;     // Rightmost point on the X axis
    parameter [9:0] heart_Y_Min = 10'd252;       // Topmost point on the Y axis
    parameter [9:0] heart_Y_Max = 10'd366;     // Bottommost point on the Y axis
    parameter [9:0] heart_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] heart_Y_Step = 10'd1;      // Step size on the Y axis

	logic [9:0] heart_X_Pos, heart_X_Motion, heart_Y_Pos, heart_Y_Motion;
    logic [9:0] heart_X_Pos_in, heart_X_Motion_in, heart_Y_Pos_in, heart_Y_Motion_in;
	 logic mark_xmin, mark_xmax, mark_ymin, mark_ymax;
    
	logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

	always_ff @ (posedge Clk)
    begin
        if (status != 4'd5)
        begin
            heart_X_Pos <= heart_X_Init;
            heart_Y_Pos <= heart_Y_Init;
            heart_X_Motion <= 10'd0;
            heart_Y_Motion <= 10'd0;
        end
        else
        begin
            heart_X_Pos <= heart_X_Pos_in;
            heart_Y_Pos <= heart_Y_Pos_in;
            heart_X_Motion <= heart_X_Motion_in;
            heart_Y_Motion <= heart_Y_Motion_in;
				PosXH <= heart_X_Pos;
				PosYH <= heart_Y_Pos;
        end
    end

	always_comb
    begin
        // By default, keep motion and position unchanged
        heart_X_Pos_in = heart_X_Pos;
        heart_Y_Pos_in = heart_Y_Pos;
        heart_X_Motion_in = heart_X_Motion;
        heart_Y_Motion_in = heart_Y_Motion;
		  mark_ymin = 1'b0;
		  mark_xmax = 1'b0;
		  mark_xmin = 1'b0;
		  mark_ymax = 1'b0;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. heart_Y_Pos - heart_Size <= heart_Y_Min 
            // If heart_Y_Pos is 0, then heart_Y_Pos - heart_Size will not be -4, but rather a large positive number.
            
            // TODO: Add other boundary detections and handle keypress here.
             
					case (keycode)
						8'd26:
						begin
							
							if ( heart_Y_Pos <= heart_Y_Min ) begin // heart is at the top edge, BOUNCE!
								heart_Y_Motion_in = 10'b0;
								mark_ymin = 1'b1;
							end
							else begin
								heart_Y_Motion_in = (~(heart_Y_Step) + 1'b1);
								heart_X_Motion_in = 10'b0;
								
							end
						end
						8'd04:
						begin
							
							if ( heart_X_Pos <= heart_X_Min ) begin// heart is at the left edge, BOUNCE!
								heart_X_Motion_in = 10'b0;
								mark_xmin = 1'b1;
							end
							else begin
								heart_X_Motion_in = (~(heart_X_Step) + 1'b1);
								heart_Y_Motion_in = 10'b0;
								
							end
						end
						8'd22:
						begin
							
							if( heart_Y_Pos >= heart_Y_Max ) begin // heart is at the bottom edge, BOUNCE!
								heart_Y_Motion_in = 10'b0;
								mark_ymax = 1'b1;
							end
							else begin
								heart_Y_Motion_in = heart_Y_Step;
								heart_X_Motion_in = 10'b0;
								
							end
						end
						8'd07:
						begin
							
							if( heart_X_Pos >= heart_X_Max ) begin// heart is at the right edge, BOUNCE!
								heart_X_Motion_in = 10'b0;
								mark_xmax = 1'b1;
							end
							else begin
								heart_X_Motion_in = heart_X_Step;
								heart_Y_Motion_in = 10'b0;
							
							end
						end
						default: 
						begin
							heart_X_Motion_in = 10'd0;
							heart_Y_Motion_in = 10'd0;
						end
					endcase
        
            // Update the heart's position with its motion
				if (mark_xmin) begin
					heart_X_Pos_in = heart_X_Min;
					heart_Y_Pos_in = heart_Y_Pos + heart_Y_Motion;
				end
				else if (mark_xmax) begin
					heart_X_Pos_in = heart_X_Max;
					heart_Y_Pos_in = heart_Y_Pos + heart_Y_Motion;
				end
				else if (mark_ymin) begin
					heart_X_Pos_in = heart_X_Pos + heart_X_Motion;
					heart_Y_Pos_in = heart_Y_Min;
				end
				else if (mark_ymax) begin
					heart_X_Pos_in = heart_X_Pos + heart_X_Motion;
					heart_Y_Pos_in = heart_Y_Max;
				end
				else begin
					heart_X_Pos_in = heart_X_Pos + heart_X_Motion;
					heart_Y_Pos_in = heart_Y_Pos + heart_Y_Motion;
				end
			
        end
	end

	int DistX, DistY;
    assign DistX = DrawX - heart_X_Pos;
    assign DistY = DrawY - heart_Y_Pos;
    always_comb begin
        if ( DistX >= -8 && DistX < 8 && DistY >= -8 && DistY < 8 && status == 4'd5) begin
            is_heart = 1'b1;
				heart_address = DrawX - heart_X_Pos + 8 + (DrawY - heart_Y_Pos + 8) * 16;
		  end
        else begin
            is_heart = 1'b0;
				heart_address = 20'b0;
        /* The heart's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
		  end
    end
endmodule

module  heart_rom
(
		input [19:0] heart_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:255];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hff0000;

assign color_out = col[mem[heart_address]];

initial
begin
	 $readmemh("sprite_bytes/heart.txt", mem);
end

endmodule
