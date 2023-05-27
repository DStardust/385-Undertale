module frisk_move
(
		input  Clk, frame_clk,
		input Reset,
		input [3:0] status,
		input [7:0]	  keycode,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		output logic is_frisk,					// Whether current pixel belongs to background
		output logic [19:0] frisk_address,		// address for color mapper to figure out what color the logo pixel should be
		output logic arrived_door
);

	parameter [9:0] Frisk_X_Init = 10'd301;  // Center position on the X axis
    parameter [9:0] Frisk_Y_Init = 10'd191;  // Center position on the Y axis
    parameter [9:0] Frisk_X_Min = 10'd130;       // Leftmost point on the X axis
    parameter [9:0] Frisk_X_Max = 10'd602;     // Rightmost point on the X axis
    parameter [9:0] Frisk_Y_Min = 10'd130;       // Topmost point on the Y axis
    parameter [9:0] Frisk_Y_Max = 10'd242;     // Bottommost point on the Y axis
    parameter [9:0] Frisk_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Frisk_Y_Step = 10'd1;      // Step size on the Y axis

	logic [9:0] Frisk_X_Pos, Frisk_X_Motion, Frisk_Y_Pos, Frisk_Y_Motion;
    logic [9:0] Frisk_X_Pos_in, Frisk_X_Motion_in, Frisk_Y_Pos_in, Frisk_Y_Motion_in;
	 logic mark_xmin, mark_xmax, mark_ymin, mark_ymax;
    
	logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

	always_ff @ (posedge Clk)
    begin
        if (status != 4'd3)
        begin
            Frisk_X_Pos <= Frisk_X_Init;
            Frisk_Y_Pos <= Frisk_Y_Init;
            Frisk_X_Motion <= 10'd0;
            Frisk_Y_Motion <= 10'd0;
        end
        else
        begin
            Frisk_X_Pos <= Frisk_X_Pos_in;
            Frisk_Y_Pos <= Frisk_Y_Pos_in;
            Frisk_X_Motion <= Frisk_X_Motion_in;
            Frisk_Y_Motion <= Frisk_Y_Motion_in;
        end
    end

	always_comb
    begin
        // By default, keep motion and position unchanged
        Frisk_X_Pos_in = Frisk_X_Pos;
        Frisk_Y_Pos_in = Frisk_Y_Pos;
        Frisk_X_Motion_in = Frisk_X_Motion;
        Frisk_Y_Motion_in = Frisk_Y_Motion;
		  mark_ymin = 1'b0;
		  mark_xmax = 1'b0;
		  mark_xmin = 1'b0;
		  mark_ymax = 1'b0;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Frisk_Y_Pos - Frisk_Size <= Frisk_Y_Min 
            // If Frisk_Y_Pos is 0, then Frisk_Y_Pos - Frisk_Size will not be -4, but rather a large positive number.
            
            // TODO: Add other boundary detections and handle keypress here.
             
					case (keycode)
						8'd26:
						begin
							
							if ( Frisk_Y_Pos <= Frisk_Y_Min ) begin // Frisk is at the top edge, BOUNCE!
								Frisk_Y_Motion_in = 10'b0;
								mark_ymin = 1'b1;
							end
							else begin
								Frisk_Y_Motion_in = (~(Frisk_Y_Step) + 1'b1);
								Frisk_X_Motion_in = 10'b0;
								
							end
						end
						8'd04:
						begin
							
							if ( Frisk_X_Pos <= Frisk_X_Min ) begin// Frisk is at the left edge, BOUNCE!
								Frisk_X_Motion_in = 10'b0;
								mark_xmin = 1'b1;
							end
							else begin
								Frisk_X_Motion_in = (~(Frisk_X_Step) + 1'b1);
								Frisk_Y_Motion_in = 10'b0;
								
							end
						end
						8'd22:
						begin
							
							if( Frisk_Y_Pos >= Frisk_Y_Max ) begin // Frisk is at the bottom edge, BOUNCE!
								Frisk_Y_Motion_in = 10'b0;
								mark_ymax = 1'b1;
							end
							else begin
								Frisk_Y_Motion_in = Frisk_Y_Step;
								Frisk_X_Motion_in = 10'b0;
								
							end
						end
						8'd07:
						begin
							
							if( Frisk_X_Pos >= Frisk_X_Max ) begin// Frisk is at the right edge, BOUNCE!
								Frisk_X_Motion_in = 10'b0;
								mark_xmax = 1'b1;
								
							end
							else begin
								Frisk_X_Motion_in = Frisk_X_Step;
								Frisk_Y_Motion_in = 10'b0;
							
							end
						end
						default: 
						begin
							Frisk_X_Motion_in = 10'd0;
							Frisk_Y_Motion_in = 10'd0;
						end
					endcase
        
            // Update the Frisk's position with its motion
				if (mark_xmin) begin
					Frisk_X_Pos_in = Frisk_X_Min;
					Frisk_Y_Pos_in = Frisk_Y_Pos + Frisk_Y_Motion;
				end
				else if (mark_xmax) begin
					Frisk_X_Pos_in = Frisk_X_Max;
					Frisk_Y_Pos_in = Frisk_Y_Pos + Frisk_Y_Motion;
				end
				else if (mark_ymin) begin
					Frisk_X_Pos_in = Frisk_X_Pos + Frisk_X_Motion;
					Frisk_Y_Pos_in = Frisk_Y_Min;
				end
				else if (mark_ymax) begin
					Frisk_X_Pos_in = Frisk_X_Pos + Frisk_X_Motion;
					Frisk_Y_Pos_in = Frisk_Y_Max;
				end
				else begin
					Frisk_X_Pos_in = Frisk_X_Pos + Frisk_X_Motion;
					Frisk_Y_Pos_in = Frisk_Y_Pos + Frisk_Y_Motion;
				end
			
        end
	end

	int DistX, DistY;
    assign DistX = DrawX - Frisk_X_Pos;
    assign DistY = DrawY - Frisk_Y_Pos;
    always_comb begin
        if ( DistX >= 0 && DistX < 38 && DistY >= 0 && DistY < 58 && status == 4'd3) begin
            is_frisk = 1'b1;
				frisk_address = DrawX - Frisk_X_Pos + (DrawY - Frisk_Y_Pos) * 38;
		  end
        else begin
            is_frisk = 1'b0;
				frisk_address = 20'b0;
        /* The Frisk's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
		  end
		  if ( Frisk_X_Pos >= 520 && Frisk_X_Pos < 580 && Frisk_Y_Pos >= 130 && Frisk_Y_Pos < 140 && status == 4'd3) begin
            arrived_door = 1'b1;
		  end
        else begin
            arrived_door = 1'b0;
		  end
    end
endmodule

module frisk_move2
(
		input  Clk, frame_clk,
		input Reset,
		input [3:0] status,
		input [7:0]	  keycode,
		input  logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		output logic is_frisk,					// Whether current pixel belongs to background
		output logic [19:0] frisk_address,		// address for color mapper to figure out what color the logo pixel should be
		output logic arrived_monster
);

	parameter [9:0] Frisk_X_Init = 10'd301;  // Center position on the X axis
    parameter [9:0] Frisk_Y_Init = 10'd400;  // Center position on the Y axis
    parameter [9:0] Frisk_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Frisk_X_Max = 10'd602;     // Rightmost point on the X axis
    parameter [9:0] Frisk_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Frisk_Y_Max = 10'd422;     // Bottommost point on the Y axis
    parameter [9:0] Frisk_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Frisk_Y_Step = 10'd1;      // Step size on the Y axis

	logic [9:0] Frisk_X_Pos, Frisk_X_Motion, Frisk_Y_Pos, Frisk_Y_Motion;
    logic [9:0] Frisk_X_Pos_in, Frisk_X_Motion_in, Frisk_Y_Pos_in, Frisk_Y_Motion_in;
	 logic mark_xmin, mark_xmax, mark_ymin, mark_ymax;
    
	logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

	always_ff @ (posedge Clk)
    begin
        if (status != 4'd4)
        begin
            Frisk_X_Pos <= Frisk_X_Init;
            Frisk_Y_Pos <= Frisk_Y_Init;
            Frisk_X_Motion <= 10'd0;
            Frisk_Y_Motion <= 10'd0;
        end
        else
        begin
            Frisk_X_Pos <= Frisk_X_Pos_in;
            Frisk_Y_Pos <= Frisk_Y_Pos_in;
            Frisk_X_Motion <= Frisk_X_Motion_in;
            Frisk_Y_Motion <= Frisk_Y_Motion_in;
        end
    end

	always_comb
    begin
        // By default, keep motion and position unchanged
        Frisk_X_Pos_in = Frisk_X_Pos;
        Frisk_Y_Pos_in = Frisk_Y_Pos;
        Frisk_X_Motion_in = Frisk_X_Motion;
        Frisk_Y_Motion_in = Frisk_Y_Motion;
		  mark_ymin = 1'b0;
		  mark_xmax = 1'b0;
		  mark_xmin = 1'b0;
		  mark_ymax = 1'b0;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Frisk_Y_Pos - Frisk_Size <= Frisk_Y_Min 
            // If Frisk_Y_Pos is 0, then Frisk_Y_Pos - Frisk_Size will not be -4, but rather a large positive number.
            
            // TODO: Add other boundary detections and handle keypress here.
             
					case (keycode)
						8'd26:
						begin
							
							if ( Frisk_Y_Pos <= Frisk_Y_Min ) begin // Frisk is at the top edge, BOUNCE!
								Frisk_Y_Motion_in = 10'b0;
								mark_ymin = 1'b1;
							end
							else begin
								Frisk_Y_Motion_in = (~(Frisk_Y_Step) + 1'b1);
								Frisk_X_Motion_in = 10'b0;
								
							end
						end
						8'd04:
						begin
							
							if ( Frisk_X_Pos <= Frisk_X_Min ) begin// Frisk is at the left edge, BOUNCE!
								Frisk_X_Motion_in = 10'b0;
								mark_xmin = 1'b1;
							end
							else begin
								Frisk_X_Motion_in = (~(Frisk_X_Step) + 1'b1);
								Frisk_Y_Motion_in = 10'b0;
								
							end
						end
						8'd22:
						begin
							
							if( Frisk_Y_Pos >= Frisk_Y_Max ) begin // Frisk is at the bottom edge, BOUNCE!
								Frisk_Y_Motion_in = 10'b0;
								mark_ymax = 1'b1;
							end
							else begin
								Frisk_Y_Motion_in = Frisk_Y_Step;
								Frisk_X_Motion_in = 10'b0;
								
							end
						end
						8'd07:
						begin
							
							if( Frisk_X_Pos >= Frisk_X_Max ) begin// Frisk is at the right edge, BOUNCE!
								Frisk_X_Motion_in = 10'b0;
								mark_xmax = 1'b1;
								
							end
							else begin
								Frisk_X_Motion_in = Frisk_X_Step;
								Frisk_Y_Motion_in = 10'b0;
							
							end
						end
						default: 
						begin
							Frisk_X_Motion_in = 10'd0;
							Frisk_Y_Motion_in = 10'd0;
						end
					endcase
        
            // Update the Frisk's position with its motion
				if (mark_xmin) begin
					Frisk_X_Pos_in = Frisk_X_Min;
					Frisk_Y_Pos_in = Frisk_Y_Pos + Frisk_Y_Motion;
				end
				else if (mark_xmax) begin
					Frisk_X_Pos_in = Frisk_X_Max;
					Frisk_Y_Pos_in = Frisk_Y_Pos + Frisk_Y_Motion;
				end
				else if (mark_ymin) begin
					Frisk_X_Pos_in = Frisk_X_Pos + Frisk_X_Motion;
					Frisk_Y_Pos_in = Frisk_Y_Min;
				end
				else if (mark_ymax) begin
					Frisk_X_Pos_in = Frisk_X_Pos + Frisk_X_Motion;
					Frisk_Y_Pos_in = Frisk_Y_Max;
				end
				else begin
					Frisk_X_Pos_in = Frisk_X_Pos + Frisk_X_Motion;
					Frisk_Y_Pos_in = Frisk_Y_Pos + Frisk_Y_Motion;
				end
			
        end
	end

	int DistX, DistY;
    assign DistX = DrawX - Frisk_X_Pos;
    assign DistY = DrawY - Frisk_Y_Pos;
    always_comb begin
        if ( DistX >= 0 && DistX < 38 && DistY >= 0 && DistY < 58 && status == 4'd4) begin
            is_frisk = 1'b1;
				frisk_address = DrawX - Frisk_X_Pos + (DrawY - Frisk_Y_Pos) * 38;
		  end
        else begin
            is_frisk = 1'b0;
				frisk_address = 20'b0;
        /* The Frisk's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
		  end
		  if ( Frisk_X_Pos >= 260 && Frisk_X_Pos < 340 && Frisk_Y_Pos >= 146 && Frisk_Y_Pos < 206 && status == 4'd4) begin
            arrived_monster = 1'b1;
		  end
        else begin
            arrived_monster = 1'b0;
		  end
    end
endmodule

module  frisk1_rom
(
		input [19:0] frisk1_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk1_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk1.txt", mem);
end

endmodule

module  frisk2_rom
(
		input [19:0] frisk2_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk2_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk2.txt", mem);
end

endmodule

module  frisk3_rom
(
		input [19:0] frisk3_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk3_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk3.txt", mem);
end

endmodule

module  frisk4_rom
(
		input [19:0] frisk4_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk4_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk4.txt", mem);
end

endmodule

module  frisk5_rom
(
		input [19:0] frisk5_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk5_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk5.txt", mem);
end

endmodule

module  frisk6_rom
(
		input [19:0] frisk6_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk6_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk6.txt", mem);
end

endmodule

module  frisk7_rom
(
		input [19:0] frisk7_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk7_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk7.txt", mem);
end

endmodule

module  frisk8_rom
(
		input [19:0] frisk8_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk8_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk8.txt", mem);
end

endmodule

module  frisk9_rom
(
		input [19:0] frisk9_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk9_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk9.txt", mem);
end

endmodule

module  frisk10_rom
(
		input [19:0] frisk10_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:4095];

logic [23:0] col [7:0];
assign col[0] = 24'h000000;
assign col[1] = 24'h3d120e;
assign col[2] = 24'h67a4e0;
assign col[3] = 24'he607f8;
assign col[4] = 24'hffc90e;
assign col[5] = 24'hffffff;

assign color_out = col[mem[frisk10_address]];

initial
begin
	 $readmemh("sprite_bytes/Frisk10.txt", mem);
end

endmodule
