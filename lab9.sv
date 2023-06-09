//-------------------------------------------------------------------------
//      lab9.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//      Zuofu Cheng                                                      --
//      4/10/2023                                                        --
//      Spring 2023 Distribution                                         --
//                                                                       --
//      For use with ECE 385 Lab 9 (DE2-115)                             --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab9( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,HEX2, HEX3,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
											
				 inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
            
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock
											
				 input 					AUD_ADCDAT,
             input 					AUD_DACLRCK,
             input 					AUD_ADCLRCK,
             input 					AUD_BCLK,
             output logic        I2C_SCLK, 
				 output logic			I2C_SDAT, 
				 output logic			AUD_XCK, 
				 output logic			AUD_DACDAT
				 
//				 inout  wire  [15:0] SRAM_DQ,       // external_interface.DQ
//				 output logic [19:0] SRAM_ADDR,     //                   .ADDR
//				 output logic        SRAM_LB_N,     //                   .LB_N
//				 output logic        SRAM_UB_N,     //                   .UB_N
//				 output logic        SRAM_CE_N,     //                   .CE_N
//				 output logic        SRAM_OE_N,     //                   .OE_N
//				 output logic        SRAM_WE_N     //                   .WE_N
				);
    
	 logic [3:0] HP;
	 logic [1:0] Difficulty;
	 logic time_up;
    logic Reset_h, Clk;
	 logic arrived_door;
	 logic arrived_monster;
	 logic is_press;
	 logic [3:0] status;
	 logic [7:0] keycode;
	 logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 
	 logic INIT, data_over, INIT_FINISH, adc_full;
	 logic [16:0] Add;
	 logic [16:0] music_content, music_content1, music_content2, music_content3;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
   
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
	lab9_soc u0 (
					 .clk_clk                           (Clk),      //clk.clk
					 .reset_reset_n(1'b1),    						// Never reset NIOS
					 .sdram_wire_addr(DRAM_ADDR), 
					 .sdram_wire_ba(DRAM_BA),   
					 .sdram_wire_cas_n(DRAM_CAS_N),
					 .sdram_wire_cke(DRAM_CKE),  
					 .sdram_wire_cs_n(DRAM_CS_N), 
					 .sdram_wire_dq(DRAM_DQ),   
					 .sdram_wire_dqm(DRAM_DQM),  
					 .sdram_wire_ras_n(DRAM_RAS_N),
					 .sdram_wire_we_n(DRAM_WE_N), 
					 .sdram_clk_clk(DRAM_CLK),
					 
					 .keycode_export(keycode),  
                .otg_hpi_address_export(hpi_addr),
                .otg_hpi_data_in_port(hpi_data_in),
                .otg_hpi_data_out_port(hpi_data_out),
                .otg_hpi_cs_export(hpi_cs),
                .otg_hpi_r_export(hpi_r),
                .otg_hpi_w_export(hpi_w),
                .otg_hpi_reset_export(hpi_reset),
					 
					//VGA
					.vga_port_red (VGA_R),
					.vga_port_green (VGA_G),
					.vga_port_blue (VGA_B),
					.vga_port_hs (VGA_HS),
					.vga_port_vs (VGA_VS),
					.vga_port_pixel_clk (VGA_CLK),
					.vga_port_blank (VGA_BLANK_N),
					.vga_port_sync (VGA_SYNC_N),
					.vga_port_status (status),
					.vga_port_keycode(keycode),
					.vga_port_arrived_door(arrived_door),
					.vga_port_arrived_monster(arrived_monster),
					.vga_port_hp(HP),
					.vga_port_time_up(time_up),
					.vga_port_difficulty(Difficulty)
    );
	 
	     // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );

	 audio audio(.*, .Reset(Reset_h));
	 music1 music1(.*, .music_content(music_content1));
	 music2 music2(.*, .music_content(music_content2));
	 music3 music3(.*, .music_content(music_content3));
	 
	 always_comb
	 begin
			case (status)
			4'd1:
			begin
				music_content = music_content1;
			end
			4'd2:
			begin
				music_content = music_content1;
			end
			4'd3:
			begin
				music_content = music_content3;
			end
			4'd4:
			begin
				music_content = music_content2;
			end
			4'd5:
			begin
				music_content = music_content2;
			end
			4'd6:
			begin
				music_content = music_content1;
			end
			4'd7:
			begin
				music_content = music_content1;
			end
			default: music_content <= 17'b0;
			endcase
	 end
	 audio_interface audio_interface(.LDATA(music_content), 
											 .RDATA(music_content),
											 .CLK(Clk),
											 .Reset(Reset_h), 
											 .INIT(INIT),
											 .INIT_FINISH(INIT_FINISH),
											 .adc_full(adc_full),
											 .data_over(data_over),
											 .AUD_MCLK(AUD_XCK),
											 .AUD_BCLK(AUD_BCLK),     
											 .AUD_ADCDAT(AUD_ADCDAT),
											 .AUD_DACDAT(AUD_DACDAT),
											 .AUD_DACLRCK(AUD_DACLRCK),
											 .AUD_ADCLRCK(AUD_ADCLRCK),
											 .I2C_SDAT(I2C_SDAT),
											 .I2C_SCLK(I2C_SCLK),
											 .ADCDATA(ADCDATA));
	 
	 state states(.Clk(Clk), .Reset(Reset_h), .keycode(keycode), .status(status), .arrived_door(arrived_door), .arrived_monster(arrived_monster), .HP(HP), .time_up(time_up));
	 
	 always_ff @ (posedge Clk)
    begin
		if (status != 4'd5)
        begin
            Difficulty <= 2'd1;
        end
		else
		begin
			case (keycode)
			7'd30:
				Difficulty <= 2'd1;
			7'd31:
				Difficulty <= 2'd2;
			7'd32:
				Difficulty <= 2'd3;
			default:;
			endcase
		end
	 end
	 
    HexDriver hex_inst_0 (HP, HEX0);
	 assign HEX1 = 7'hFF;
	 assign HEX2 = 7'h0C;
	 assign HEX3 = 7'h09;
	 
endmodule
