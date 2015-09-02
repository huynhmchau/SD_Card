module init_block(
	input input_clk, //250kHz clock
	input input_clk_inv,
	input MISO_bit,
   input resend,
	output reg CS_bit,
	output reg MOSI_bit,
	output reg [15:0] response,
	output reg test_out
);

localparam WAIT_74_CYCLE = 0, SEND_CMD0 = 1, READ_CMD0_RESP = 2, SEND_CMD8 = 3, READ_CMD8_RESP = 4, END = 5;

localparam CMD0 = 48'h400000000095, CMD8 = 48'h48000001AA87;

reg[2:0] state = 0, next_state = 0;
reg[15:0] clock_counter = 0;
reg[47:0] MOSI = 0;
reg[15:0] recv_data = 0;
reg activator = 0;

//assign response = recv_data;

always@(posedge input_clk or negedge resend)begin
	if(resend == 0) begin
		clock_counter <= 80;
		response <= 16'd0;
		test_out = 0;
	end
	else begin
		
		state <= next_state;
		clock_counter <= clock_counter + 1;
		if(clock_counter < 243) begin
			activator <= 1;
			response <= recv_data;
			if(clock_counter > 136 && response[7:0] == 8'b00000001)begin
				test_out = 1;
				//clock_counter <= 80;
			end
		end
		else activator <= 0;
	end
end

always@(state)begin
	case(state)
		WAIT_74_CYCLE:begin
			if(clock_counter == 80)begin
				next_state = SEND_CMD0;
			end
			else begin
				next_state = WAIT_74_CYCLE;
			end
		end
		
		SEND_CMD0:begin
			if(clock_counter > 80 && clock_counter < 128)begin
				next_state = SEND_CMD0;
			end
			else begin //clock_counter == 128
				next_state = READ_CMD0_RESP;
			end
		end	
		
		READ_CMD0_RESP:begin
			if(clock_counter > 128 && clock_counter < 145)begin
//				if(clock_counter == 145 && response[7:0] != 8'b00000001)begin
//					next_state = SEND_CMD0;	//Resend CMD0
//				end
//				else begin
//					next_state = READ_RESP;
//				end
				next_state = READ_CMD0_RESP;
			end
			else begin //clock_counter == 145
				next_state = SEND_CMD8;
			end
		end
		
		SEND_CMD8:begin
			if(clock_counter > 145 && clock_counter < 193)begin
				next_state = SEND_CMD8;
			end
			else begin //clock_counter == 193
				next_state = READ_CMD8_RESP;
			end
		end
		
		READ_CMD8_RESP:begin
			if(clock_counter > 193 && clock_counter < 242)begin
				next_state = READ_CMD8_RESP;
			end
			else begin //clock_counter == 242
				next_state = END;
			end
		end
		
		END:begin end
		default:begin end
	endcase
end

always @(posedge input_clk_inv)begin
	if(activator == 1)begin
		case(state)
			WAIT_74_CYCLE:begin
				CS_bit <= 1;
				MOSI_bit <= 1;
				MOSI <= CMD0; //assign MOSI reg with CMD0
			end
			
			SEND_CMD0:begin
				CS_bit <= 0;
				MOSI_bit <= MOSI[47];
				MOSI = MOSI << 1;
			end	
			
			READ_CMD0_RESP:begin
				CS_bit <= 0;
				MOSI_bit <= 1;
				MOSI <= CMD8; //assign MOSI reg with CMD8
				recv_data <= {recv_data[14:0], MISO_bit}; 
			end
			
			SEND_CMD8:begin
				CS_bit <= 0;
				MOSI_bit <= MOSI[47];
				MOSI = MOSI << 1;
			end
			
			READ_CMD8_RESP:begin
				CS_bit <= 0;
				MOSI_bit <= 1;
				MOSI <= CMD8; //reassign MOSI reg with CMD8
				recv_data <= {recv_data[14:0], MISO_bit}; 
			end
			
			END:begin end
			default:begin end
		endcase
	end
	else begin
		CS_bit <= 1;
		MOSI_bit <= 0;
		recv_data <= 16'h0;
	end
end

endmodule
