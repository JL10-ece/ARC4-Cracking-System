module task1(
    input  logic CLOCK_50,
    input  logic [3:0] KEY,
    input  logic [9:0] SW,

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output logic [9:0] LEDR
);

    // internal signals
    logic [7:0] addr_w, wrdata_w;
    logic       wren_w;
    logic       en_w;
    logic       rdy_w;

    // memory output (internal wire)
    logic [7:0] mem_q;

    //-----------------------------------------------------------------
    // s_mem instance (single-ported RAM / ROM)
    // map its q output to mem_q, not directly to LEDR to avoid multiple drivers
    //-----------------------------------------------------------------
    s_mem s (
        .address (addr_w),
        .clock   (CLOCK_50),
        .data    (wrdata_w),
        .wren    (wren_w),
        .q       (mem_q)
    );

    //-----------------------------------------------------------------
    // init instance
    //-----------------------------------------------------------------
    init pop (
        .clk    (CLOCK_50),
        .rst_n  (KEY[3]),   // active-low reset
        .en     (en_w),
        .rdy    (rdy_w),
        .addr   (addr_w),
        .wrdata (wrdata_w),
        .wren   (wren_w)
    );

    //-----------------------------------------------------------------
    // en_w: hold low during reset, set high after reset released
    // (you can change this to a button start if you prefer)
    //-----------------------------------------------------------------
    always_ff @(posedge CLOCK_50 or negedge KEY[3]) begin
        if (!KEY[3])
            en_w <= 1'b0;
        else
            en_w <= 1'b1;
    end

    //-----------------------------------------------------------------
    // Drive all LEDR bits from one sequential block (no multiple drivers)
    // LEDR[9] = rdy (init done)
    // LEDR[8] = wren (write active)
    // LEDR[7:0] = contents of memory at address (mem_q)
    //-----------------------------------------------------------------
    always_ff @(posedge CLOCK_50) begin
        LEDR[9]   <= rdy_w;
        LEDR[8]   <= wren_w;
        LEDR[7:0] <= mem_q;
    end

    //-----------------------------------------------------------------
    // HEX display — show "init" when rdy_w = 1
    // 7-seg encodings used earlier:
    //  i : 7'b1111001
    //  n : 7'b0101011
    //  t : 7'b0000111
    // blank: 7'b1111111
    //-----------------------------------------------------------------
    always_comb begin
        if (rdy_w) begin
            HEX5 = 7'b1111001;   // i
            HEX4 = 7'b0101011;   // n
            HEX3 = 7'b1111001;   // i
            HEX2 = 7'b0000111;   // t
            HEX1 = 7'b1111111;   // blank
            HEX0 = 7'b1111111;   // blank
        end
        else begin
            HEX5 = 7'b1111111;
            HEX4 = 7'b1111111;
            HEX3 = 7'b1111111;
            HEX2 = 7'b1111111;
            HEX1 = 7'b1111111;
            HEX0 = 7'b1111111;
        end
    end

endmodule : task1
