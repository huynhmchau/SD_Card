module sd_controller(
	input	CLOCK_50,	//	50 MHz
	input	sd_clk_in,
	input start_btn,
	input resend_btn,
	input[15:0] response_signal,
	output reg gate_signal
);

wire[1:0]clk_250k_edge;

edge_detect edged(CLOCK_50, sd_clk_in, clk_250k_edge[1:0]);

localparam WAIT = 0, EDGE_DETECT = 1;

reg state, next_state;
reg[15:0] edge_counter;

always @(posedge CLOCK_50)begin
	if(start_btn == 0)begin
		state <= next_state;
		if(state == EDGE_DETECT) edge_counter <= edge_counter + 1;
		if(edge_counter > 130 && response_signal[7:0] == 8'b00000001) gate_signal <= 0;
		//if(edge_counter > 145) gate_signal <= 0;
		else gate_signal <= 1;
	end
	else if(resend_btn == 0) edge_counter <= 80;
	else begin end
end

always @(state)begin
	case(state)
		WAIT:begin
			if(clk_250k_edge == 2'b10) next_state = EDGE_DETECT;
			else next_state = WAIT;
		end
		
		EDGE_DETECT:begin
			if(clk_250k_edge != 2'b10) next_state = WAIT;
			else next_state = EDGE_DETECT;
		end
	endcase
end

endmodule