/*
	This code is tested using SanDisk Ultra 8GB SDHC and Altera DE2-115 FPGA board.
	Data blocks are fixed to 512 bytes due to SDHC card.
*/

module sd_card(
	input CLOCK_50, //50 MHz clock
	input [3:3] KEY,
	inout [3:0]SD_DAT, //SD_DAT[0] - MISO, SD_DAT[3] - CS
	output SD_CLK,	//SDCLK
	output SD_CMD,	//MOSI
	output[15:0] LEDR
);

wire sd_clk_wire, gate_sig_wire;
wire slow_clk, gated_50M;
wire [15:0] response_sig;

sd_controller sd_contr(CLOCK_50, SD_CLK, KEY[3], response_sig[15:0], gate_sig_wire);
and andgate(gated_50M, CLOCK_50, gate_sig_wire);
clock_divisor clk_div(gated_50M, slow_clk);
sd_interface sd_int(slow_clk, SD_DAT[0], SD_DAT[3], SD_CMD, SD_CLK, response_sig[15:0]);

assign LEDR[15:0] = response_sig[15:0];

endmodule
