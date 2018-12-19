`timescale 1ps/1ps

module conv_sim;
reg ck;
reg res;

parameter STEP = 1000;

conv_mesh MESH(.ck(ck),.res(res));

// clock generation
always #(STEP/2) ck = ~ck;

// test input
initial begin
	ck=1; res=1;
	#STEP res=0;
	#STEP res=1;
	#(STEP*64) $stop;
end

// display
always #STEP $display(" %d ck=%b res=%b \t north[4][4]=%d south[4][4]=%d west[4][4]=%d east[4][4]=%d \n\t\t\t    north[5][4]=%d south[5][4]=%d west[5][4]=%d east[5][4]=%d",
			$stime/STEP, ck, res,
			MESH.n[6][6], MESH.s[6][6], MESH.w[6][6], MESH.e[6][6],
			MESH.n[7][6], MESH.s[7][6], MESH.w[7][6], MESH.e[7][6]
);


// monitor
//initial $monitor(" %d ck=%b res=%b north[0][0]=%d south[0][0]=%d west[0][0]=%d east[0][0]=%d \n\t\t north[1][0]=%d south[1][0]=%d west[1][0]=%d east[1][0]=%d",
//			$stime/STEP, ck, res,
//			MESH.n[4][4], MESH.s[4][4], MESH.w[4][4], MESH.e[4][4],
//		MESH.n[5][4], MESH.s[5][4], MESH.w[5][4], MESH.e[5][4]
//);

endmodule
