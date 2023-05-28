module bullets_move
(
		input  Clk, frame_clk,
		input Reset,
		input [9:0]	counter,
		input [3:0]   status,
		input [1:0] Difficulty,
		input logic [9:0] DrawX, DrawY,				// Current pixel coordinates
		input logic [9:0] PosXH, PosYH,	
		input logic start_bullet,
		output logic bullet_shape,
		output logic [3:0] HP,
		output logic is_bullets,					// Whether current pixel belongs to background
		output logic [19:0] bullets_address		// address for color mapper to figure out what color the logo pixel should be
);

	logic [5:0] in_counter;
	logic [9:0] b_address;
	logic is_bullet0, is_bullet1, is_bullet2, is_bullet3, is_bullet4, is_bullet5, is_bullet6, is_bullet7, is_bullet8, is_bullet9, 
	is_bullet10, is_bullet11, is_bullet12, is_bullet13, is_bullet14;
	
	logic is_collide0, is_collide1, is_collide2, is_collide3, is_collide4, is_collide5, is_collide6, is_collide7, is_collide8,
	is_collide9, is_collide10, is_collide11, is_collide12, is_collide13, is_collide14;

	logic [14:0] show_bullet, show_bullet_in;

	logic [3:0] bullet_num;

	assign is_bullets = is_bullet0 | is_bullet1 | is_bullet2 | is_bullet3 | is_bullet4 | is_bullet5 | is_bullet6 | is_bullet7
	| is_bullet8 | is_bullet9 | is_bullet10 | is_bullet11 | is_bullet12 | is_bullet13 | is_bullet14;

	rand_rom rand_rom(.CLK(Clk), .address(b_address), .bullet_num(bullet_num));
	
	always_ff @ (posedge frame_clk)
    begin
        if (status != 4'd5)
        begin
            HP = 4'd5;
        end
        else
        begin
            if (is_collide0)
				begin
					HP = HP-1;
				end
				if (is_collide1)
				begin
					HP = HP-1;
				end
				if (is_collide2)
				begin
					HP = HP-1;
				end
				if (is_collide3)
				begin
					HP = HP-1;
				end
				if (is_collide4)
				begin
					HP = HP-1;
				end
				if (is_collide5)
				begin
					HP = HP-1;
				end
				if (is_collide6)
				begin
					HP = HP-1;
				end
				if (is_collide7)
				begin
					HP = HP-1;
				end
				if (is_collide8)
				begin
					HP = HP-1;
				end
				if (is_collide9)
				begin
					HP = HP-1;
				end
				if (is_collide10)
				begin
					HP = HP-1;
				end
				if (is_collide11)
				begin
					HP = HP-1;
				end
				if (is_collide12)
				begin
					HP = HP-1;
				end
				if (is_collide13)
				begin
					HP = HP-1;
				end
				if (is_collide14)
				begin
					HP = HP-1;
				end
        end
    end
	 
	always_ff @(posedge frame_clk)
	begin
		if (status != 4'd5)
		begin
			bullet_shape = 1'b0;
			b_address <= 10'b0;
			in_counter <= 6'b0;
		end
		else
		begin
			if (in_counter <= 6'd15)
			begin
				bullet_shape = 1'b0;
				in_counter ++;
			end
			else if (in_counter < 6'd30)
			begin
				bullet_shape <= 1'b1;
				in_counter ++;
			end
			else if (in_counter == 6'd30)
			begin
				b_address <= counter;
				bullet_shape <= 1'b1;
				in_counter ++;
			end
			else if (in_counter <= 6'd45)
			begin
				bullet_shape <= 1'b0;
				in_counter ++;
			end
			else if (in_counter < 6'd60)
			begin
				bullet_shape <= 1'b1;
				in_counter ++;
			end
			else if (in_counter >= 6'd60)
			begin
				b_address <= counter;
				in_counter <= 6'b0;
			end
			else
				in_counter ++;
		end
	end

	parameter [9:0] bullet0_X_Init = 10'd120;  // Center position on the X axis
    parameter [9:0] bullet0_Y_Init = 10'd274;  // Center position on the Y axis
	parameter [9:0] bullet1_X_Init = 10'd120;  // Center position on the X axis
    parameter [9:0] bullet1_Y_Init = 10'd309;  // Center position on the Y axis
	parameter [9:0] bullet2_X_Init = 10'd120;  // Center position on the X axis
    parameter [9:0] bullet2_Y_Init = 10'd344;  // Center position on the Y axis
    parameter [9:0] bullet0_X_Max = 10'd633;     // Rightmost point on the X axis
	parameter [9:0] bullet1_X_Max = 10'd633;     // Rightmost point on the X axis
	parameter [9:0] bullet2_X_Max = 10'd633;     // Rightmost point on the X axis

	parameter [9:0] bullet3_X_Init = 10'd520;  // Center position on the X axis
    parameter [9:0] bullet3_Y_Init = 10'd274;  // Center position on the Y axis
	parameter [9:0] bullet4_X_Init = 10'd520;  // Center position on the X axis
    parameter [9:0] bullet4_Y_Init = 10'd309;  // Center position on the Y axis
	parameter [9:0] bullet5_X_Init = 10'd520;  // Center position on the X axis
    parameter [9:0] bullet5_Y_Init = 10'd344;  // Center position on the Y axis
    parameter [9:0] bullet3_X_Min = 10'd5;     // Rightmost point on the X axis
	parameter [9:0] bullet4_X_Min = 10'd5;     // Rightmost point on the X axis
	parameter [9:0] bullet5_X_Min = 10'd5;     // Rightmost point on the X axis

	parameter [9:0] bullet6_X_Init = 10'd279;  // Center position on the X axis
    parameter [9:0] bullet6_Y_Init = 10'd60;  // Center position on the Y axis
	parameter [9:0] bullet7_X_Init = 10'd320;  // Center position on the X axis
    parameter [9:0] bullet7_Y_Init = 10'd60;  // Center position on the Y axis
	parameter [9:0] bullet8_X_Init = 10'd361;  // Center position on the X axis
    parameter [9:0] bullet8_Y_Init = 10'd60;  // Center position on the Y axis
    parameter [9:0] bullet6_Y_Max = 10'd473;     // Rightmost point on the X axis
	parameter [9:0] bullet7_Y_Max = 10'd473;     // Rightmost point on the X axis
	parameter [9:0] bullet8_Y_Max = 10'd473;     // Rightmost point on the X axis

	parameter [9:0] bullet9_X_Init = 10'd115;  // Center position on the X axis
    parameter [9:0] bullet9_Y_Init = 10'd160;  // Center position on the Y axis
	parameter [9:0] bullet10_X_Init = 10'd145;  // Center position on the X axis
    parameter [9:0] bullet10_Y_Init = 10'd120;  // Center position on the Y axis
	parameter [9:0] bullet11_X_Init = 10'd175;  // Center position on the X axis
    parameter [9:0] bullet11_Y_Init = 10'd60;  // Center position on the Y axis
    parameter [9:0] bullet9_Y_Max = 10'd473;     // Rightmost point on the X axis
	parameter [9:0] bullet10_Y_Max = 10'd473;     // Rightmost point on the X axis
	parameter [9:0] bullet11_Y_Max = 10'd473;     // Rightmost point on the X axis

	parameter [9:0] bullet12_X_Init = 10'd524;  // Center position on the X axis
    parameter [9:0] bullet12_Y_Init = 10'd160;  // Center position on the Y axis
	parameter [9:0] bullet13_X_Init = 10'd494;  // Center position on the X axis
    parameter [9:0] bullet13_Y_Init = 10'd120;  // Center position on the Y axis
	parameter [9:0] bullet14_X_Init = 10'd464;  // Center position on the X axis
    parameter [9:0] bullet14_Y_Init = 10'd60;  // Center position on the Y axis
    parameter [9:0] bullet12_Y_Max = 10'd473;     // Rightmost point on the X axis
	parameter [9:0] bullet13_Y_Max = 10'd473;     // Rightmost point on the X axis
	parameter [9:0] bullet14_Y_Max = 10'd473;     // Rightmost point on the X axis

   logic [9:0] bullet_X_Step;      // Step size on the X axis
   logic [9:0] bullet_Y_Step;     // Step size on the Y axis

	logic [9:0] bullet0_X_Pos, bullet0_X_Motion;
	logic [9:0] bullet1_X_Pos, bullet1_X_Motion;
	logic [9:0] bullet2_X_Pos, bullet2_X_Motion;

	logic [9:0] bullet3_X_Pos, bullet3_X_Motion;
	logic [9:0] bullet4_X_Pos, bullet4_X_Motion;
	logic [9:0] bullet5_X_Pos, bullet5_X_Motion;

	logic [9:0] bullet6_Y_Pos, bullet6_Y_Motion;
	logic [9:0] bullet7_Y_Pos, bullet7_Y_Motion;
	logic [9:0] bullet8_Y_Pos, bullet8_Y_Motion;

	logic [9:0] bullet9_Y_Pos, bullet9_Y_Motion;
	logic [9:0] bullet10_Y_Pos, bullet10_Y_Motion;
	logic [9:0] bullet11_Y_Pos, bullet11_Y_Motion;
	logic [9:0] bullet9_X_Pos, bullet9_X_Motion;
	logic [9:0] bullet10_X_Pos, bullet10_X_Motion;
	logic [9:0] bullet11_X_Pos, bullet11_X_Motion;

	logic [9:0] bullet12_Y_Pos, bullet12_Y_Motion;
	logic [9:0] bullet13_Y_Pos, bullet13_Y_Motion;
	logic [9:0] bullet14_Y_Pos, bullet14_Y_Motion;
	logic [9:0] bullet12_X_Pos, bullet12_X_Motion;
	logic [9:0] bullet13_X_Pos, bullet13_X_Motion;
	logic [9:0] bullet14_X_Pos, bullet14_X_Motion;

    logic [9:0] bullet0_X_Pos_in, bullet1_X_Pos_in, bullet2_X_Pos_in;
	logic [9:0] bullet3_X_Pos_in, bullet4_X_Pos_in, bullet5_X_Pos_in;
	logic [9:0] bullet6_Y_Pos_in, bullet7_Y_Pos_in, bullet8_Y_Pos_in;
	logic [9:0] bullet9_X_Pos_in, bullet10_X_Pos_in, bullet11_X_Pos_in;
	logic [9:0] bullet9_Y_Pos_in, bullet10_Y_Pos_in, bullet11_Y_Pos_in;
	logic [9:0] bullet12_X_Pos_in, bullet13_X_Pos_in, bullet14_X_Pos_in;
	logic [9:0] bullet12_Y_Pos_in, bullet13_Y_Pos_in, bullet14_Y_Pos_in;

	logic bullet0_edge, bullet1_edge, bullet2_edge;
	logic bullet3_edge, bullet4_edge, bullet5_edge;
	logic bullet6_edge, bullet7_edge, bullet8_edge;
    logic bullet9_edge, bullet10_edge, bullet11_edge;
	logic bullet12_edge, bullet13_edge, bullet14_edge;

	assign bullet_X_Step = Difficulty;
	assign bullet_Y_Step = Difficulty;
	always_ff @ (posedge Clk)
    begin
        if ((status != 4'd5) || (start_bullet == 1'b0))
        begin
            show_bullet <= 15'd0;
        end
        else
        begin
            show_bullet <= show_bullet_in;
        end
    end
	 
	always_comb
    begin
		show_bullet_in = show_bullet;
		if (frame_clk_rising_edge)
			begin
				case (bullet_num)
				4'd0:
					show_bullet_in[0] = 1'b1;
				4'd1:
					show_bullet_in[1] = 1'b1;
				4'd2:
					show_bullet_in[2] = 1'b1;
				4'd3:
					show_bullet_in[3] = 1'b1;
				4'd4:
					show_bullet_in[4] = 1'b1;
				4'd5:
					show_bullet_in[5] = 1'b1;
				4'd6:
					show_bullet_in[6] = 1'b1;
				4'd7:
					show_bullet_in[7] = 1'b1;
				4'd8:
					show_bullet_in[8] = 1'b1;
				4'd9:
					show_bullet_in[9] = 1'b1;
				4'd10:
					show_bullet_in[10] = 1'b1;
				4'd11:
					show_bullet_in[11] = 1'b1;
				4'd12:
					show_bullet_in[12] = 1'b1;
				4'd13:
					show_bullet_in[13] = 1'b1;
				4'd14:
					show_bullet_in[14] = 1'b1;
				default: ;
				endcase
				if (bullet0_edge | is_collide0) 
					show_bullet_in[0] = 1'b0;
				if (bullet1_edge | is_collide1) 
					show_bullet_in[1] = 1'b0;
				if (bullet2_edge | is_collide2) 
					show_bullet_in[2] = 1'b0;
				if (bullet3_edge | is_collide3) 
					show_bullet_in[3] = 1'b0;
				if (bullet4_edge | is_collide4) 
					show_bullet_in[4] = 1'b0;
				if (bullet5_edge | is_collide5) 
					show_bullet_in[5] = 1'b0;
				if (bullet6_edge | is_collide6) 
					show_bullet_in[6] = 1'b0;
				if (bullet7_edge | is_collide7) 
					show_bullet_in[7] = 1'b0;
				if (bullet8_edge | is_collide8) 
					show_bullet_in[8] = 1'b0;
				if (bullet9_edge | is_collide9) 
					show_bullet_in[9] = 1'b0;
				if (bullet10_edge | is_collide10) 
					show_bullet_in[10] = 1'b0;
				if (bullet11_edge | is_collide11) 
					show_bullet_in[11] = 1'b0;
				if (bullet12_edge | is_collide12) 
					show_bullet_in[12] = 1'b0;
				if (bullet13_edge | is_collide13) 
					show_bullet_in[13] = 1'b0;
				if (bullet14_edge | is_collide14) 
					show_bullet_in[14] = 1'b0;
		end
	end

	logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

	always_ff @ (posedge Clk)
    begin
        if (status != 4'd5 | bullet0_edge | ~(show_bullet[0]))
        begin
            bullet0_X_Pos <= bullet0_X_Init;
            bullet0_X_Motion <= 10'd0;
        end
        else
        begin
            bullet0_X_Pos <= bullet0_X_Pos_in;
			bullet0_X_Motion <= bullet_X_Step;
        end

		  if (status != 4'd5 | bullet1_edge | ~(show_bullet[1]))
        begin
            bullet1_X_Pos <= bullet1_X_Init;
            bullet1_X_Motion <= 10'd0;
        end
        else
        begin
            bullet1_X_Pos <= bullet1_X_Pos_in;
			bullet1_X_Motion <= bullet_X_Step;
        end

		if (status != 4'd5 | bullet2_edge | ~(show_bullet[2]))
        begin
            bullet2_X_Pos <= bullet2_X_Init;
            bullet2_X_Motion <= 10'd0;
        end
        else
        begin
            bullet2_X_Pos <= bullet2_X_Pos_in;
			bullet2_X_Motion <= bullet_X_Step;
        end

		if (status != 4'd5 | bullet3_edge | ~(show_bullet[3]))
        begin
            bullet3_X_Pos <= bullet3_X_Init;
            bullet3_X_Motion <= 10'd0;
        end
        else
        begin
            bullet3_X_Pos <= bullet3_X_Pos_in;
			bullet3_X_Motion <= (~(bullet_X_Step) + 1'b1);
        end

		if (status != 4'd5 | bullet4_edge | ~(show_bullet[4]))
        begin
            bullet4_X_Pos <= bullet4_X_Init;
            bullet4_X_Motion <= 10'd0;
        end
        else
        begin
            bullet4_X_Pos <= bullet4_X_Pos_in;
			bullet4_X_Motion <= (~(bullet_X_Step) + 1'b1);
        end

		if (status != 4'd5 | bullet5_edge | ~(show_bullet[5]))
        begin
            bullet5_X_Pos <= bullet5_X_Init;
            bullet5_X_Motion <= 10'd0;
        end
        else
        begin
            bullet5_X_Pos <= bullet5_X_Pos_in;
			bullet5_X_Motion <= (~(bullet_X_Step) + 1'b1);
        end

		if (status != 4'd5 | bullet6_edge | ~(show_bullet[6]))
        begin
            bullet6_Y_Pos <= bullet6_Y_Init;
            bullet6_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet6_Y_Pos <= bullet6_Y_Pos_in;
			bullet6_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet7_edge | ~(show_bullet[7]))
        begin
            bullet7_Y_Pos <= bullet7_Y_Init;
            bullet7_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet7_Y_Pos <= bullet7_Y_Pos_in;
			bullet7_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet8_edge | ~(show_bullet[8]))
        begin
            bullet8_Y_Pos <= bullet8_Y_Init;
            bullet8_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet8_Y_Pos <= bullet8_Y_Pos_in;
			bullet8_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet9_edge | ~(show_bullet[9]))
        begin
            bullet9_X_Pos <= bullet9_X_Init;
            bullet9_X_Motion <= 10'd0;
			bullet9_Y_Pos <= bullet9_Y_Init;
            bullet9_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet9_X_Pos <= bullet9_X_Pos_in;
			bullet9_X_Motion <= bullet_X_Step;
			bullet9_Y_Pos <= bullet9_Y_Pos_in;
			bullet9_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet10_edge | ~(show_bullet[10]))
        begin
            bullet10_X_Pos <= bullet10_X_Init;
            bullet10_X_Motion <= 10'd0;
			bullet10_Y_Pos <= bullet10_Y_Init;
            bullet10_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet10_X_Pos <= bullet10_X_Pos_in;
			bullet10_X_Motion <= bullet_X_Step;
			bullet10_Y_Pos <= bullet10_Y_Pos_in;
			bullet10_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet11_edge | ~(show_bullet[11]))
        begin
            bullet11_X_Pos <= bullet11_X_Init;
            bullet11_X_Motion <= 10'd0;
			bullet11_Y_Pos <= bullet11_Y_Init;
            bullet11_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet11_X_Pos <= bullet11_X_Pos_in;
			bullet11_X_Motion <= bullet_X_Step;
			bullet11_Y_Pos <= bullet11_Y_Pos_in;
			bullet11_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet12_edge | ~(show_bullet[12]))
        begin
            bullet12_X_Pos <= bullet12_X_Init;
            bullet12_X_Motion <= 10'd0;
			bullet12_Y_Pos <= bullet12_Y_Init;
            bullet12_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet12_X_Pos <= bullet12_X_Pos_in;
			bullet12_X_Motion <= (~(bullet_X_Step) + 1'b1);
			bullet12_Y_Pos <= bullet12_Y_Pos_in;
			bullet12_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet13_edge | ~(show_bullet[13]))
        begin
            bullet13_X_Pos <= bullet13_X_Init;
            bullet13_X_Motion <= 10'd0;
			bullet13_Y_Pos <= bullet13_Y_Init;
            bullet13_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet13_X_Pos <= bullet13_X_Pos_in;
			bullet13_X_Motion <= (~(bullet_X_Step) + 1'b1);
			bullet13_Y_Pos <= bullet13_Y_Pos_in;
			bullet13_Y_Motion <= bullet_Y_Step;
        end

		if (status != 4'd5 | bullet14_edge | ~(show_bullet[14]))
        begin
            bullet14_X_Pos <= bullet14_X_Init;
            bullet14_X_Motion <= 10'd0;
			bullet14_Y_Pos <= bullet14_Y_Init;
            bullet14_Y_Motion <= 10'd0;
        end
        else
        begin
            bullet14_X_Pos <= bullet14_X_Pos_in;
			bullet14_X_Motion <= (~(bullet_X_Step) + 1'b1);
			bullet14_Y_Pos <= bullet14_Y_Pos_in;
			bullet14_Y_Motion <= bullet_Y_Step;
        end
    end

	always_comb
    begin
        // By default, keep motion and position unchanged
        bullet0_X_Pos_in = bullet0_X_Pos;
		bullet1_X_Pos_in = bullet1_X_Pos;
		bullet2_X_Pos_in = bullet2_X_Pos;
		bullet0_edge = 1'b0;
		bullet1_edge = 1'b0;
		bullet2_edge = 1'b0;

		bullet3_X_Pos_in = bullet3_X_Pos;
		bullet4_X_Pos_in = bullet4_X_Pos;
		bullet5_X_Pos_in = bullet5_X_Pos;
		bullet3_edge = 1'b0;
		bullet4_edge = 1'b0;
		bullet5_edge = 1'b0;

		bullet6_Y_Pos_in = bullet6_Y_Pos;
		bullet7_Y_Pos_in = bullet7_Y_Pos;
		bullet8_Y_Pos_in = bullet8_Y_Pos;
		bullet6_edge = 1'b0;
		bullet7_edge = 1'b0;
		bullet8_edge = 1'b0;

		bullet9_X_Pos_in = bullet9_X_Pos;
		bullet10_X_Pos_in = bullet10_X_Pos;
		bullet11_X_Pos_in = bullet11_X_Pos;
		bullet9_Y_Pos_in = bullet9_Y_Pos;
		bullet10_Y_Pos_in = bullet10_Y_Pos;
		bullet11_Y_Pos_in = bullet11_Y_Pos;
		bullet9_edge = 1'b0;
		bullet10_edge = 1'b0;
		bullet11_edge = 1'b0;

		bullet12_X_Pos_in = bullet12_X_Pos;
		bullet13_X_Pos_in = bullet13_X_Pos;
		bullet14_X_Pos_in = bullet14_X_Pos;
		bullet12_Y_Pos_in = bullet12_Y_Pos;
		bullet13_Y_Pos_in = bullet13_Y_Pos;
		bullet14_Y_Pos_in = bullet14_Y_Pos;
		bullet12_edge = 1'b0;
		bullet13_edge = 1'b0;
		bullet14_edge = 1'b0;

        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
			if( bullet0_X_Pos >= bullet0_X_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet0_edge = 1'b1;
			end
			bullet0_X_Pos_in = bullet0_X_Pos +bullet0_X_Motion;

			if( bullet1_X_Pos >= bullet1_X_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet1_edge = 1'b1;
			end
			bullet1_X_Pos_in = bullet1_X_Pos +bullet1_X_Motion;

			if( bullet2_X_Pos >= bullet2_X_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet2_edge = 1'b1;
			end
			bullet2_X_Pos_in = bullet2_X_Pos +bullet2_X_Motion;

			if( bullet3_X_Pos <= bullet3_X_Min )
			begin// heart is at the right edge, BOUNCE!
				bullet3_edge = 1'b1;
			end
			bullet3_X_Pos_in = bullet3_X_Pos +bullet3_X_Motion;

			if( bullet4_X_Pos <= bullet4_X_Min )
			begin// heart is at the right edge, BOUNCE!
				bullet4_edge = 1'b1;
			end
			bullet4_X_Pos_in = bullet4_X_Pos +bullet4_X_Motion;

			if( bullet5_X_Pos <= bullet5_X_Min )
			begin// heart is at the right edge, BOUNCE!
				bullet5_edge = 1'b1;
			end
			bullet5_X_Pos_in = bullet5_X_Pos +bullet5_X_Motion;

			if( bullet6_Y_Pos >= bullet6_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet6_edge = 1'b1;
			end
			bullet6_Y_Pos_in = bullet6_Y_Pos +bullet6_Y_Motion;

			if( bullet7_Y_Pos >= bullet7_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet7_edge = 1'b1;
			end
			bullet7_Y_Pos_in = bullet7_Y_Pos +bullet7_Y_Motion;

			if( bullet8_Y_Pos >= bullet8_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet8_edge = 1'b1;
			end
			bullet8_Y_Pos_in = bullet8_Y_Pos +bullet8_Y_Motion;

			if( bullet9_Y_Pos >= bullet9_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet9_edge = 1'b1;
			end
			bullet9_Y_Pos_in = bullet9_Y_Pos +bullet9_Y_Motion;
			bullet9_X_Pos_in = bullet9_X_Pos +bullet9_X_Motion;

			if( bullet10_Y_Pos >= bullet10_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet10_edge = 1'b1;
			end
			bullet10_Y_Pos_in = bullet10_Y_Pos +bullet10_Y_Motion;
			bullet10_X_Pos_in = bullet10_X_Pos +bullet10_X_Motion;

			if( bullet11_Y_Pos >= bullet11_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet11_edge = 1'b1;
			end
			bullet11_Y_Pos_in = bullet11_Y_Pos +bullet11_Y_Motion;
			bullet11_X_Pos_in = bullet11_X_Pos +bullet11_X_Motion;

			if( bullet12_Y_Pos >= bullet12_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet12_edge = 1'b1;
			end
			bullet12_Y_Pos_in = bullet12_Y_Pos +bullet12_Y_Motion;
			bullet12_X_Pos_in = bullet12_X_Pos +bullet12_X_Motion;

			if( bullet13_Y_Pos >= bullet13_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet13_edge = 1'b1;
			end
			bullet13_Y_Pos_in = bullet13_Y_Pos +bullet13_Y_Motion;
			bullet13_X_Pos_in = bullet13_X_Pos +bullet13_X_Motion;

			if( bullet14_Y_Pos >= bullet14_Y_Max )
			begin// heart is at the right edge, BOUNCE!
				bullet14_edge = 1'b1;
			end
			bullet14_Y_Pos_in = bullet14_Y_Pos +bullet14_Y_Motion;
			bullet14_X_Pos_in = bullet14_X_Pos +bullet14_X_Motion;
		end
	end
	int DistX0, DistY0;
	int DistX1, DistY1;
	int DistX2, DistY2;
	int DistX3, DistY3;
	int DistX4, DistY4;
	int DistX5, DistY5;
	int DistX6, DistY6;
	int DistX7, DistY7;
	int DistX8, DistY8;
	int DistX9, DistY9;
	int DistX10, DistY10;
	int DistX11, DistY11;
	int DistX12, DistY12;
	int DistX13, DistY13;
	int DistX14, DistY14;

    assign DistX0 = DrawX - bullet0_X_Pos;
    assign DistY0 = DrawY - bullet0_Y_Init;
	assign DistX1 = DrawX - bullet1_X_Pos;
    assign DistY1 = DrawY - bullet1_Y_Init;
	assign DistX2 = DrawX - bullet2_X_Pos;
    assign DistY2 = DrawY - bullet2_Y_Init;
	assign DistX3 = DrawX - bullet3_X_Pos;
    assign DistY3 = DrawY - bullet3_Y_Init;
	assign DistX4 = DrawX - bullet4_X_Pos;
    assign DistY4 = DrawY - bullet4_Y_Init;
	assign DistX5 = DrawX - bullet5_X_Pos;
    assign DistY5 = DrawY - bullet5_Y_Init;
	assign DistX6 = DrawX - bullet6_X_Init;
    assign DistY6 = DrawY - bullet6_Y_Pos;
	assign DistX7 = DrawX - bullet7_X_Init;
    assign DistY7 = DrawY - bullet7_Y_Pos;
	assign DistX8 = DrawX - bullet8_X_Init;
    assign DistY8 = DrawY - bullet8_Y_Pos;
	assign DistX9 = DrawX - bullet9_X_Pos;
    assign DistY9 = DrawY - bullet9_Y_Pos;
	assign DistX10 = DrawX - bullet10_X_Pos;
    assign DistY10 = DrawY - bullet10_Y_Pos;
	assign DistX11 = DrawX - bullet11_X_Pos;
    assign DistY11 = DrawY - bullet11_Y_Pos;
	assign DistX12 = DrawX - bullet12_X_Pos;
    assign DistY12 = DrawY - bullet12_Y_Pos;
	assign DistX13 = DrawX - bullet13_X_Pos;
    assign DistY13 = DrawY - bullet13_Y_Pos;
	assign DistX14 = DrawX - bullet14_X_Pos;
    assign DistY14 = DrawY - bullet14_Y_Pos;

    always_comb 
	 begin
		is_bullet0 = 1'b0;
		is_bullet1 = 1'b0;
		is_bullet2 = 1'b0;
		is_bullet3 = 1'b0;
		is_bullet4 = 1'b0;
		is_bullet5 = 1'b0;
		is_bullet6 = 1'b0;
		is_bullet7 = 1'b0;
		is_bullet8 = 1'b0;
		is_bullet9 = 1'b0;
		is_bullet10 = 1'b0;
		is_bullet11 = 1'b0;
		is_bullet12 = 1'b0;
		is_bullet13 = 1'b0;
		is_bullet14 = 1'b0;

		bullets_address = 20'b0;
        if ( DistX0 >= -6 && DistX0 < 6 && DistY0 >= -6 && DistY0 < 6 && status == 4'd5 && (bullet0_edge == 1'b0) && show_bullet[0]) begin
         	is_bullet0 = 1'b1;
			bullets_address = DistX0 + 6 + (DistY0 + 6) * 12;
		end
		else if ( DistX1 >= -6 && DistX1 < 6 && DistY1 >= -6 && DistY1 < 6 && status == 4'd5 && (bullet1_edge == 1'b0) && show_bullet[1]) begin
         	is_bullet1 = 1'b1;
			bullets_address = DistX1 + 6 + (DistY1 + 6) * 12;
		end
        else if ( DistX2 >= -6 && DistX2 < 6 && DistY2 >= -6 && DistY2 < 6 && status == 4'd5 && (bullet2_edge == 1'b0) && show_bullet[2]) begin
         	is_bullet2 = 1'b1;
			bullets_address = DistX2 + 6 + (DistY2 + 6) * 12;
		end
		else if ( DistX3 >= -6 && DistX3 < 6 && DistY3 >= -6 && DistY3 < 6 && status == 4'd5 && (bullet3_edge == 1'b0) && show_bullet[3]) begin
         	is_bullet3 = 1'b1;
			bullets_address = DistX3 + 6 + (DistY3 + 6) * 12;
		end
		else if ( DistX4 >= -6 && DistX4 < 6 && DistY4 >= -6 && DistY4 < 6 && status == 4'd5 && (bullet4_edge == 1'b0) && show_bullet[4]) begin
         	is_bullet4 = 1'b1;
			bullets_address = DistX4 + 6 + (DistY4 + 6) * 12;
		end
        else if ( DistX5 >= -6 && DistX5 < 6 && DistY5 >= -6 && DistY5 < 6 && status == 4'd5 && (bullet5_edge == 1'b0) && show_bullet[5]) begin
         	is_bullet5 = 1'b1;
			bullets_address = DistX5 + 6 + (DistY5 + 6) * 12;
		end
		else if ( DistX6 >= -6 && DistX6 < 6 && DistY6 >= -6 && DistY6 < 6 && status == 4'd5 && (bullet6_edge == 1'b0) && show_bullet[6]) begin
         	is_bullet6 = 1'b1;
			bullets_address = DistX6 + 6 + (DistY6 + 6) * 12;
		end
		else if ( DistX7 >= -6 && DistX7 < 6 && DistY7 >= -6 && DistY7 < 6 && status == 4'd5 && (bullet7_edge == 1'b0) && show_bullet[7]) begin
         	is_bullet7 = 1'b1;
			bullets_address = DistX7 + 6 + (DistY7 + 6) * 12;
		end
        else if ( DistX8 >= -6 && DistX8 < 6 && DistY8 >= -6 && DistY8 < 6 && status == 4'd5 && (bullet8_edge == 1'b0) && show_bullet[8]) begin
         	is_bullet8 = 1'b1;
			bullets_address = DistX8 + 6 + (DistY8 + 6) * 12;
		end
		else if ( DistX9 >= -6 && DistX9 < 6 && DistY9 >= -6 && DistY9 < 6 && status == 4'd5 && (bullet9_edge == 1'b0) && show_bullet[9]) begin
         	is_bullet9 = 1'b1;
			bullets_address = DistX9 + 6 + (DistY9 + 6) * 12;
		end
		else if ( DistX10 >= -6 && DistX10 < 6 && DistY10 >= -6 && DistY10 < 6 && status == 4'd5 && (bullet10_edge == 1'b0) && show_bullet[10]) begin
         	is_bullet10 = 1'b1;
			bullets_address = DistX10 + 6 + (DistY10 + 6) * 12;
		end
        else if ( DistX11 >= -6 && DistX11 < 6 && DistY11 >= -6 && DistY11 < 6 && status == 4'd5 && (bullet11_edge == 1'b0) && show_bullet[11]) begin
         	is_bullet11 = 1'b1;
			bullets_address = DistX11 + 6 + (DistY11 + 6) * 12;
		end
		else if ( DistX12 >= -6 && DistX12 < 6 && DistY12 >= -6 && DistY12 < 6 && status == 4'd5 && (bullet12_edge == 1'b0) && show_bullet[12]) begin
         	is_bullet12 = 1'b1;
			bullets_address = DistX12 + 6 + (DistY12 + 6) * 12;
		end
		else if ( DistX13 >= -6 && DistX13 < 6 && DistY13 >= -6 && DistY13 < 6 && status == 4'd5 && (bullet13_edge == 1'b0) && show_bullet[13]) begin
         	is_bullet13 = 1'b1;
			bullets_address = DistX13 + 6 + (DistY13 + 6) * 12;
		end
        else if ( DistX14 >= -6 && DistX14 < 6 && DistY14 >= -6 && DistY14 < 6 && status == 4'd5 && (bullet14_edge == 1'b0) && show_bullet[14]) begin
         	is_bullet14 = 1'b1;
			bullets_address = DistX14 + 6 + (DistY14 + 6) * 12;
		end
    end
	 
	 int deltax0, deltay0;
	 int deltax1, deltay1;
	 int deltax2, deltay2;
	 int deltax3, deltay3;
	 int deltax4, deltay4;
	 int deltax5, deltay5;
	 int deltax6, deltay6;
	 int deltax7, deltay7;
	 int deltax8, deltay8;
	 int deltax9, deltay9;
	 int deltax10, deltay10;
	 int deltax11, deltay11;
	 int deltax12, deltay12;
	 int deltax13, deltay13;
	 int deltax14, deltay14;
	 int size;
	 
	 assign size = 4'd13;
	 assign deltax0 = bullet0_X_Pos - PosXH;
	 assign deltay0 = bullet0_Y_Init - PosYH;
	 assign deltax1 = bullet1_X_Pos - PosXH;
	 assign deltay1 = bullet1_Y_Init - PosYH;
	 assign deltax2 = bullet2_X_Pos - PosXH;
	 assign deltay2 = bullet2_Y_Init - PosYH;

	 assign deltax3 = bullet3_X_Pos - PosXH;
	 assign deltay3 = bullet3_Y_Init - PosYH;
	 assign deltax4 = bullet4_X_Pos - PosXH;
	 assign deltay4 = bullet4_Y_Init - PosYH;
	 assign deltax5 = bullet5_X_Pos - PosXH;
	 assign deltay5 = bullet5_Y_Init - PosYH;

	 assign deltax6 = bullet6_X_Init - PosXH;
	 assign deltay6 = bullet6_Y_Pos - PosYH;
	 assign deltax7 = bullet7_X_Init - PosXH;
	 assign deltay7 = bullet7_Y_Pos - PosYH;
	 assign deltax8 = bullet8_X_Init - PosXH;
	 assign deltay8 = bullet8_Y_Pos - PosYH;

	 assign deltax9 = bullet9_X_Pos - PosXH;
	 assign deltay9 = bullet9_Y_Pos - PosYH;
	 assign deltax10 = bullet10_X_Pos - PosXH;
	 assign deltay10 = bullet10_Y_Pos - PosYH;
	 assign deltax11 = bullet11_X_Pos - PosXH;
	 assign deltay11 = bullet11_Y_Pos - PosYH;	

	 assign deltax12 = bullet12_X_Pos - PosXH;
	 assign deltay12 = bullet12_Y_Pos - PosYH;
	 assign deltax13 = bullet13_X_Pos - PosXH;
	 assign deltay13 = bullet13_Y_Pos - PosYH;
	 assign deltax14 = bullet14_X_Pos - PosXH;
	 assign deltay14 = bullet14_Y_Pos - PosYH;
	 
	 always_comb 
	 begin
				if ((deltax0*deltax0 + deltay0*deltay0) <= (size*size))
				begin
					is_collide0 = 1'b1;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax1*deltax1 + deltay1*deltay1) <= (size*size))
				begin
					is_collide0 = 1'b0;
					is_collide1 = 1'b1;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax2*deltax2 + deltay2*deltay2) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b1;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax3*deltax3 + deltay3*deltay3) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b1;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax4*deltax4 + deltay4*deltay4) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b1;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax5*deltax5 + deltay5*deltay5) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b1;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax6*deltax6 + deltay6*deltay6) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b1;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax7*deltax7 + deltay7*deltay7) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b1;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax8*deltax8 + deltay8*deltay8) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b1;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax9*deltax9 + deltay9*deltay9) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b1;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax10*deltax10 + deltay10*deltay10) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b1;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax11*deltax11 + deltay11*deltay11) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b1;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax12*deltax12 + deltay12*deltay12) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b1;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
				else if ((deltax13*deltax13 + deltay13*deltay13) <= (size*size))
				begin
					
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b1;
					is_collide14 = 1'b0;
				end
				else if ((deltax14*deltax14 + deltay14*deltay14) <= (size*size))
				begin
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b1;
				end
				else
				begin
					is_collide0 = 1'b0;
					is_collide1 = 1'b0;
					is_collide2 = 1'b0;
					is_collide3 = 1'b0;
					is_collide4 = 1'b0;
					is_collide5 = 1'b0;
					is_collide6 = 1'b0;
					is_collide7 = 1'b0;
					is_collide8 = 1'b0;
					is_collide9 = 1'b0;
					is_collide10 = 1'b0;
					is_collide11 = 1'b0;
					is_collide12 = 1'b0;
					is_collide13 = 1'b0;
					is_collide14 = 1'b0;
				end
			end
endmodule

module  bullet1_rom
(
		input [19:0] bullet1_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:143];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hffffff;

assign color_out = col[mem[bullet1_address]];

initial
begin
	 $readmemh("sprite_bytes/bullet1.txt", mem);
end

endmodule 

module  bullet2_rom
(
		input [19:0] bullet2_address,
		output logic [23:0] color_out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:143];

logic [23:0] col [8:0];
assign col[0] = 24'h000000;
assign col[1] = 24'hffffff;

assign color_out = col[mem[bullet2_address]];

initial
begin
	 $readmemh("sprite_bytes/bullet2.txt", mem);
end

endmodule 

module  rand_rom
(
		input CLK,
		input [9:0] address,
		output logic [3:0] bullet_num
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:1023];

	assign bullet_num = mem[address];

//	always_ff @ (negedge CLK)
//    begin
//		bullet_num <= 4'd15;
//	end
initial
begin
	 $readmemh("random.txt", mem);
end

endmodule 