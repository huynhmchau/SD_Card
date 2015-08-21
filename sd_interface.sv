module sd_interface(
	input input_slow_clk,
	input MISO_bit,
   input resend,
	output CS_bit,
	output MOSI_bit,
	output out_250k_clk,
	output [15:0] response_LED
);

wire clk_invert;

init_block init(input_slow_clk, clk_invert, MISO_bit, resend, CS_bit, MOSI_bit, response_LED);

assign clk_invert = ~input_slow_clk;
assign out_250k_clk = input_slow_clk;

endmodule
