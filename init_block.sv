module init_block(
	input input_clk, //250kHz clock
	input input_clk_inv, //Inverted 250kHz clock, for preparing data
	input MISO_bit, //Input from SD bit
	output reg CS_bit, //Chip select bit
	output reg MOSI_bit, //Output bit
	output reg [15:0] response //Resposne from SD, output to LED
);

localparam WAIT_74_CYCLE = 0, SEND_CMD0 = 1, READ_CMD0_RESP = 2, SEND_CMD8 = 3, READ_CMD8_RESP = 4, 
			  SEND_CMD55 = 5, READ_CMD55_RESP = 6, SEND_CMD41 = 7, READ_ACMD41_RESP = 8, END = 9;

localparam CMD0 = 48'h400000000095, CMD8 = 48'h48000001AA87, CMD55 = 48'h7700000000FF, CMD41 = 48'h6940000000FF;

reg[3:0] state = 0, next_state = 0;
reg[15:0] clock_counter = 0;
reg[47:0] MOSI = 0;
reg[15:0] recv_data = 0;
reg activator = 0;


always@(posedge input_clk)begin
	state <= next_state;
	if(clock_counter == 372 && response[7:0] != 8'b00000000)begin
		clock_counter <= 243;
	end
	else begin
		clock_counter <= clock_counter + 1;
	end
	if(clock_counter < 373) begin
		activator <= 1;
		response <= recv_data;
	end
	else activator <= 0;
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
				next_state = SEND_CMD55;
			end
		end
		
		SEND_CMD55:begin
			if(clock_counter > 242 && clock_counter < 290)begin
				next_state = SEND_CMD55;
			end
			else begin //clock_counter == 290
				next_state = READ_CMD55_RESP;
			end
		end
		
		READ_CMD55_RESP:begin
			if(clock_counter > 290 && clock_counter < 307)begin
				next_state = READ_CMD55_RESP;
			end
			else begin //clock_counter == 307
				next_state = SEND_CMD41;
			end
		end
		
		SEND_CMD41:begin
			if(clock_counter > 307 && clock_counter < 355)begin
				next_state = SEND_CMD41;
			end
			else begin //clock_counter == 355
				next_state = READ_ACMD41_RESP;
			end
		end
		
		READ_ACMD41_RESP:begin
			if(clock_counter > 355 && clock_counter < 372)begin
				next_state = READ_ACMD41_RESP;
			end
			else begin //clock_counter == 372
				if(response[7:0] != 8'b00000000) begin
					next_state = SEND_CMD55;
				end
				else begin
					next_state = END;
				end
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
				MOSI <= CMD55; //reassign MOSI reg with CMD55
				recv_data <= {recv_data[14:0], MISO_bit}; 
			end
			
			SEND_CMD55:begin
				CS_bit <= 0;
				MOSI_bit <= MOSI[47];
				MOSI = MOSI << 1;
			end
			
			READ_CMD55_RESP:begin
				CS_bit <= 0;
				MOSI_bit <= 1;
				MOSI <= CMD41; //assign MOSI reg with CMD41
				recv_data <= {recv_data[14:0], MISO_bit};
			end
			
			SEND_CMD41:begin
				CS_bit <= 0;
				MOSI_bit <= MOSI[47];
				MOSI = MOSI << 1;
			end
			
			READ_ACMD41_RESP:begin
				CS_bit <= 0;
				MOSI_bit <= 1;
				MOSI <= CMD55; //reassign MOSI reg with CMD55
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
