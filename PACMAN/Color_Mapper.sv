module  color_mapper(input  [9:0] BallX, BallY, DrawX, DrawY, Ball_size, 
					input [9:0]   oghostx, oghosty, bghostx, bghosty, rghostx, rghosty, pghostx, pghosty,
                    input  [143:0] currDotMap,
                    input 	[1:0] Direction, level,
                    output logic [7:0]  Red, Green, Blue 
                );

    logic [415:0]wall_display;
	logic [0:31]pac_display;
    logic [31:0] chomping_data, ghost_O_display, ghost_B_display, ghost_R_display, ghost_P_display;
    logic [9:0]wall_sprite, dot_X_pos, dot_Y_pos, pac_destination;
    logic [7:0]PAC_sprite_array, ghost_O_sprite, ghost_B_sprite, ghost_R_sprite, ghost_P_sprite, ghost_offset;
    logic [2:0] dot_sprite;
    logic [1:0] dot_display;
    logic pac_en, ghost_O_en, ghost_B_en, ghost_R_en, ghost_P_en, dot_en, wall_en;
    // logic chomp;
    

    assign dot_X_pos = DrawX + 2 - 32;
    assign dot_Y_pos = DrawY + 2 - 32;
    assign ghost_offset = 224;
    
    assign pac_destination = (DrawY - BallY + Ball_size + 96 + 32 * Direction);

//  logic [9:0] tmp2;
//  assign tmp2 = (DrawY - BallY + Ball_size + 96 /*+ 32 * Direction*/);
    
    spriteData get_pac(.addr(PAC_sprite_array), .data(pac_display));
//  spriteData_chomping spritePac_chomping(.addr(PAC_sprite_array), .data(chomping_data));
    spriteData get_ghost_o(.addr(ghost_O_sprite), .data(ghost_O_display));
    spriteData get_ghost_r(.addr(ghost_R_sprite), .data(ghost_R_display));
    spriteData get_ghost_b(.addr(ghost_B_sprite), .data(ghost_B_display));
    spriteData get_ghost_p(.addr(ghost_P_sprite), .data(ghost_P_display));
    wallData get_map (.addr(wall_sprite), .data(wall_display));
    dotSpriteData get_dots ( .addr(dot_sprite), .data(dot_display) );

// always_comb
// begin: Set_chomp
// 		if(chomp==1)
// 			chomp=0;
// 		else
// 			chomp=1;
// end

