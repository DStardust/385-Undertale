//-------------------------------------------------------------------------
//      audio.sv                                                         --
//      Created by Yihong Jin                                            --
//      Cited by Yang Dai & Lumeng Xu (2023.5.28)                        --
//      Spring 2023                                                      --
//                                                                       --
//      This mopdule helps to control the sound play of the board        --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module audio ( input logic Clk, Reset, 
				  input logic INIT_FINISH,
				  input logic data_over,
				  output logic INIT,
				  output [16:0] Add
);

logic [15:0] counter;
logic [15:0] inner_counter;
enum logic {WAIT,RUN} current_state, next_state;
logic [16:0] inner_Add;


always_ff @ (posedge Clk)
	begin
		if (Reset)
		begin
			current_state <= WAIT;
			counter <= 16'd0;
			Add <= 17'd0;
		end
		else
		begin
			current_state <= next_state;
			counter <= inner_counter;
			Add <= inner_Add;
		end
	end
		
always_comb
	begin
		unique case(current_state)
			WAIT:
				begin
					if (INIT_FINISH == 4'd01)
						begin
							next_state = RUN;
							INIT = 4'd01;
						end
					else
						begin
							next_state = WAIT;
							
						end
					INIT = 4'd01;	
					inner_counter = 16'd0;
					inner_Add = 17'd0;
				end

				
			
			RUN:
			begin 
				next_state = RUN;
				INIT = 4'd01;
				
				if (counter<16'd126 ) //music frequency, to be polished
					inner_counter = counter+16'd1;
				else
					inner_counter = 16'd0;
					
				if (counter==16'd125  && Add<=17'd43113 && data_over!=0)//music frequency, to be polished
					inner_Add = Add+17'd1;
				else if (Add < 17'd43113)
					inner_Add = Add;
				else
					inner_Add = 17'd0;
			end	
		
		default: ;
		endcase	
	end

endmodule

