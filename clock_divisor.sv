module clock_divisor(
	input clk_50,
	output reg clk_250k
);

reg [15:0] count_update;

parameter count_250kHz = 200; //250kHz clock

always @(posedge clk_50)begin
	if(count_update == count_250kHz)begin
		count_update = 0;
		clk_250k = ~clk_250k;
	end
	else count_update = count_update + 1;
end 

endmodule