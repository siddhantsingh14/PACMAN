//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);

logic [1:0] level;
logic [155:0] horiz_walls, vert_walls;  //walls of the map
logic Starting_screen;
logic dots_status;
logic [143:0] dotStartMap;
logic [143:0] currDotMap;
logic reset_game;
logic [3:0] PAC_contact;
logic PAC_status;
logic ResetAll;
logic [9:0] ghost_O_X, ghost_O_Y;
logic [9:0] ghost_B_X, ghost_B_Y;
logic [9:0] ghost_R_X, ghost_R_Y;
logic [9:0] ghost_P_X, ghost_P_Y;

logic Clk_PAC_en;
logic Clk_ghost_en;
logic [17:0] PAC_gametime;
logic [17:0] ghost_timer;

logic [1:0] pac_direction;
logic [9:0] pac_size_ret;
logic waiting;
logic [15:0] randomness;
assign randomness = 16'h4369;
// assign waiting = 1'b0;

logic [4:0] ghost_O_X_initial, ghost_O_Y_initial;
assign ghost_O_X_initial = 5'h06;   //starting position of the ghosts, they all start from the same point
assign ghost_O_Y_initial = 5'h06;
logic [4:0] ghost_R_X_initial, ghost_R_Y_initial;
// assign ghost_R_X_initial = 5'h00;
// assign ghost_R_Y_initial = 5'h00;
logic [4:0] ghost_B_X_initial, ghost_B_Y_initial;
// assign ghost_B_X_initial = 5'h06;
// assign ghost_B_Y_initial = 5'h06;
logic [4:0] ghost_P_X_initial, ghost_P_Y_initial;
// assign ghost_P_X_initial = 5'h06;
// assign ghost_P_Y_initial = 5'h06;


logic Clk;
assign Clk = MAX10_CLK1_50;


walls_init walls_init_module(.*);

getDotStarts get_dots_module(.dotMap(dotStartMap)); //setting the starting map of the dots to the variable

dots_orientation all_dots_module(.*, .Reset(reset_game), .dots_original_orientation(dotStartMap), .pacX(ballxsig), .pacY(ballysig), .level_status(dots_status), .display(currDotMap) );
	 

assign reset_game = ResetAll | Reset_h;

assign PAC_status = (PAC_contact[0] | PAC_contact[1] | PAC_contact[2] | PAC_contact[3]);    //if PAC makes contact with any ghost, then the pac status goes high which means the pac is dead and the game must be reset



logic Reset_h, vssig, blank, sync, VGA_Clk;

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [15:0] keycode;
    assign ballsizesig = 16;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode)
		
	 );

pac_control pac_control_module(.*, .Reset(Reset_h), .keycode(keycode));


always_ff @ (posedge Clk or posedge Reset_h )
begin 
    if (Reset_h) 
    begin
        Clk_PAC_en <= 1'b0;
        Clk_ghost_en <= 1'b0;
	    PAC_gametime <= 18'h00000;
        ghost_timer <= 18'h00000;
	end
    else
	begin 
		PAC_gametime <= PAC_gametime + 1;
		ghost_timer <= ghost_timer + 1;
		if(PAC_gametime >= 200000)
		begin
            PAC_gametime <= 18'h00000;
            Clk_PAC_en <= ~Clk_PAC_en;
		end
		// if(ghost_timer>=1000 && waiting == 1'b0)
		// begin
		// 	ghost_R_X_initial <= 5'h06;
		// 	ghost_R_Y_initial <= 5'h06;
		// 	waiting<=1'b1;
		// end

		if(ghost_timer >= 262000)
		begin
			ghost_timer <= 18'h00000;
			Clk_ghost_en <= ~Clk_ghost_en;
		end
		
	end
		
end

always_comb
begin:Assigning_next_level_ghost_map
	if(level==2'b10)
	begin
		ghost_R_X_initial = 5'h01;
		ghost_R_Y_initial = 5'h00;
		ghost_B_X_initial = 5'h0c;
		ghost_B_Y_initial = 5'h00;
		ghost_P_X_initial = 5'h07;
		ghost_P_Y_initial = 5'h00;
	end
	else begin
		ghost_R_X_initial = 5'h06;
		ghost_R_Y_initial = 5'h06;
		ghost_B_X_initial = 5'h06;
		ghost_B_Y_initial = 5'h06;
		ghost_P_X_initial = 5'h06;
		ghost_P_Y_initial = 5'h06;
	end
end

ghost_motion orange_ghost(.*, .Reset(reset_game), .frame_Clk(Clk_ghost_en), .ghostX(ghost_O_X), .ghostY(ghost_O_Y), .pacX(ballxsig), .pacY(ballysig), .x_start(ghost_O_X_initial), .y_start(ghost_O_Y_initial), .hitPacman(PAC_contact[0]));	 
ghost_motion blue_ghost(.*, .Reset(reset_game), .frame_Clk(Clk_ghost_en), .ghostX(ghost_B_X), .ghostY(ghost_B_Y), .pacX(ballxsig), .pacY(ballysig), .x_start(ghost_B_X_initial), .y_start(ghost_B_Y_initial), .hitPacman(PAC_contact[1]));
ghost_motion red_ghost(.*, .Reset(reset_game), .frame_Clk(Clk_ghost_en), .ghostX(ghost_R_X), .ghostY(ghost_R_Y), .pacX(ballxsig), .pacY(ballysig), .x_start(ghost_R_X_initial), .y_start(ghost_R_Y_initial), .hitPacman(PAC_contact[2]));
ghost_motion pink_ghost (.*, .Reset(reset_game), .frame_Clk(Clk_ghost_en), .ghostX(ghost_P_X), .ghostY(ghost_P_Y), .pacX(ballxsig), .pacY(ballysig), .x_start(ghost_P_X_initial), .y_start(ghost_P_Y_initial), .hitPacman(PAC_contact[3]));

pac_motion pac_instance(.*, .Reset(reset_game), .frame_Clk(Clk_PAC_en), .pacX(ballxsig), .pacY(ballysig), .pacS(pac_size_ret), .Direction(pac_direction));

//instantiate a vga_controller, ball, and color_mapper here with the ports.

vga_controller vga_inst (.Clk(MAX10_CLK1_50), 
						 .Reset(Reset_h),
						 .hs(VGA_HS),        
						 .vs(VGA_VS),        
						 .pixel_clk(VGA_Clk), 
					    .blank(blank),    
						 .sync(sync),			             
						 .DrawX(drawxsig),     
				       .DrawY(drawysig)	);

color_mapper color_instance(.*, .DrawX(drawxsig), .DrawY(drawysig), .BallX(ballxsig), .BallY(ballysig), .Ball_size(ballsizesig), .Red(Red), .Green(Green), .Blue(Blue), .Direction(pac_direction), .oghostx(ghost_O_X), .oghosty(ghost_O_Y), .bghostx(ghost_B_X), .bghosty(ghost_B_Y), .rghostx(ghost_R_X), .rghosty(ghost_R_Y), .pghostx(ghost_P_X), .pghosty(ghost_P_Y));





endmodule
