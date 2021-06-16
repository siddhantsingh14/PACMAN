module pac_control (input  Clk,
					input  Reset,
					input  [15:0]keycode,
					input  PAC_status,
					input  dots_status,
					output  [1:0] level,
					output Starting_screen,
					output ResetAll
               );
    
	 
	enum logic [2:0] { LEVEL1, LEVEL2, LEVEL1DONE, LEVEL2DONE, NEWGAME } state, next_state;
	logic reset_state;
	
	
	always_ff @ (posedge Clk or posedge Reset) 
    begin: Game_status
		if (Reset) begin    //reset the game
			state <= NEWGAME;
			ResetAll <= 1;
		end else begin
			state <= next_state;
			ResetAll <= reset_state;
		end
	end

    logic [15:0] codeEnter;
	assign codeEnter = 16'h0028;   //scan code for enter for the keyboard
	
	always_comb 
    begin:Game_control
		next_state = state;
		reset_state = ResetAll;
		
		if(PAC_status)  //if high, then the pac is dead
		begin
			next_state = NEWGAME;
			reset_state = 1;
		end
		else begin
			case (state)
			NEWGAME : begin
				reset_state = 0;
				if(keycode == codeEnter)
					next_state = LEVEL1;    //start the game if enter is pressed
				else 
					next_state = NEWGAME;
			end
			LEVEL1 : begin
				if(dots_status) //if dots are present, the the level is not over
				begin
					next_state = LEVEL1;
					reset_state = 0;
				end
				else begin
					next_state = LEVEL1DONE; //if dots are over, then reset it and move to the next state, level 1 done sets the next level as level 2. We need the done state so we can start the next round only after enter is pressed again
					reset_state = 1;
				end
			end
            LEVEL1DONE : begin
				reset_state = 0;
				if(keycode == codeEnter)
					next_state = LEVEL2;
				else 
					next_state = LEVEL1DONE;
			end
			LEVEL2 : begin
				if(dots_status) //if dots are present, the the level is not over
				begin
					next_state = LEVEL2;
					reset_state = 0;
				end
				else begin
					next_state = LEVEL2DONE;
					reset_state = 1;
				end
			end
			LEVEL2DONE : begin
				reset_state = 0;
				if(keycode == codeEnter)
					next_state = LEVEL1;
				else 
					next_state = LEVEL2DONE;
			end
			
			endcase
		end
		
	end
	
	always_comb begin
		Starting_screen = 0;
		case (state)
			NEWGAME: begin
				level = 1;
				Starting_screen = 1;
			end
            LEVEL1DONE : begin
				level = 2;
				Starting_screen = 1;
			end
			LEVEL1 : begin
				level = 1;
			end
			LEVEL2 : begin
				level = 2;
			end
			LEVEL2DONE : begin
				level = 1;
				Starting_screen = 1;
			end
		endcase
	end

endmodule