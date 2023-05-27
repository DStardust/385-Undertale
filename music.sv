//-------------------------------------------------------------------------
//      music.sv                                                         --
//      Created by Peiyuan Liu                                           --
//      Cited by Yang Dai & Lumeng Xu (2023.5.28)                        --
//      Spring 2023                                                      --
//                                                                       --
//      This mopdule helps to control the music of the game              --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

module music (input logic  Clk,
				  input logic  [16:0]Add,
				  output logic [16:0]music_content);
				  
	logic [16:0] music_memory [0:43113]; //this is the line number of the music.txt(or we can just pick a cut of the whole music length), which is corresponding to the max value of Add.
	initial 
	begin 
		$readmemh("music1.txt",music_memory); //the name of the music .txt
	end
	
	always_ff @ (posedge Clk)
		begin
			music_content <= music_memory[Add];
		end
endmodule
