//-------------------------------------------------------------------------
//      music.sv                                                         --
//      Created by Peiyuan Liu                                           --
//      Cited by Yang Dai & Lumeng Xu (2023.5.28)                        --
//      Spring 2023                                                      --
//                                                                       --
//      This mopdule helps to control the music of the game              --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

module music1 (input logic  Clk,
				  input logic  [16:0]Add,
				  input logic [3:0] status,
				  output logic [16:0]music_content);
				  
	logic [16:0] music_memory [0:65535]; //this is the line number of the music.txt(or we can just pick a cut of the whole music length), which is corresponding to the max value of Add.
//	logic [16:0] music_memory2 [0:32767];
//	logic [16:0] music_memory3 [0:32767];
	initial 
	begin 
		$readmemh("music1.txt",music_memory); //the name of the music .txt
	end
//	initial 
//	begin 
//		$readmemh("music2.txt",music_memory2); //the name of the music .txt
//	end
//	initial 
//	begin 
//		$readmemh("music3.txt",music_memory3); //the name of the music .txt
//	end
	
	always_ff @ (posedge Clk)
		begin
//			case (status)
//			4'd1:
//			begin
//				music_content <= music_memory1[Add];
//			end
//			4'd2:
//			begin
//				music_content <= music_memory1[Add];
//			end
//			4'd3:
//			begin
//				music_content <= music_memory3[Add];
//			end
//			4'd4:
//			begin
//				music_content <= music_memory2[Add];
//			end
//			4'd5:
//			begin
				music_content <= music_memory[Add];
//			end
//			default: music_content <= 17'b0;
//			endcase
		end
endmodule

module music2 (input logic  Clk,
				  input logic  [16:0]Add,
				  input logic [3:0] status,
				  output logic [16:0]music_content);
				  
	logic [16:0] music_memory [0:65535]; //this is the line number of the music.txt(or we can just pick a cut of the whole music length), which is corresponding to the max value of Add.
//	logic [16:0] music_memory2 [0:32767];
//	logic [16:0] music_memory3 [0:32767];
//	initial 
//	begin 
//		$readmemh("music1.txt",music_memory); //the name of the music .txt
//	end
	initial 
	begin 
		$readmemh("music2.txt",music_memory); //the name of the music .txt
	end
//	initial 
//	begin 
//		$readmemh("music3.txt",music_memory3); //the name of the music .txt
//	end
	
	always_ff @ (posedge Clk)
		begin
//			case (status)
//			4'd1:
//			begin
//				music_content <= music_memory1[Add];
//			end
//			4'd2:
//			begin
//				music_content <= music_memory1[Add];
//			end
//			4'd3:
//			begin
//				music_content <= music_memory3[Add];
//			end
//			4'd4:
//			begin
//				music_content <= music_memory2[Add];
//			end
//			4'd5:
//			begin
				music_content <= music_memory[Add];
//			end
//			default: music_content <= 17'b0;
//			endcase
		end
endmodule

module music3 (input logic  Clk,
				  input logic  [16:0]Add,
				  input logic [3:0] status,
				  output logic [16:0]music_content);
				  
	logic [16:0] music_memory [0:65535]; //this is the line number of the music.txt(or we can just pick a cut of the whole music length), which is corresponding to the max value of Add.
//	logic [16:0] music_memory2 [0:32767];
//	logic [16:0] music_memory3 [0:32767];
//	initial 
//	begin 
//		$readmemh("music1.txt",music_memory); //the name of the music .txt
//	end
//	initial 
//	begin 
//		$readmemh("music2.txt",music_memory2); //the name of the music .txt
//	end
	initial 
	begin 
		$readmemh("music3.txt",music_memory); //the name of the music .txt
	end
	
	always_ff @ (posedge Clk)
		begin
//			case (status)
//			4'd1:
//			begin
//				music_content <= music_memory1[Add];
//			end
//			4'd2:
//			begin
//				music_content <= music_memory1[Add];
//			end
//			4'd3:
//			begin
//				music_content <= music_memory3[Add];
//			end
//			4'd4:
//			begin
//				music_content <= music_memory2[Add];
//			end
//			4'd5:
//			begin
				music_content <= music_memory[Add];
//			end
//			default: music_content <= 17'b0;
//			endcase
		end
endmodule
