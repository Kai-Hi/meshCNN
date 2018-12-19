// defining width/height OF EACH WINDOW
// this is NOT MESH SIZE
`define WIN_WIDTH 5		// MUST BE LARGER THAN 2
`define WIN_HEIGHT 6		// MUST BE EVEN

// phases
`define PH_DEF 1
`define PH_UNENABLED 2'b00
`define PH_INITIATE 2'b01
`define PH_WORKING 2'b10
`define PH_DISABLED 2'b11


/*
	** main behabiour **
	1. multiply value with weight 
	2. add input and product
	3. update step pointer and direction pointer

*/
module conv_cell (ck, res, i_north, i_south, i_east, i_west, o_north, o_south, o_east, o_west);
input		ck;
input 		res;
input 		 [11:0]	i_north, i_south, i_east, i_west;
output	reg	 [11:0]	o_north, o_south, o_east, o_west;
reg   [1:0]	phase = `PH_UNENABLED;

parameter RIGHT = 2'b01;
parameter LEFT = 2'b10;
parameter UP = 2'b11;
parameter DOWN = 2'b00;

reg [3:0] weights[`WIN_WIDTH*`WIN_HEIGHT-1:0];		// CNN window weight 
reg [3:0] value;			// pixel value
reg [11:0] inbuf;
reg [7:0]  mulbuf;
reg [7:0]  step;			// 1~[w*h]
reg [1:0]  direction_o;			// RIGHT,LEFT,UP,DOWN
reg [1:0]  direction_i;
reg	   ck_work = 1;			// internal clock for PH_WORKING
reg [11:0] conv;			// the answer

integer i;

// convolution hamilton path which is common in every cell
reg [`WIN_WIDTH*`WIN_HEIGHT*2-1:0] path;


always @(posedge ck, negedge res) begin : Convolution

	// reset weights, value and the path
	// replace this when "Back Propagation" and "Picture input" become available
	if(!res) begin
		// assume substitutions below as external inputs
		for (i=0; i<=`WIN_WIDTH*`WIN_HEIGHT-1; i=i+1)begin
			weights[i] <= 4'd10;
		end
		value <= 4'd5;
		// end of external inputs
	
		/*
		// ex) case of 4*4
		path <= {
			RIGHT,RIGHT,RIGHT,DOWN,
			LEFT, LEFT, DOWN,
			RIGHT,RIGHT,DOWN,
			LEFT, LEFT, LEFT, UP,
			UP,
			UP
			};
		*/

		path <= {
			RIGHT,
			{(`WIN_HEIGHT/2-1){{{(`WIN_WIDTH-2){RIGHT}}},DOWN,{{(`WIN_WIDTH-2){LEFT}},DOWN}}},
			{{(`WIN_WIDTH-2){RIGHT}},DOWN,{(`WIN_WIDTH-1){LEFT}}},
			{(`WIN_HEIGHT-1){UP}}
			};
		
		o_north <= 12'b0;
		o_south <= 12'b0;
		o_east <= 12'b0;
		o_west <= 12'b0;

		phase <= `PH_INITIATE;
	end else begin
	
		// break if disabled or unenabled
		if(phase == `PH_DISABLED || phase == `PH_UNENABLED) begin
			disable Convolution;
		end
	
		// initiate buffers
		if(phase == `PH_INITIATE) begin
			inbuf <= 8'h00;
			mulbuf <= value * weights[0];
			step <= 8'h00;
			direction_i <= RIGHT;	// don't care
			direction_o <= path[31:30];
			path <= path<<2;
			
			phase <= `PH_WORKING;
		end
	
		// main loop for convolution
		if(phase == `PH_WORKING) begin
			if(ck_work) begin
				case (direction_o)
					RIGHT:	o_east  <= inbuf + {4'b0,mulbuf};
					LEFT:	o_west  <= inbuf + {4'b0,mulbuf};
					UP:	o_north <= inbuf + {4'b0,mulbuf};
					DOWN:	o_south <= inbuf + {4'b0,mulbuf};
				endcase
				
				direction_i <= direction_o;
				direction_o <= path[`WIN_WIDTH*`WIN_HEIGHT*2-1:`WIN_WIDTH*`WIN_HEIGHT*2-2];
				path <= path<<2;
				mulbuf 		<= value * weights[step];
				step 		<= step+1;
				ck_work <= ~ck_work;
			end else begin
				case (direction_i)
					RIGHT:	inbuf <= i_west;
					LEFT:	inbuf <= i_east;
					UP:	inbuf <= i_south;
					DOWN:	inbuf <= i_north;
				endcase
				ck_work <= ~ck_work;

				// solve then disable if everything is done
				if(step == 4'd`WIN_WIDTH * 4'd`WIN_HEIGHT) begin
					conv <= inbuf + {4'b0,mulbuf};
					phase <= `PH_DISABLED;
					disable Convolution;
				end
			end

		end
	end
end


endmodule
