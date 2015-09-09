module sd_interface(
	input input_slow_clk, //250kHz clock
	input MISO_bit, //Input from SD bit
	output CS_bit, //Chip select bit
	output MOSI_bit, //Output bit
	output out_250k_clk, //SD_CLK
	output [15:0] response_LED //Resposne from SD, output to LED
);

wire clk_invert;

init_block init(input_slow_clk, clk_invert, MISO_bit, CS_bit, MOSI_bit, response_LED);

assign clk_invert = ~input_slow_clk;
assign out_250k_clk = input_slow_clk;

endmodule
