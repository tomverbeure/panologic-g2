
module Audio_test (
    input wire  clk12,
    input wire  reset12_,

    output wire codec_mclk,
    output wire codec_bclk,
    output reg  codec_dacdat,
    output reg  codec_daclrc,
    input  wire codec_adcdat,
    output reg  codec_adclrc
    );

//    // DSP Mode, mode B, LRP=0, Slave (Figure 23), 16 bits
//    { WM8750_codec_INTFC_ADDR,          (0<<7) |    // BCLKINV: BCLK not inverted
//                                        (1<<6) |    // MS     : Master mode
//                                        (0<<5) |    // LRSWAP : No L/R swap
//                                        (1<<4) |    // LRP    : DSP mode B: MSB on first clock cycle
//                                        (0<<2) |    // WL     : 16 bits
//                                        (3<<0) },   // FORMAT : DSP mode
//

    // In USB mode, BCLK = MCLK

    ODDR2 MCLK_OBUF (
        .D0(1'b1),
        .D1(1'b0),
        .C0(clk12),
        .C1(!clk12),
        .CE(1'b1),
        .Q(codec_mclk)
    );

    ODDR2 BCLK_OBUF (
        .D0(1'b1),
        .D1(1'b0),
        .C0(clk12),
        .C1(!clk12),
        .CE(1'b1),
        .Q(codec_bclk)
    );

    reg signed [15:0] sample_left, sample_right;
    reg [31:0] sample;
    reg [8:0]  bit_cntr, bit_cntr_nxt;
    reg [15:0] phase_cntr, phase_cntr_nxt;
    reg codec_daclrc_nxt, codec_dacdat_nxt;
    reg codec_adclrc_nxt;

    localparam max_bit_cntr = 12000/48;     // 48KHz
    
    always @*
    begin
        bit_cntr_nxt    = bit_cntr;
        phase_cntr_nxt  = phase_cntr;

        if (bit_cntr_nxt == max_bit_cntr-1) begin
            bit_cntr_nxt    = 0;
            
            if (phase_cntr == 47) begin         // 1KHz test tone
                phase_cntr_nxt  = 0;
            end
            else begin
                phase_cntr_nxt  = phase_cntr + 1;
            end
        end
        else begin
            bit_cntr_nxt    = bit_cntr + 1;
        end

        codec_daclrc_nxt    = (bit_cntr == 0);
        codec_dacdat_nxt    = |bit_cntr[8:5] ? 1'b0 : sample[~bit_cntr[4:0]];

        codec_adclrc_nxt    = (bit_cntr == 0);
    end

    always @(posedge clk12) 
    begin
        bit_cntr        <= bit_cntr_nxt;
        phase_cntr      <= phase_cntr_nxt;
        codec_daclrc    <= codec_daclrc_nxt;
        codec_dacdat    <= codec_dacdat_nxt;
        codec_adclrc    <= codec_adclrc_nxt;

        if (!reset12_) begin
            bit_cntr        <= 0;
            phase_cntr      <= 0;
            codec_daclrc    <= 1'b0;
            codec_dacdat    <= 1'b0;
            codec_adclrc    <= 1'b0;
        end
    end

    always @*
    begin
        sample_left  = (phase_cntr < 24) ? -16'd8192 : 16'd8192;
        sample_right = (phase_cntr < 24) ? -16'd1024 : 16'd1024;
        sample = { sample_left, sample_right };
    end

endmodule

