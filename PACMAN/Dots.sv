module getDotStarts (output [143:0] dotMap);

	assign dotMap = {
		36'hfffa65fff,
		36'hfff1f8f9f,
		36'h1981f8fff,
		36'hfffffffff
	};  
    

endmodule


module Dot_control (input  Clk,
					input  Reset,
					input  ResetVal,
					input  intersection,
					input  [9:0] pacX, pacY,
					input  [4:0] dotX, dotY,
					output display
               );
	enum logic [1:0] { GONE, PRESENT } state, next_state;

	always_ff @ (posedge Clk, posedge Reset)
    begin
		if (Reset)
        begin
			state <= PRESENT;
		end
        else 
        begin
			state <= next_state;
		end
	end
	
	always_comb 
    begin: Assigning_DotState
		next_state = state;
		case (state)
		PRESENT : begin
			if(dotY != pacY[9:5] || dotX != pacX[9:5] || ~intersection)
                next_state = state;
			else 
				next_state = GONE;
		end
		GONE : begin
			next_state = state;
		end		
		endcase
		
	end
	
	always_comb 
    begin: Output_dot
		display = ResetVal;
		case (state)
			GONE: begin
				display = 1'b0;
			end
			PRESENT : begin
				display = ResetVal;
			end
		endcase
	end

endmodule


module dots_horizontal_orientation (input  Clk,
									input	 Reset,
									input  intersection,
									input  [11:0] dot_orientation,
									input  [9:0] pacX, pacY,
									input  [4:0] dotY,
									output level_status,
									output [11:0] display
               						);
	
	always_comb 
    begin: Dot_check
		if(display)
			level_status = 1'b1;    //dots are still present so the level is not over yet
		else 
			level_status = 1'b0;
	end
	
	Dot_control display_dot11 (.*, .ResetVal(dot_orientation[11]), .dotX(5'h01), .display(display[11]));
	Dot_control display_dot10 (.*, .ResetVal(dot_orientation[10]), .dotX(5'h02), .display(display[10]));
	Dot_control display_dot9 (.*, .ResetVal(dot_orientation[9]), .dotX(5'h03), .display(display[9]));
	Dot_control display_dot8 (.*, .ResetVal(dot_orientation[8]), .dotX(5'h04), .display(display[8]));
	Dot_control display_dot7 (.*, .ResetVal(dot_orientation[7]), .dotX(5'h05), .display(display[7]));
	Dot_control display_dot6 (.*, .ResetVal(dot_orientation[6]), .dotX(5'h06), .display(display[6]));
	Dot_control display_dot5 (.*, .ResetVal(dot_orientation[5]), .dotX(5'h07), .display(display[5]));
	Dot_control display_dot4 (.*, .ResetVal(dot_orientation[4]), .dotX(5'h08), .display(display[4]));
	Dot_control display_dot3 (.*, .ResetVal(dot_orientation[3]), .dotX(5'h09), .display(display[3]));
	Dot_control display_dot2 (.*, .ResetVal(dot_orientation[2]), .dotX(5'h0a), .display(display[2]));
	Dot_control display_dot1 (.*, .ResetVal(dot_orientation[1]), .dotX(5'h0b), .display(display[1]));
	Dot_control display_dot0 (.*, .ResetVal(dot_orientation[0]), .dotX(5'h0c), .display(display[0]));	

endmodule


module dots_orientation(input  Clk,
					    input  Reset,
					    input  [143:0] dots_original_orientation,
					    input  [9:0] pacX, pacY,
					    output level_status,
					    output [143:0] display
                    );
    
	 
	 
	logic intersection;
	assign intersection =~(pacX[0] | pacX[1] | pacX[2] | pacX[3] | pacX[4] | pacY[0] | pacY[1] | pacY[2] | pacY[3] | pacY[4]);   //checking if the current pacman position results in an intersection
    // assign intersection = ~intersection;
	
	logic display_dot_row[11:0];
	always_comb 
    begin: Dot_placement_check
		if(display_dot_row)
			level_status = 1'b1;
		else 
			level_status = 1'b0;
	end
	
	
	dots_horizontal_orientation display_dots11(.*, .dot_orientation(dots_original_orientation[143:132]), .dotY(5'h01), .display(display[143:132]), .level_status(display_dot_row[11]));
	dots_horizontal_orientation display_dots10(.*, .dot_orientation(dots_original_orientation[131:120]), .dotY(5'h02), .display(display[131:120]), .level_status(display_dot_row[10]));
	dots_horizontal_orientation display_dots9(.*, .dot_orientation(dots_original_orientation[119:108]), .dotY(5'h03), .display(display[119:108]), .level_status(display_dot_row[9]));
	dots_horizontal_orientation display_dots8(.*, .dot_orientation(dots_original_orientation[107:96]),  .dotY(5'h04), .display(display[107:96] ), .level_status(display_dot_row[8]));
	dots_horizontal_orientation display_dots7(.*, .dot_orientation(dots_original_orientation[95:84]),   .dotY(5'h05), .display(display[95:84]  ), .level_status(display_dot_row[7]));
	dots_horizontal_orientation display_dots6(.*, .dot_orientation(dots_original_orientation[83:72]),   .dotY(5'h06), .display(display[83:72]  ), .level_status(display_dot_row[6]));
	dots_horizontal_orientation display_dots5(.*, .dot_orientation(dots_original_orientation[71:60]),   .dotY(5'h07), .display(display[71:60]  ), .level_status(display_dot_row[5]));
	dots_horizontal_orientation display_dots4(.*, .dot_orientation(dots_original_orientation[59:48]),   .dotY(5'h08), .display(display[59:48]  ), .level_status(display_dot_row[4]));
	dots_horizontal_orientation display_dots3(.*, .dot_orientation(dots_original_orientation[47:36]),   .dotY(5'h09), .display(display[47:36]  ), .level_status(display_dot_row[3]));
	dots_horizontal_orientation display_dots2(.*, .dot_orientation(dots_original_orientation[35:24]),   .dotY(5'h0a), .display(display[35:24]  ), .level_status(display_dot_row[2]));
	dots_horizontal_orientation display_dots1(.*, .dot_orientation(dots_original_orientation[23:12]),   .dotY(5'h0b), .display(display[23:12]  ), .level_status(display_dot_row[1]));
	dots_horizontal_orientation display_dots0(.*, .dot_orientation(dots_original_orientation[11:0] ),   .dotY(5'h0c), .display(display[11:0]   ), .level_status(display_dot_row[0]));
	
	


endmodule