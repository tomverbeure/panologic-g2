module top(
	input SYSCLK,
	output LED_RED,
	output LED_BLUE,
	output LED_GREEN
	);

	reg [2:0] led_reg;
	reg [32:0] counter;

	assign LED_RED = led_reg[0];
	assign LED_BLUE = led_reg[1];
	assign LED_GREEN = led_reg[2];

	always @(posedge SYSCLK) begin
		if (counter < 25000000)
			counter <= counter + 1;
		else begin
			counter <= 0;
			led_reg <= led_reg + 1;
		end
	end
endmodule
