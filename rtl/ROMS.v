// Copyright (c) 2019 MiSTer-X

module DLROM #(parameter AW,parameter DW)
(
	input							CL0,
	input [(AW-1):0]			AD0,
	output reg [(DW-1):0]	DO0,

	input							CL1,
	input [(AW-1):0]			AD1,
	input	[(DW-1):0]			DI1,
	input							WE1
);

reg [(DW-1):0] core[0:((2**AW)-1)];

always @(posedge CL0) DO0 <= core[AD0];
always @(posedge CL1) if (WE1) core[AD1] <= DI1;

endmodule


module CPU_ROM
(
	input         CL,
	input  [15:0] AD,
	input         MX,

	output        DV,
	output  [7:0] OP,
	output  [7:0] DT,

	input         DLCL,
	input  [17:0] DLAD,
	input   [7:0] DLID,
	input         DLEN
);

wire [7:0] OD,DC;

assign DT = OD;
assign DC = {AD[1],1'b0,~AD[1],1'b0,AD[3],1'b0,~AD[3],1'b0};
assign OP = (OD^DC);
assign DV = (AD[15]==1'b1) & MX;

DLROM #(15,8) r(CL,AD[14:0],OD, DLCL,DLAD,DLID,DLEN & (DLAD[17:15]==2'b00_0));

endmodule



module SPCHIP_ROM
(
	input			 	CL,
	input [15:0] 	AD,
	output [7:0] 	DT,

	input				DLCL,
	input [17:0]	DLAD,
	input	 [7:0]	DLDT,
	input				DLEN
);
DLROM #(16,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:16]==2'b01));
endmodule


module BGCHIP_ROM
(
	input			 	CL,
	input [14:0] 	AD,
	output [7:0] 	DT,

	input				DLCL,
	input [17:0]	DLAD,
	input	 [7:0]	DLDT,
	input				DLEN
);
DLROM #(15,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:15]==4'b10_0));
endmodule


module SPCLUT_ROM
(
	input				CL,
	input  [7:0]	AD,
	output [7:0]	DT,

	input				DLCL,
	input [17:0]	DLAD,
	input	 [7:0]	DLDT,
	input				DLEN
);
DLROM #(8,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:8]==10'b10_1000_0000));
endmodule


module BGCLUT_ROM
(
	input				CL,
	input  [7:0]	AD,
	output [7:0]	DT,

	input				DLCL,
	input [17:0]	DLAD,
	input	 [7:0]	DLDT,
	input				DLEN
);
DLROM #(8,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:8]==10'b10_1000_0001));
endmodule


module PALET_ROM
(
	input				CL,
	input  [5:0]	AD,
	output [7:0]	DT,

	input				DLCL,
	input [17:0]	DLAD,
	input	 [7:0]	DLDT,
	input				DLEN,
	input  hi
);
DLROM #(5,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:5]=={13'b10_1000_0010_00,hi}));
endmodule

