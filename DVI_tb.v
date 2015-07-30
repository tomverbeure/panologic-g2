`timescale 10 ns/1 ps

module test;
	reg tb_clk;
	reg tb_button;

	wire tb_spd;
	wire tb_spc;

	wire [11:0] tb_d;
	wire tb_xclk_p;
	wire tb_xclk_n;
	wire tb_hsync;
	wire tb_vsync;
	wire tb_de;
	wire tb_reset_n;

	parameter CLK_HALF_PERIOD = 2;
	parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;

	dvi_top DUT(
		.SYSCLK(tb_clk),
		.PANO_BUTTON(tb_button),

		.V_SPD(tb_spd),
		.V_SPC(tb_spc),

		.V1_D(tb_d),
		.V1_XCLK_P(tb_xclk_p),
		.V1_XCLK_N(tb_xclk_n),
		.V1_HSYNC(tb_hsync),
		.V1_VSYNC(tb_vsync),
		.V1_DE(tb_de),
		.V1_RESET_N(tb_reset_n)
	);

	always #CLK_HALF_PERIOD tb_clk = !tb_clk;

	task reset();
		begin
			tb_button <= 0;
			#(10 * CLK_PERIOD); // DCM_SP needs at least 3 clock periods
			tb_button <= 1;
		end
	endtask

	initial begin
		tb_clk <= 0;
		tb_button <= 1;

		#CLK_PERIOD;

		reset();

		#(640*480*5 * CLK_PERIOD);
	end

endmodule
