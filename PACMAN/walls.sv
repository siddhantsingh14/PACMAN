module walls_init (input  Starting_screen,
				  output [155:0] horiz_walls, vert_walls
               );
    
    logic [155:0] pac_vertical, pac_horizontal, starting_vertical, starting_horizontal;

    assign starting_vertical = {
		39'h7fffffffff,
		26'h3ffffff,
		26'h3f7ffbf,
		26'h3ffffff,
		39'h7fffffffff
	};
	 
	assign starting_horizontal = {
		72'hffffffffffffffffff,
		12'hf9f,
		72'hffffffffffffffffff
	};
	 
	assign pac_vertical = {
		39'h4107ddf001,
		39'h45466330e1,
		39'h4fe6633041,
		39'h48262a3001
	 };
	 

	assign pac_horizontal = {
		72'hfff59a59a666e97e67,
		72'he67060e67696c6379e,
		12'hfff
	};
	 
    always_comb
    begin: Assigning_Wall
        if (Starting_screen == 1'b1)
        begin
            horiz_walls = starting_horizontal;
            vert_walls = starting_vertical;
        end
        else 
        begin
            horiz_walls = pac_horizontal;
            vert_walls  = pac_vertical;
        end
			
	 end

endmodule

module wall_check(input [0:155]  horiz_walls, vert_walls,
				   input [0:4] curr_X, curr_Y,
                   output logic final_check_left, final_check_right, final_check_up, final_check_down 
				);

	 logic [0:11] check_left, check_right, check_up, check_down;
	 
	 wall_vertical_check check_row0(.curr_X(curr_X), .check_down(check_down[0]), .check_left(check_left[0]), .check_right(check_right[0]),  .check_up(check_up[0]),  .vert_walls(~vert_walls[0:12]), .above_walls(~horiz_walls[0:11]), .below_walls(~horiz_walls[12:23]));
	 wall_vertical_check check_row1(.curr_X(curr_X), .check_down(check_down[1]), .check_left(check_left[1]), .check_right(check_right[1]),  .check_up(check_up[1]),  .vert_walls(~vert_walls[13:25]), .above_walls(~horiz_walls[12:23]), .below_walls(~horiz_walls[24:35]));
	 wall_vertical_check check_row2(.curr_X(curr_X), .check_down(check_down[2]), .check_left(check_left[2]), .check_right(check_right[2]),  .check_up(check_up[2]),  .vert_walls(~vert_walls[26:38]), .above_walls(~horiz_walls[24:35]), .below_walls(~horiz_walls[36:47]));
	 wall_vertical_check check_row3(.curr_X(curr_X), .check_down(check_down[3]), .check_left(check_left[3]), .check_right(check_right[3]),  .check_up(check_up[3]),  .vert_walls(~vert_walls[39:51]), .above_walls(~horiz_walls[36:47]), .below_walls(~horiz_walls[48:59]));
	 wall_vertical_check check_row4(.curr_X(curr_X), .check_down(check_down[4]), .check_left(check_left[4]), .check_right(check_right[4]),  .check_up(check_up[4]),  .vert_walls(~vert_walls[52:64]), .above_walls(~horiz_walls[48:59]), .below_walls(~horiz_walls[60:71]));
	 wall_vertical_check check_row5(.curr_X(curr_X), .check_down(check_down[5]), .check_left(check_left[5]), .check_right(check_right[5]),  .check_up(check_up[5]),  .vert_walls(~vert_walls[65:77]), .above_walls(~horiz_walls[60:71]), .below_walls(~horiz_walls[72:83]));
	 wall_vertical_check check_row6(.curr_X(curr_X), .check_down(check_down[6]), .check_left(check_left[6]), .check_right(check_right[6]),  .check_up(check_up[6]),  .vert_walls(~vert_walls[78:90]), .above_walls(~horiz_walls[72:83]), .below_walls(~horiz_walls[84:95]));
	 wall_vertical_check check_row7(.curr_X(curr_X), .check_down(check_down[7]), .check_left(check_left[7]), .check_right(check_right[7]),  .check_up(check_up[7]),  .vert_walls(~vert_walls[91:103]), .above_walls(~horiz_walls[84:95]), .below_walls(~horiz_walls[96:107]));
	 wall_vertical_check check_row8(.curr_X(curr_X), .check_down(check_down[8]), .check_left(check_left[8]), .check_right(check_right[8]),  .check_up(check_up[8]),  .vert_walls(~vert_walls[104:116]), .above_walls(~horiz_walls[96:107]), .below_walls(~horiz_walls[108:119]));
	 wall_vertical_check check_row9(.curr_X(curr_X), .check_down(check_down[9]), .check_left(check_left[9]), .check_right(check_right[9]),  .check_up(check_up[9]),  .vert_walls(~vert_walls[117:129]), .above_walls(~horiz_walls[108:119]), .below_walls(~horiz_walls[120:131]));
	 wall_vertical_check check_row10(.curr_X(curr_X), .check_down(check_down[10]), .check_left(check_left[10]), .check_right(check_right[10]), .check_up(check_up[10]), .vert_walls(~vert_walls[130:142]), .above_walls(~horiz_walls[120:131]), .below_walls(~horiz_walls[132:143]));
	 wall_vertical_check check_row11(.curr_X(curr_X), .check_down(check_down[11]), .check_left(check_left[11]), .check_right(check_right[11]), .check_up(check_up[11]), .vert_walls(~vert_walls[143:155]), .above_walls(~horiz_walls[132:143]), .below_walls(~horiz_walls[144:155]));
	 
	 
	 always_comb begin
		 unique case (curr_Y)   //checking the position depending on row sanity check and assigning sanity of possible move
		 5'h00 : begin
            final_check_right = 1'b0;
            final_check_left = 1'b0;
            final_check_down = 1'b1;
            final_check_up = 1'b0;
		 end
		 5'h01 : begin
            final_check_right = check_right[0];
            final_check_left = check_left[0];
            final_check_down = check_down[0];
            final_check_up = check_up[0];
		 end
		 5'h02 : begin
            final_check_right = check_right[1];
            final_check_left = check_left[1];
            final_check_down = check_down[1];
            final_check_up = check_up[1];
		 end
		 5'h03 : begin
            final_check_right = check_right[2];
            final_check_left = check_left[2];
            final_check_down = check_down[2];
            final_check_up = check_up[2];
		 end
		 5'h04 : begin
            final_check_right = check_right[3];
            final_check_left = check_left[3];
            final_check_down = check_down[3];
            final_check_up = check_up[3];
		 end
		 5'h05 : begin
            final_check_right = check_right[4];
            final_check_left = check_left[4];
            final_check_down = check_down[4];
            final_check_up = check_up[4];
		 end
		 5'h06 : begin
            final_check_right = check_right[5];
            final_check_left = check_left[5];
            final_check_down = check_down[5];
            final_check_up = check_up[5];
		 end
		 5'h07 : begin
            final_check_right = check_right[6];
            final_check_left = check_left[6];
            final_check_down = check_down[6];
            final_check_up = check_up[6];
		 end
		 5'h08 : begin
            final_check_right = check_right[7];
            final_check_left = check_left[7];
            final_check_down = check_down[7];
            final_check_up = check_up[7];
		 end
		 5'h09 : begin
             final_check_right = check_right[8];
            final_check_left = check_left[8];
            final_check_down = check_down[8];
            final_check_up = check_up[8];
		 end
		 5'h0a : begin
            final_check_right = check_right[9];
            final_check_left = check_left[9];
            final_check_down = check_down[9];
            final_check_up = check_up[9];
		 end
		 5'h0b : begin
            final_check_right = check_right[10];
            final_check_left = check_left[10];
            final_check_down = check_down[10];
            final_check_up = check_up[10];
		 end
		 5'h0c : begin
            final_check_right = check_right[11];
            final_check_left = check_left[11];
            final_check_down = check_down[11];
            final_check_up = check_up[11];
		 end
		 default : begin
            final_check_right = 1'b0;
            final_check_left = 1'b0;
            final_check_down = 1'b0;
            final_check_up = 1'b1;
		 end
		 endcase
	 end

endmodule


module wall_vertical_check(input [0:12]  vert_walls,
					        input [0:11] below_walls, above_walls,
					        input [0:4] curr_X,
                            output logic check_left, check_right, check_up, check_down
					    );
    
	 always_comb begin
		 unique case (curr_X)   //checking the position depending on row sanity check and assigning sanity of possible move
		 5'h00 : begin
            check_left = 1'b0;
            check_right = 1'b1;
            check_down = 1'b0;
            check_up = 1'b0;
		 end
		 5'h01 : begin
            check_left = vert_walls[0];
			check_right = vert_walls[1];
            check_down = below_walls[0];
            check_up = above_walls[0];
		 end
		 5'h02 : begin
            check_left = vert_walls[1];
            check_right = vert_walls[2];
            check_down = below_walls[1];
            check_up = above_walls[1];
		 end
		 5'h03 : begin
            check_left = vert_walls[2];
            check_right = vert_walls[3];
            check_down = below_walls[2];
            check_up = above_walls[2];
		 end
		 5'h04 : begin
            check_left = vert_walls[3];
            check_right = vert_walls[4];
            check_down = below_walls[3];
            check_up = above_walls[3];
		 end
		 5'h05 : begin
            check_left = vert_walls[4];
            check_right = vert_walls[5];
            check_down = below_walls[4];
            check_up = above_walls[4];
		 end
		 5'h06 : begin
            check_left = vert_walls[5];
            check_right = vert_walls[6];
            check_down = below_walls[5];
            check_up = above_walls[5];
		 end
		 5'h07 : begin
            check_left = vert_walls[6];
            check_right = vert_walls[7];
            check_down = below_walls[6];
            check_up = above_walls[6];
		 end
		 5'h08 : begin
            check_left = vert_walls[7];
            check_right = vert_walls[8];
            check_down = below_walls[7];
            check_up = above_walls[7];
		 end
		 5'h09 : begin
            check_left = vert_walls[8];
            check_right = vert_walls[9];
            check_down = below_walls[8];
            check_up = above_walls[8];
		 end
		 5'h0a : begin
            check_left = vert_walls[9];
            check_right = vert_walls[10];
            check_down = below_walls[9];
            check_up = above_walls[9];
		 end
		 5'h0b : begin
            check_left = vert_walls[10];
            check_right = vert_walls[11];
            check_down = below_walls[10];
            check_up = above_walls[10];
		 end
		 5'h0c : begin
            check_left = vert_walls[11];
            check_right = vert_walls[12];
            check_down = below_walls[11];
            check_up = above_walls[11];
		 end
		 default : begin
            check_left = 1'b1;
            check_right = 1'b0;
            check_down = 1'b0;
            check_up = 1'b0;
		 end
		 endcase
	 end

endmodule