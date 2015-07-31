module dvi_top(
	input SYSCLK,

	input PANO_BUTTON,

	inout V_SPD,
	output V_SPC,

	output [11:0] V1_D,
	output V1_XCLK_P,
	output V1_XCLK_N,
	output V1_HSYNC,
	output V1_VSYNC,
	output V1_DE,
	output V1_RESET_N
	);

	// Video timing parameters
	parameter X_RESOLUTION = 640;
	parameter X_FRONT_PORCH = 16;
	parameter X_SYNC_PULSE = 96;
	parameter X_BACK_PORCH = 48;
	parameter Y_RESOLUTION = 480;
	parameter Y_FRONT_PORCH = 12;
	parameter Y_SYNC_PULSE = 2;
	parameter Y_BACK_PORCH = 31;

	// Global reset signal
	wire reset_n = PANO_BUTTON;

	// Buffer I/O
	wire sysclk_ibuf;
	wire dcm_clk0;
	wire dcm_clk0_bufg;
	wire dcm_clk90;
	wire dcm_locked;

	// Buffers
	IBUFG IBUFG0(.I(SYSCLK), .O(sysclk_ibuf));
	BUFG BUFG0(.I(dcm_clk0), .O(dcm_clk0_bufg));

	// Clock generator
	DCM_SP #(
		.CLKDV_DIVIDE   (2.0),
		.CLKFX_MULTIPLY (2),
		.CLKFX_DIVIDE   (1),
		.CLKIN_PERIOD   (40.0)
	)
	dcm0 (
		.CLKIN    (sysclk_ibuf),
		.CLKFB    (dcm_clk0_bufg),
		.DSSEN    (1'b0),
		.PSINCDEC (1'b0),
		.PSEN     (1'b0),
		.PSCLK    (1'b0),
		.RST      (!reset_n),
		.CLK0     (dcm_clk0),
		.CLK90    (dcm_clk90),
		.CLK180   (),
		.CLK270   (),
		.CLK2X    (),
		.CLK2X180 (),
		.CLKDV    (),
		.CLKFX    (),
		.CLKFX180 (),
		.LOCKED   (dcm_locked),
		.PSDONE   ()
	);

	// Pixel clock output
	OBUFDS clkout_oddr_p(
		.I  (dcm_clk90),
		.O  (V1_XCLK_P),
		.OB (V1_XCLK_N)
	);

	// TODO: Implement I2C
	assign V_SPD = 1'b1;
	assign V_SPC = 1'b1;

	// Video signals
	reg [31:0] x_counter;
	reg [31:0] y_counter;
	assign V1_HSYNC = (x_counter < X_RESOLUTION + X_FRONT_PORCH) || (x_counter >= X_RESOLUTION + X_FRONT_PORCH + X_SYNC_PULSE);
	assign V1_VSYNC = (y_counter < Y_RESOLUTION + Y_FRONT_PORCH) || (y_counter >= Y_RESOLUTION + Y_FRONT_PORCH + Y_SYNC_PULSE);
	assign V1_DE = (x_counter < X_RESOLUTION) && (y_counter < Y_RESOLUTION);

	// Chrontel reset
	assign V1_RESET_N = reset_n && dcm_locked;

	// Static pixel data
	wire [7:0] pixel_red = 8'hff;
	wire [7:0] pixel_green = 8'hf0;
	wire [7:0] pixel_blue = 8'h0f;

	// Main block
	always @(posedge dcm_clk0) begin
		if (!reset_n || !dcm_locked) begin
			x_counter <= 0;
			y_counter <= 0;
		end else begin
			if (x_counter==X_RESOLUTION + X_FRONT_PORCH + X_SYNC_PULSE + X_BACK_PORCH - 1) begin
				x_counter <= 0;
				if (y_counter==Y_RESOLUTION + Y_FRONT_PORCH + Y_SYNC_PULSE + Y_BACK_PORCH - 1)
					y_counter <= 0;
				else
					y_counter <= y_counter + 1;
			end else begin
				x_counter <= x_counter + 1;
			end
		end
	end

	// Pixel data DDR blocks
	ODDR2 v1_d_11(
		.Q  (V1_D[11]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_green[3]),
		.D1 (pixel_red[7]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_10(
		.Q  (V1_D[10]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_green[2]),
		.D1 (pixel_red[6]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_9(
		.Q  (V1_D[9]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_green[1]),
		.D1 (pixel_red[5]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_8(
		.Q  (V1_D[8]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_green[0]),
		.D1 (pixel_red[4]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_7(
		.Q  (V1_D[7]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[7]),
		.D1 (pixel_red[3]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_6(
		.Q  (V1_D[6]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[6]),
		.D1 (pixel_red[2]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_5(
		.Q  (V1_D[5]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[5]),
		.D1 (pixel_red[1]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_4(
		.Q  (V1_D[4]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[4]),
		.D1 (pixel_red[0]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_3(
		.Q  (V1_D[3]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[3]),
		.D1 (pixel_green[7]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_2(
		.Q  (V1_D[2]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[2]),
		.D1 (pixel_green[6]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_1(
		.Q  (V1_D[1]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[1]),
		.D1 (pixel_green[5]),
		.R  (1'b0),
		.S  (1'b0)
	);
	ODDR2 v1_d_0(
		.Q  (V1_D[0]),
		.C0 (dcm_clk0),
		.C1 (!dcm_clk0),
		.CE (1'b1),
		.D0 (pixel_blue[0]),
		.D1 (pixel_green[4]),
		.R  (1'b0),
		.S  (1'b0)
	);
endmodule
