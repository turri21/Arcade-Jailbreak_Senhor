/******************************************************
	FPGA Implimentation of "Green Beret" (Main Part)
*******************************************************/
// Copyright (c) 2013,19 MiSTer-X

module MAIN
(
	input				CPUCL,
	input				RESET,

	input   [8:0]	PH,
	input   [8:0]	PV,

	input   [5:0]	INP0,
	input   [5:0]	INP1,
	input   [3:0]	INP2,

	input	  [7:0]	DSW0,
	input	  [7:0]	DSW1,
	input	  [7:0]	DSW2,

	output          CPUMX,
	output   [15:0]	CPUAD,
	output          CPUWR,
	output    [7:0] CPUWD,

	input				VIDDV,
	input   [7:0]	VIDRD,
	input           vlm_busy,

	input				DLCL,
	input  [17:0]  DLAD,
	input   [7:0]	DLDT,
	input				DLEN,

	input   [3:0] title,
	input         pause
);

//
// CPU (KONAMI-1) - encrypted mc6809
//
wire [7:0] CPUID;
wire cpu_irq, cpu_nmi;

reg [4:0] clkdiv;
always @(posedge CPUCL)
	clkdiv <= clkdiv+1;

wire cpu_clk = ~clkdiv[0];

wire [7:0] ROMOP;
wire [7:0] ROMDT;
wire   ROMDV;
wire   CPURnW;
assign CPUWR = ~CPURnW;

CPU_ROM prog_rom(CPUCL,CPUAD,CPUMX, ROMDV,ROMOP,ROMDT, DLCL,DLAD,DLDT,DLEN);

cpu09 konami1(
	.clk(cpu_clk),
	.rst(RESET),
	.rw(CPURnW),
	.vma(CPUMX),
	.address(CPUAD),
	.opc_in(ROMOP),
	.data_in(CPUID),
	.data_out(CPUWD),
	.halt(1'b0),
	.hold(pause),
	.irq(cpu_irq),
	.firq(1'b0),
	.nmi(cpu_nmi)
);

//
// Input Ports (HID & DIPSWs)
//
wire CS_ISYS = (CPUAD[15:0] == 16'h3300) & CPUMX;
wire CS_IP01 = (CPUAD[15:0] == 16'h3301) & CPUMX;
wire CS_IP02 = (CPUAD[15:0] == 16'h3302) & CPUMX;
wire CS_DSW2 = (CPUAD[15:0] == 16'h3303) & CPUMX;
wire CS_DSW1 = (CPUAD[15:8] ==  8'h32  ) & CPUMX;
wire CS_DSW0 = (CPUAD[15:8] ==  8'h31  ) & CPUMX;
wire cs_vlm  = (CPUAD[15:0] == 16'h6000) & CPUMX;

`include "HIDDEF.i"
wire [7:0]	ISYS = ~{`none,`none,`none,`P2ST,`P1ST,`none,`COIN2,`COIN1};
wire [7:0]	IP01 = ~{`none,`none,`P1TB,`P1TA,`P1DW,`P1UP,`P1RG,`P1LF};
wire [7:0]	IP02 = ~{`none,`none,`P2TB,`P2TA,`P2DW,`P2UP,`P2RG,`P2LF};

//
// CPU Input Data Selector
//
DSEL10 dsel(
	CPUID,
	VIDDV,VIDRD,
	ROMDV,ROMDT,
	CS_ISYS,ISYS,
	CS_IP01,IP01,
	CS_IP02,IP02,
	CS_DSW0,DSW0,
	CS_DSW1,DSW1,
	CS_DSW2,DSW2,
	cs_vlm,{7'h0,vlm_busy}
);


//
// Interrupt Generator & ROM Bank Selector
//
IRQGEN irqg(
	RESET,PH,PV,
	CPUCL,CPUAD,CPUWD,CPUMX & CPUWR,
	cpu_irq,cpu_nmi,
	title
);


endmodule


module IRQGEN
(
	input 			RESET,
	input  [8:0]  PH,
	input  [8:0]  PV,

	input         CPUCL,
	input [15:0]  CPUAD,
	input  [7:0]  CPUWD,
	input				CPUWE,

	output reg	cpu_irq,
	output reg	cpu_nmi,

	input   [7:0] title
);

wire CS_FSCW = (CPUAD[15:0] == 16'h2044) & CPUWE;
wire CS_CCTW = (CPUAD[15:0] == 16'h3000) & CPUWE;

reg  [2:0] irqmask;
reg  [8:0] tick;
wire [8:0] irqs = (~tick) & (tick+9'd1);
reg  [8:0] pPV;
reg        sync;
wire [8:0] tick_init;

always @( negedge CPUCL ) begin
	if (RESET) begin
		irqmask <= 0;
		cpu_nmi <= 0;
		cpu_irq <= 0;
		tick    <= 0;
		pPV     <= 1;
		sync    <= 1;
	end
	else begin
		if (CS_FSCW) begin
			irqmask <= CPUWD[1:0];
			if (~CPUWD[0]) cpu_nmi <= 0;
			else if (~CPUWD[1]) cpu_irq <= 0;
		end
		else if (pPV != PV) begin
			if (PV[3:0]==0) begin
				// tick reset value value 9 to mitigate tearing
				if (sync & (PV==9'd0)) begin tick <= 9; sync <= 0; end
				else
					tick <= (tick+9'd1);
				cpu_nmi <= irqs[0] & irqmask[0];
				cpu_irq <= irqs[3] & irqmask[1];
				pPV <= PV;
			end
		end
	end
end

endmodule


module DSEL10
(
	output [7:0] out,
	input en0, input [7:0] in0,
	input en1, input [7:0] in1,
	input en2, input [7:0] in2,
	input en3, input [7:0] in3,
	input en4, input [7:0] in4,
	input en5, input [7:0] in5,
	input en6, input [7:0] in6,
	input en7, input [7:0] in7,
	input en8, input [7:0] in8,
	input en9, input [7:0] in9
);

assign out = en0 ? in0 :
				 en1 ? in1 :
				 en2 ? in2 :
				 en3 ? in3 :
				 en4 ? in4 :
				 en5 ? in5 :
				 en6 ? in6 :
				 en7 ? in7 :
				 en8 ? in8 :
				 en9 ? in9 :
				 8'h00;

endmodule

