/********************************************************
	FPGA Implimentation of "Green Beret"  (Sound Part)
*********************************************************/
// Copyright (c) 2013 MiSTer-X
// Copyright (c) 2021 blackwine

module SOUND
(
	input				dacclk,
	input				reset,

	output  [7:0]	SNDOUT,

	input				CPUCL,
	input				CPUMX,
	input	 [15:0]	CPUAD,
	input				CPUWR,
	input	  [7:0]	CPUWD,
	output reg      vlm_busy,

	input				pause
);

//
// SN76496
//
wire CS_SNDLC = ( CPUAD[15:8] == 8'h31 ) & CPUMX & CPUWR;
wire CS_SNDWR = ( CPUAD[15:8] == 8'h32 ) & CPUMX;

reg [7:0] SNDLATCH;
always @( posedge CPUCL or posedge reset ) begin
	if (reset) SNDLATCH <= 0;
	else begin
		if ( CS_SNDLC ) SNDLATCH <= CPUWD;
	end
end

wire sndclk;
sndclkgen scgen( dacclk, sndclk );


wire [3:0] sndmask = pause ? 4'b0000 : 4'b1111;
SN76496 sgn( sndclk, CPUCL, reset, CS_SNDWR, CPUWR, SNDLATCH, sndmask, SNDOUT );

//
// VLM5030
//
// dummy def driver
//

wire cs_vlm_speech_write = (CPUAD[15:0] == 16'h4000) & CPUMX & CPUWR;
wire cs_vlm_data_write = (CPUAD[15:0] == 16'h5000) & CPUMX & CPUWR;
always @(posedge CPUCL or posedge reset) begin
	reg [15:0] tick;

	if (reset)
		vlm_busy <= 1'b0;
	else begin
		if (cs_vlm_speech_write)
			if(CPUWD&1)
				vlm_busy <= 1;
			else begin
				vlm_busy <= 0;
				tick <= 0;
			end
		if (vlm_busy)
			tick <= tick + 15'd1;
		if (tick == 16'hffff) begin
			vlm_busy <=0;
			tick <= 0;
		end
	end
end


endmodule


/*
   Clock Generator
     in: 50000000Hz -> out: 1600000Hz
*/
module sndclkgen( input in, output reg out );
reg [6:0] count;
always @( posedge in ) begin
        if (count > 7'd117) begin
                count <= count - 7'd117;
                out <= ~out;
        end
        else count <= count + 7'd8;
end
endmodule
