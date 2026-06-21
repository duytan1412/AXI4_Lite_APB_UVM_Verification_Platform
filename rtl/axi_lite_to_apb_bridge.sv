`timescale 1ns/1ps

module axi_lite_to_apb_bridge #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input  logic                  aclk,
    input  logic                  aresetn,

    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic                  s_axi_awvalid,
    output logic                  s_axi_awready,
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                  s_axi_wvalid,
    output logic                  s_axi_wready,
    output logic [1:0]            s_axi_bresp,
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready,

    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    output logic                  s_axi_rvalid,
    input  logic                  s_axi_rready,

    output logic [ADDR_WIDTH-1:0] paddr,
    output logic                  psel,
    output logic                  penable,
    output logic                  pwrite,
    output logic [DATA_WIDTH-1:0] pwdata,
    output logic [DATA_WIDTH/8-1:0] pstrb,
    input  logic [DATA_WIDTH-1:0] prdata,
    input  logic                  pready,
    input  logic                  pslverr
);

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_WRITE_SETUP,
        ST_WRITE_ACCESS,
        ST_WRITE_RESP,
        ST_READ_SETUP,
        ST_READ_ACCESS,
        ST_READ_RESP
    } state_t;

    state_t state_q, state_d;
    logic [ADDR_WIDTH-1:0] addr_q, addr_d;
    logic [DATA_WIDTH-1:0] wdata_q, wdata_d;
    logic [DATA_WIDTH/8-1:0] wstrb_q, wstrb_d;
    logic [DATA_WIDTH-1:0] rdata_q, rdata_d;
    logic slverr_q, slverr_d;

    always_comb begin
        state_d = state_q;
        addr_d = addr_q;
        wdata_d = wdata_q;
        wstrb_d = wstrb_q;
        rdata_d = rdata_q;
        slverr_d = slverr_q;

        s_axi_awready = 1'b0;
        s_axi_wready  = 1'b0;
        s_axi_bvalid  = 1'b0;
        s_axi_bresp   = slverr_q ? 2'b10 : 2'b00;
        s_axi_arready = 1'b0;
        s_axi_rvalid  = 1'b0;
        s_axi_rdata   = rdata_q;
        s_axi_rresp   = slverr_q ? 2'b10 : 2'b00;

        paddr   = addr_q;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pwdata  = wdata_q;
        pstrb   = wstrb_q;

        unique case (state_q)
            ST_IDLE: begin
                if (s_axi_awvalid && s_axi_wvalid) begin
                    s_axi_awready = 1'b1;
                    s_axi_wready  = 1'b1;
                    addr_d = s_axi_awaddr;
                    wdata_d = s_axi_wdata;
                    wstrb_d = s_axi_wstrb;
                    slverr_d = 1'b0;
                    state_d = ST_WRITE_SETUP;
                end else if (s_axi_arvalid) begin
                    s_axi_arready = 1'b1;
                    addr_d = s_axi_araddr;
                    slverr_d = 1'b0;
                    state_d = ST_READ_SETUP;
                end
            end

            ST_WRITE_SETUP: begin
                psel = 1'b1;
                pwrite = 1'b1;
                state_d = ST_WRITE_ACCESS;
            end

            ST_WRITE_ACCESS: begin
                psel = 1'b1;
                penable = 1'b1;
                pwrite = 1'b1;
                if (pready) begin
                    slverr_d = pslverr;
                    state_d = ST_WRITE_RESP;
                end
            end

            ST_WRITE_RESP: begin
                s_axi_bvalid = 1'b1;
                if (s_axi_bready) begin
                    state_d = ST_IDLE;
                end
            end

            ST_READ_SETUP: begin
                psel = 1'b1;
                state_d = ST_READ_ACCESS;
            end

            ST_READ_ACCESS: begin
                psel = 1'b1;
                penable = 1'b1;
                if (pready) begin
                    rdata_d = prdata;
                    slverr_d = pslverr;
                    state_d = ST_READ_RESP;
                end
            end

            ST_READ_RESP: begin
                s_axi_rvalid = 1'b1;
                if (s_axi_rready) begin
                    state_d = ST_IDLE;
                end
            end

            default: state_d = ST_IDLE;
        endcase
    end

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state_q <= ST_IDLE;
            addr_q <= '0;
            wdata_q <= '0;
            wstrb_q <= '0;
            rdata_q <= '0;
            slverr_q <= 1'b0;
        end else begin
            state_q <= state_d;
            addr_q <= addr_d;
            wdata_q <= wdata_d;
            wstrb_q <= wstrb_d;
            rdata_q <= rdata_d;
            slverr_q <= slverr_d;
        end
    end

`ifdef FORMAL_OR_SIM_ASSERT
    always_ff @(posedge aclk) begin
        if (aresetn) begin
            if (psel && !penable) begin
                assert ($stable(paddr));
            end
            if (s_axi_bvalid) begin
                assert (s_axi_bresp inside {2'b00, 2'b10});
            end
            if (s_axi_rvalid) begin
                assert (s_axi_rresp inside {2'b00, 2'b10});
            end
        end
    end
`endif

endmodule
