module state (input  logic Clk, Reset, 
				  input [7:0] keycode,
				  input arrived_door,
				  input arrived_monster,
				  input [3:0] HP,
				  input time_up,
                output logic [3:0] status);

    enum logic [4:0] {title, intro, map1, map2, battle, win, lose}   curr_state, next_state; 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= title;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
        
		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

            title : if (keycode==8'h28)
							next_state = intro;
            intro : if (keycode==8'h1d)
							next_state = map1;
				map1 : if (keycode==8'h28 && arrived_door == 1'b1)
							next_state = map2;
				map2 : if (arrived_monster == 1'b1)
							next_state = battle;
				battle : if (HP == 4'b0)
							next_state = lose;
							else if (time_up)
							next_state = win;
				win : if (keycode==8'h1d)
							next_state = title;
				lose : if (keycode==8'h1d)
							next_state = map2;
							  
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
	   	   title: 
	         begin
					 status = 4'd1;
		      end
				intro:
				begin
					 status = 4'd2;
		      end
				map1:
				begin
					 status = 4'd3;
		      end
				map2:
				begin
					 status = 4'd4;
		      end
				battle:
				begin
					 status = 4'd5;
		      end
				win:
				begin
					 status = 4'd6;
		      end
				lose:
				begin
					 status = 4'd7;
		      end
	   	   default:
		      begin
					 status = 4'd0;
		      end
        endcase
    end

endmodule
