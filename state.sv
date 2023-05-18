module state (input  logic Clk, Reset, 
				  input [7:0] keycode,
                output logic [3:0] status);

    enum logic [4:0] {title, intro}   curr_state, next_state; 

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
            intro : if (keycode==8'h20)
							next_state = title;
							  
        endcase
   
		  // Assign outputs based on ‘state’
		  // For "Add" states, set Add logic as high.
		  // For "Shift" states, set Shift_En logic as high.
		  // For "Sub" states, set Sub logic as high.
		  // For "ClearA_LoadB" states, set Reset_A and Ld_B logic as high.
        case (curr_state) 
	   	   title: 
	         begin
					 status = 4'd1;
		      end
				intro:
				begin
					 status = 4'd2;
		      end
	   	   default:
		      begin
					 status = 4'd0;
		      end
        endcase
    end

endmodule
