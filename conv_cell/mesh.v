
// defining width/height OF MESH ITSELF
// this is NOT WINDOW SIZE
`define MESH_WIDTH 20
`define MESH_HEIGHT 20

module conv_mesh (ck, res);
input		ck;
input 		res;

wire [11:0] n[`MESH_WIDTH:0][`MESH_HEIGHT:0];
wire [11:0] s[`MESH_WIDTH:0][`MESH_HEIGHT:0];
wire [11:0] w[`MESH_WIDTH:0][`MESH_HEIGHT:0];
wire [11:0] e[`MESH_WIDTH:0][`MESH_HEIGHT:0];

// making the edge high-impedance to check error and clearify "pudding margin"
parameter verge = 12'bz;

// there are 9 cases of generation: 4 corners, 4 edges and central board
genvar i,j;
generate
for (i=0;i<=`MESH_WIDTH;i=i+1) begin: GenerateRow
	for (j=0;j<`MESH_HEIGHT;j=j+1) begin:GenerateColumn
		if(i==0)begin
			if(j==0)
				conv_cell c_nw(	.ck(ck),.res(res),
						.i_north(verge), .i_south(n[i][j+1]), .i_east(w[i+1][j]), .i_west(verge),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
			else if(j==`MESH_HEIGHT-1)
				conv_cell c_sw(	.ck(ck),.res(res),
						.i_north(s[i][j-1]), .i_south(verge), .i_east(w[i+1][j]), .i_west(verge),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
			else
				conv_cell c_w(	.ck(ck),.res(res),
						.i_north(s[i][j-1]), .i_south(n[i][j+1]), .i_east(w[i+1][j]), .i_west(verge),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
		end 
		else if(i==`MESH_WIDTH-1) begin
			if(j==0)
				conv_cell c_ne(	.ck(ck),.res(res),
						.i_north(verge), .i_south(n[i][j+1]), .i_east(verge), .i_west(e[i-1][j]),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
			else if(j==`MESH_HEIGHT-1)
				conv_cell c_se(	.ck(ck),.res(res),
						.i_north(s[i][j-1]), .i_south(verge), .i_east(verge), .i_west(e[i-1][j]),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
			else
				conv_cell c_e(	.ck(ck),.res(res),
						.i_north(s[i][j-1]), .i_south(n[i][j+1]), .i_east(verge), .i_west(e[i-1][j]),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
		end
		else begin
			if(j==0)
				conv_cell c_n(	.ck(ck),.res(res),
						.i_north(verge), .i_south(n[i][j+1]), .i_east(w[i+1][j]), .i_west(e[i-1][j]),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
			else if(j==`MESH_HEIGHT-1)
				conv_cell c_s(	.ck(ck),.res(res),
						.i_north(s[i][j-1]), .i_south(verge), .i_east(w[i+1][j]), .i_west(e[i-1][j]),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
			else
				conv_cell c_mid(	.ck(ck),.res(res),
						.i_north(s[i][j-1]), .i_south(n[i][j+1]), .i_east(w[i+1][j]), .i_west(e[i-1][j]),
						.o_north(n[i][j]), .o_south(s[i][j]), .o_east(e[i][j]), .o_west(w[i][j]));
		end
	end
end
endgenerate

endmodule
