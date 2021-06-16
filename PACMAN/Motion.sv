module  pac_motion (input Reset, frame_Clk,
					input [15:0]  keycode,
					input [155:0] horiz_walls, vert_walls,
                    output [9:0]  pacX, pacY, pacS,
					output [1:0] Direction );
					
    
    logic [15:0] scancode_A, scancode_W, scancode_S, scancode_D;
    logic [9:0] pac_curr_X, pac_curr_Y, pac_direction_X, pac_direction_Y, pac_move_X, pac_move_Y, pac_turn_X, pac_turn_Y, pacSize, prev_move_X, prev_move_Y,move_X, move_Y;
    logic intersection, turn_blocked, left_check, right_check, up_check, down_check, left_turn, right_turn, up_turn, down_turn;
    logic [2:0] direction_list; //3 bits signify, left, right, up and down
    
    assign pacSize = 4;
    assign scancode_W = 16'h001a;
    assign scancode_A = 16'h0004;
    assign scancode_S = 16'h0016;
    assign scancode_D = 16'h0007;
 
	 
    parameter [9:0] pac_X_Center=320;  // Center position on the X axis
    parameter [9:0] pac_Y_Center=240;  // Center position on the Y axis
	parameter [9:0] pac_X_Start=160;  // Center position on the X axis
    parameter [9:0] pac_Y_Start=160;  // Center position on the Y axis
    parameter [9:0] pac_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] pac_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] pac_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] pac_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] pac_X_Step=1;      // Step size on the X axis
    parameter [9:0] pac_Y_Step=1;      // Step size on the Y axis

    
    wall_check wall_check_module(.*, .curr_X(pac_curr_X[9:5]), .curr_Y(pac_curr_Y[9:5]), .final_check_left(left_check), .final_check_right(right_check), .final_check_up(up_check), .final_check_down(down_check) );

    always_comb begin
        if (keycode == scancode_W)  //up
        begin
            turn_blocked = ~up_check;
            pac_turn_Y = (~ (pac_Y_Step) + 1'b1);
            pac_turn_X = 10'd0;
            direction_list = 3'b010;
        end
        else if (keycode == scancode_A) //left
        begin
            turn_blocked = ~left_check;
            pac_turn_Y = 10'd0;
            pac_turn_X = (~ (pac_X_Step) + 1'b1);
            direction_list = 3'b000;
        end
        else if (keycode == scancode_S)      //user wants to go down
        begin
            turn_blocked = ~down_check; //checking down to see if there is a wall
            pac_turn_Y = pac_Y_Step;
            pac_turn_X = 10'd0;
            direction_list = 3'b011;
        end
        
        else if (keycode == scancode_D) //right
        begin
            turn_blocked = ~right_check;
            pac_turn_Y = 10'd0;
            pac_turn_X = pac_X_Step;
            direction_list = 3'b001;
        end
        else
        begin
            turn_blocked = 1'b1;    //if no move is attempted, then prevent moving by making all turns blocked
            pac_turn_Y = prev_move_Y;
            pac_turn_X = prev_move_X;
            direction_list = 3'b111;
        end
            
        intersection = ~(pac_curr_X[0] | pac_curr_X[1] | pac_curr_X[2] | pac_curr_X[3] | pac_curr_X[4] | pac_curr_Y[0] | pac_curr_Y[1] | pac_curr_Y[2] | pac_curr_Y[3] | pac_curr_Y[4]);
        
        
        left_turn = pac_move_X[9];
        up_turn   = pac_move_Y[9];
        right_turn = pac_move_X[0] & ~pac_move_X[9];
        down_turn  = pac_move_Y[0] & ~pac_move_Y[9];

        if(intersection)    //can only move at intersections within the map, otherwise cant move at all and direction remains the same of the character
        begin
            if(up_turn && up_check)
            begin
                pac_direction_X = 10'd0;
                pac_direction_Y = (~ (pac_Y_Step) + 1'b1);  //taking 2's complement to reverse the step to go up instead.
            end
            else if(down_turn && down_check)
            begin
                pac_direction_X = 10'd0;
                pac_direction_Y = pac_Y_Step;
            end
            else if(right_turn && right_check)
            begin
                pac_direction_X = pac_X_Step;
                pac_direction_Y = 10'd0;
            end
            else if(left_turn && left_check)
            begin
                pac_direction_X = (~ (pac_X_Step) + 1'b1);
                pac_direction_Y = 10'd0;
            end
            else
            begin
                pac_direction_X = 10'd0;
                pac_direction_Y = 10'd0;
            end
            
        end
        else begin
            if(direction_list == 3'b000 && right_turn)
            begin
                pac_direction_X = (~ (pac_X_Step) + 1'b1);  //go left
                pac_direction_Y = 10'd0;
            end
            else if(direction_list == 3'b001 && left_turn)
            begin
                pac_direction_X = pac_X_Step;
                pac_direction_Y = 10'd0;
            end
            else if(direction_list == 3'b010 && down_turn)
            begin
                pac_direction_X = 10'd0;
                pac_direction_Y = (~ (pac_Y_Step) + 1'b1);
            end
            else if(direction_list == 3'b011 && up_turn)
            begin
                pac_direction_X = 10'd0;
                pac_direction_Y = pac_Y_Step;
            end
            else
            begin
                pac_direction_X = pac_move_X;
                pac_direction_Y = pac_move_Y;
            end
        end
        
        if(turn_blocked == 1'b1 || intersection == 1'b0)    //if cant change directions, keep moving in the same path
        begin
            move_Y = pac_direction_Y;
            move_X = pac_direction_X;
        end
        else begin
            move_Y = pac_turn_Y;    //else make the turn, whichever is possible and calculated earlier
            move_X = pac_turn_X;
        end

    end
        
    always_ff @ (posedge Reset or posedge frame_Clk )
    begin: pac_movement
        if (Reset)  
        begin
            pac_curr_Y <= pac_Y_Start;
            pac_curr_X <= pac_X_Start;
            pac_move_Y <= 10'd0;
            pac_move_X <= 10'd0;
            prev_move_Y <= 10'd0;
            prev_move_X <= 10'd0; 
        end
            
        else
        begin
            pac_curr_Y <= (pac_curr_Y + move_Y); 
            pac_curr_X <= (pac_curr_X + move_X);
            pac_move_Y <= move_Y;
            pac_move_X <= move_X;
            prev_move_Y <= pac_turn_Y;
            prev_move_X <= pac_turn_X; 
        end  
    end

    assign pacS = pacSize;
    assign pacX = pac_curr_X;
    assign pacY = pac_curr_Y;

    always_comb
        begin
            if(pac_turn_Y == (~ (pac_Y_Step) + 1'b1))
                Direction = 2'b10;  //going up
            else if(pac_turn_Y == pac_Y_Step)   //down
                Direction = 2'b11;
            else if(pac_turn_X == (~ (pac_X_Step) + 1'b1))  //going left
                Direction = 2'b01;
            else
                Direction = 2'b00;  //right
        end


    endmodule







module  ghost_motion(input Reset, frame_Clk,
					 input [4:0]   x_start, y_start,
					 input [155:0] horiz_walls, vert_walls,
					 input [9:0]   pacX, pacY,
					 input [15:0]  randomness,
					 output        hitPacman,
                     output [9:0]  ghostX, ghostY
                    );
					
    
    logic [9:0] ghost_curr_X, ghost_move_X, ghost_move_Y, ghost_turn_X, ghost_curr_Y, ghost_turn_Y, ghostSize, ghost_direction_X, ghost_direction_Y, ghost_prev_X, ghost_prev_Y, move_X, move_Y;
    logic [9:0] delta_X_GP, delta_Y_GP, delta_X_PG, delta_Y_PG, pos_delta_X, pos_delta_Y, contact_X, contact_Y, delta_for_contact;
    logic [3:0] direction_list;     //4 bits signify, left, right, up and down
    logic [2:0] randomizer, randomizer_comb;
    logic [1:0] randomness_factor;  //adding randomness to make the ghost more unpredictable, drawback is that ghost might not follow best path despite knowing the best path. need to work on this further
    logic intersection, turn_blocked, left_check, right_check, up_check, down_check, left_turn, right_turn, up_turn, down_turn, ghost_move_up, ghost_move_left, ghost_move_down, ghost_move_right, planeX, planeY;
    

    assign delta_for_contact = 10'h00a;	 
    assign ghostSize = 4;
	 
    parameter [9:0] ghost_X_Center=320;  // Center position on the X axis
    parameter [9:0] ghost_Y_Center=240;  // Center position on the Y axis
    logic [9:0] ghost_X_Start;          // Center position on the X axis
	logic [9:0] ghost_Y_Start;          // Center position on the Y axis
    parameter [9:0] ghost_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] ghost_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] ghost_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] ghost_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] ghost_X_Step=1;      // Step size on the X axis
    parameter [9:0] ghost_Y_Step=1;      // Step size on the Y axis
	 
	
    assign ghost_X_Start = {x_start, 5'b0};
    assign ghost_Y_Start = {y_start, 5'b0};

    wall_check wall_check_module(.*, .curr_X(ghost_curr_X[9:5]), .curr_Y(ghost_curr_Y[9:5]), .final_check_left(left_check), .final_check_right(right_check), .final_check_up(up_check), .final_check_down(down_check) );
	 
    assign direction_list = {left_check, right_check, up_check, down_check};


    always_comb 
    begin: Ghost_move_logic
	 
        delta_X_PG = (~ghost_curr_X + 1'b1) + (pacX);   //pacX - ghostX
		delta_Y_PG = (~ghost_curr_Y + 1'b1) + (pacY);
	 
		delta_X_GP = ghost_curr_X + (~pacX + 1'b1);     //ghostX-pacX
		delta_Y_GP = ghost_curr_Y + (~pacY + 1'b1);
		
		if(!delta_X_GP[9])               //checking to see if pac - ghost gives a negative result by checking the MSB, same with Y
			pos_delta_X = delta_X_GP;
		else
			pos_delta_X = delta_X_PG;       //if it is negative, storing the positive result in X as the delta between the 2
		if(!delta_Y_GP[9])
            pos_delta_Y = delta_Y_GP;
		else
			pos_delta_Y = delta_Y_PG;
			
		contact_X = pos_delta_X + (~delta_for_contact + 1'b1);
		contact_Y = pos_delta_Y + (~delta_for_contact + 1'b1);  //calculating if contact could occur depending on preset delta needed for contact between ghost and pac
		if((!contact_X && contact_Y[9]) || (!contact_Y && contact_X[9]) )   //if contactX is 0 and Y is neg, then contact. or opp as well
			hitPacman = 1'b1;
		else
			hitPacman = 1'b0;

		if(!delta_X_GP[9] && delta_X_GP)    //if g-p is positive and the there is some gap between them, then start moving left as pac is to the left (think co-ordinates)
		begin
			ghost_move_left = 1'b1;
			ghost_move_right = 1'b0;
		end
		else
		begin
			ghost_move_left = 1'b0;
			if(delta_X_GP)              // there is some gap but pac is actually to the right, so move right
				ghost_move_right = 1'b1;
			else
				ghost_move_right = 1'b0;    //there is no gap but no contact so pac is either up or down
		end
		if(!delta_Y_GP[9] && delta_Y_GP)    //same case as X here, if g- p is pos, then the pac is up
		begin
			ghost_move_up = 1'b1;
			ghost_move_down = 1'b0;
		end
		else
		begin
			ghost_move_up = 1'b0;
			if(delta_Y_GP)
				ghost_move_down = 1'b1;
			else
				ghost_move_down = 1'b0;
		end

        // if(randomizer)  
        //     randomness_factor = randomness[randomizer+1:randomizer];
        // else 
        //     randomness_factor = randomness[1:0];

		unique case (randomizer)	//setting the randomness factor for the ghost movement by the present val randomly defined
			3'h0 : randomness_factor = randomness[1:0];
			3'h1 : randomness_factor = randomness[3:2];
			3'h2 : randomness_factor = randomness[5:4];
			3'h3 : randomness_factor = randomness[7:6];
			3'h4 : randomness_factor = randomness[9:8];
			3'h5 : randomness_factor = randomness[11:10];
			3'h6 : randomness_factor = randomness[13:12];
			3'h7 : randomness_factor = randomness[15:14];
			default : randomness_factor = randomness[1:0];
		endcase
        
        left_turn = ghost_move_X[9];
        up_turn   = ghost_move_Y[9];
        right_turn = ghost_move_X[0] & ~ghost_move_X[9];
        down_turn  = ghost_move_Y[0] & ~ghost_move_Y[9];

        planeX = ~( ghost_curr_X[0] | ghost_curr_X[1] | ghost_curr_X[2] | ghost_curr_X[3] | ghost_curr_X[4] );
        planeY = ~( ghost_curr_Y[0] | ghost_curr_Y[1] | ghost_curr_Y[2] | ghost_curr_Y[3] | ghost_curr_Y[4] );
        intersection = planeX & planeY;    //checking if the ghost is at intersection to decide the next move for the ghost
        
		 
        unique case(direction_list)    //4 bits are stored as left, right, up, down from MSB to LSB for all possible movements at the intersection
			4'b0000 : 
            begin //all paths are blocked. This is only the case for the start to get the ghost out of the cage at the start of the game
				ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1); //move up
				ghost_turn_X = 10'd0;
			end
			4'b0001 : 
            begin //can only go down
				ghost_turn_Y = ghost_Y_Step;  //moving down
				ghost_turn_X = 10'd0;
			end
			4'b0010 : 
            begin //can only move up
				ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);  // moving up
				ghost_turn_X = 10'd0;
			end
			4'b0100 : 
            begin //can only go right
				ghost_turn_Y = 10'd0;
				ghost_turn_X = ghost_X_Step;  //moving right
			end
			4'b1000 : 
            begin // can only go left
				ghost_turn_Y = 10'd0;
				ghost_turn_X = (~ (ghost_X_Step) + 1'b1);  //moving left
			end
            4'b0011 : 
            begin // can move up or down
				if(randomness_factor >= 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
					if(up_turn || ghost_move_up)    //randomizer is good here
					begin
						ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
						ghost_turn_X = 10'd0;
					end
					else begin
						ghost_turn_Y = ghost_Y_Step;
						ghost_turn_X = 10'd0;
					end
				end
				else begin
					if(!up_turn || !ghost_move_down)
					begin
						ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
						ghost_turn_X = 10'd0;
					end
					else begin
						ghost_turn_Y = ghost_Y_Step;    //move down
						ghost_turn_X = 10'd0;
					end
				end
			end
            4'b0101 : 
            begin //can move right or down
				if(randomness_factor == 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
					if(right_turn || ghost_move_right)
					begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = ghost_X_Step;
					end
					else begin
						ghost_turn_Y = ghost_Y_Step;
						ghost_turn_X = 10'd0;
					end
				end
				else begin
					if(!down_turn ||!ghost_move_down)
					begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = ghost_X_Step;
					end
					else begin
						ghost_turn_Y = ghost_Y_Step;
						ghost_turn_X = 10'd0;
					end
				end
			end
            4'b0110 : 
            begin // can move right or up
				if(randomness_factor <= 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
					if(right_turn || ghost_move_right)
					begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = ghost_X_Step;
					end
					else begin
						ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
						ghost_turn_X = 10'd0;
					end
				end
				else begin
					if(!up_turn || !ghost_move_up)
					begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = ghost_X_Step;
					end
					else begin
						ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
						ghost_turn_X = 10'd0;
					end
				end
			end
            4'b0111 : 
            begin // can move right up or down
                if(randomness_factor <= 2'b10) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
                    if(right_turn || ghost_move_right)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                    else if(up_turn || ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                end
                else begin
                    if(ghost_move_right)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                    else if(ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                end
			end
            4'b1001 : 
            begin // can move left or down
				if(randomness_factor == 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
					if(down_turn || ghost_move_down)
					begin
						ghost_turn_Y = ghost_Y_Step;
						ghost_turn_X = 10'd0;
					end
					else begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
					end
				end
				else begin
					if(!left_turn || !ghost_move_left)
					begin
						ghost_turn_Y = ghost_Y_Step;
						ghost_turn_X = 10'd0;
					end
					else begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
					end
				end
			end
            4'h1010 : 
            begin // can move left and up
				if(randomness_factor >= 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
					if(up_turn || ghost_move_up)
					begin
						ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
						ghost_turn_X = 10'd0;
					end
					else begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
					end
				end
				else begin
					if(!left_turn || !ghost_move_left)
					begin
						ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
						ghost_turn_X = 10'd0;
					end
					else begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
					end
				end
			end
            4'b1011 : 
            begin // can move left up and down
                if(randomness_factor == 2'b00) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
                    if(left_turn || ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else if(up_turn || ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                end
                else begin
                    if(ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else if(ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                end
			end

			4'b1100 : 
            begin // can move left and right
				if(randomness_factor == 2'b10) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
					if(left_turn || ghost_move_left)
					begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
					end
					else begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = ghost_X_Step;
					end
				end
				else begin
					if(!right_turn ||!ghost_move_right)
					begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
					end
					else begin
						ghost_turn_Y = 10'd0;
						ghost_turn_X = ghost_X_Step;
					end
				end
			end
            4'h1101 : 
            begin // can move left, right and down
                if(randomness_factor <= 2'b10) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
                    if(down_turn || ghost_move_down)
                    begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                    else if(left_turn || ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                end
                else begin
                    if(ghost_move_down)
                    begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                    else if(ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                end
			end
			4'b1110 : 
            begin // can move left, right and up
				if(randomness_factor >= 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
                    if(up_turn || ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else if(left_turn || ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                end
                else begin
                    if(ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else if(ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                end
			end
			4'h1111 : 
            begin // can move left, right up and down
				if(randomness_factor >= 2'b01) //taking a random value to create unpredictability. if factor matches, then the behaviour might not be the best path to the pacman
				begin
                    if(up_turn || ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else if(down_turn || ghost_move_down)
                    begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                    else if(left_turn || ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                end
                else begin
                    if(ghost_move_up)
                    begin
                        ghost_turn_Y = (~ (ghost_Y_Step) + 1'b1);
                        ghost_turn_X = 10'd0;
                    end
                    else if(ghost_move_down)
                    begin
                        ghost_turn_Y = ghost_Y_Step;
                        ghost_turn_X = 10'd0;
                    end
                    else if(ghost_move_left)
                    begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = (~ (ghost_X_Step) + 1'b1);
                    end
                    else begin
                        ghost_turn_Y = 10'd0;
                        ghost_turn_X = ghost_X_Step;
                    end
                end
			end
		endcase
		
		
		ghost_direction_X = ghost_move_X;
        ghost_direction_Y = ghost_move_Y;     

        if(!intersection)  //if not at intersection, keep moving
        begin
            move_Y = ghost_direction_Y;
            move_X = ghost_direction_X;
            randomizer_comb = randomizer;
        end
        else begin
			// ghost_direction_X = ghost_move_X;
        	// ghost_direction_Y = ghost_move_Y;
            move_Y = ghost_turn_Y;
            move_X = ghost_turn_X;
            if(randomizer_comb == 3'h7)
                randomizer_comb = 3'h0;
            else
                randomizer_comb = randomizer_comb + 3'h1;
        end
    end
	 
    always_ff @ (posedge Reset or posedge frame_Clk )
    begin: Move_ghost
        if (Reset)
        begin
            ghost_move_Y <= 10'd0;
            ghost_move_X <= 10'd0;
            ghost_curr_Y <= ghost_Y_Start;
            ghost_curr_X <= ghost_X_Start;
            ghost_prev_Y <= 10'd0;
            ghost_prev_X <= 10'd0;
            randomizer <= 3'h0;
        end
           
        else
        begin
            ghost_prev_Y <= ghost_turn_Y;
            ghost_prev_X <= ghost_turn_X;
            ghost_move_Y <= move_Y;
            ghost_move_X <= move_X;
            ghost_curr_Y <= (ghost_curr_Y + move_Y);
            ghost_curr_X <= (ghost_curr_X + move_X);
            randomizer <= randomizer_comb;
		end  
    end
       
    assign ghostX = ghost_curr_X; 
    assign ghostY = ghost_curr_Y;
    

endmodule