always_comb
begin:pac_en_proc
        if ((DrawX >= BallX - Ball_size) &&(DrawX <= BallX + Ball_size) && (DrawY >= BallY - Ball_size) && (DrawY <= BallY + Ball_size))
        begin
        // if(chomp==1)
        // begin
        // 	chomp=0;
        // end
        // else
        // begin
        // 	chomp=1;
        // end
            PAC_sprite_array = pac_destination[7:0];
            // pac_display_chomping = tmp2[7:0];
            pac_en = 1'b1;
            // chomp =1;
        end
    else
        begin
            PAC_sprite_array = 7'b0000000;
            // pac_display_chomping = 6'b000000;
            pac_en = 1'b0;
        // chomp =0;
        end
        
        if ((DrawX >= oghostx - Ball_size) &&(DrawX <= oghostx + Ball_size) && (DrawY >= oghosty - Ball_size) && (DrawY <= oghosty + Ball_size))
        begin
            ghost_O_sprite = (DrawY - oghosty + Ball_size + ghost_offset);
            ghost_O_en = 1'b1;
        end
    else
        begin
            ghost_O_sprite = 7'b0000000;
        ghost_O_en = 1'b0;
        end
        
        if ((DrawX >= bghostx - Ball_size) &&(DrawX <= bghostx + Ball_size) && (DrawY >= bghosty - Ball_size) && (DrawY <= bghosty + Ball_size))
        begin
            ghost_B_sprite = (DrawY - bghosty + Ball_size + ghost_offset);
            ghost_B_en = 1'b1;
        end
    else
        begin
            ghost_B_sprite = 7'b0000000;
        ghost_B_en = 1'b0;
        end
        
        if ((DrawX >= rghostx - Ball_size) &&(DrawX <= rghostx + Ball_size) && (DrawY >= rghosty - Ball_size) && (DrawY <= rghosty + Ball_size))
        begin
            ghost_R_sprite = (DrawY - rghosty + Ball_size + ghost_offset);
            ghost_R_en = 1'b1;
        end
    else
        begin
            ghost_R_sprite = 7'b0000000;
        ghost_R_en = 1'b0;
        end
        
        if ((DrawX >= pghostx - Ball_size) &&(DrawX <= pghostx + Ball_size) && (DrawY >= pghosty - Ball_size) && (DrawY <= pghosty + Ball_size))
        begin
            ghost_P_sprite = (DrawY - pghosty + Ball_size + ghost_offset);
            ghost_P_en = 1'b1;
        end
    else
        begin
            ghost_P_sprite = 7'b0000000;
        ghost_P_en = 1'b0;
        end
        
        if(DrawX > 16 && DrawY > 16 && DrawX < 410 && DrawY <= 400 && currDotMap[ dot_Y_pos[9:5]*12 + dot_X_pos[9:5] ] == 1'b1 && dot_X_pos[4:0] <=3 && dot_Y_pos[4:0] <=3 )//dot_en
        begin
            dot_sprite = dot_Y_pos[2:0];
            dot_en = 1'b1;
        end
        else begin
            dot_sprite = 3'b100;
            dot_en = 1'b0;
        end
        
        if(DrawX < 416 && DrawY <= 400)
        begin
            wall_sprite = DrawY + 221;
            wall_en = 1'b1;
        end
        else
        begin
            wall_sprite = 10'b0000000000;
            wall_en = 1'b0;
        end
    end

always_comb
begin:RGB_Display
    // if ((pac_en == 1'b1) && (chomp == 1'b1)&& (chomping_data[DrawX - BallX + Ball_size] == 1'b1))
    // begin
    //     Red = 8'hff;
    //     Green = 8'hff;
    //     Blue = 8'h00;
    // end
    if ((pac_en == 1'b1) /*&& (chomp == 1'b0)*/ && (pac_display[DrawX - BallX + Ball_size] == 1'b1))
    begin
        Red = 8'hff;
        Green = 8'hff;
        Blue = 8'h00;
    end

        else if(ghost_O_en == 1'b1 && ghost_O_display[DrawX - oghostx + Ball_size] == 1'b1)
        begin
        Red = 8'hff;
        Green = 8'hb8;
        Blue = 8'h51;
    end
        else if(ghost_B_en == 1'b1 && ghost_B_display[DrawX - bghostx + Ball_size] == 1'b1)
        begin
        Red = 8'h01;
        Green = 8'hff;
        Blue = 8'hff;
    end
        else if(ghost_R_en == 1'b1 && ghost_R_display[DrawX - rghostx + Ball_size] == 1'b1)
        begin
        Red = 8'hff;
        Green = 8'h5f;
        Blue = 8'h5f;
    end
        else if(ghost_P_en == 1'b1 && ghost_P_display[DrawX - pghostx + Ball_size] == 1'b1)
        begin
        Red = 8'hff;
        Green = 8'hb8;
        Blue = 8'hff;
    end
        else if(dot_en == 1'b1 && dot_display[dot_X_pos[1:0]] == 1'b1)
        begin
            Red = 8'hff;
        Green = 8'hff;
        Blue = 8'h00;
        end
        else if(wall_en == 1'b1 && wall_display[DrawX] == 1'b1)
    begin
            Red = 8'h00;
            Green = 8'h00;
            Blue = 8'hff;
    end
        else
        begin
            Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h00;
        end
end

endmodule
