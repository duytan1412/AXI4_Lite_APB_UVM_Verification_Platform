`timescale 1ns/1ps

interface axi4_lite_if #(parameter int ADDR_WIDTH = 8, parameter int DATA_WIDTH = 32) (input logic aclk, input logic aresetn);
    logic [ADDR_WIDTH-1:0] awaddr;
    logic awvalid;
    logic awready;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic wvalid;
    logic wready;
    logic [1:0] bresp;
    logic bvalid;
    logic bready;
    logic [ADDR_WIDTH-1:0] araddr;
    logic arvalid;
    logic arready;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
    logic rvalid;
    logic rready;

`ifdef FORMAL_OR_SIM_ASSERT
    always_ff @(posedge aclk) begin
        if (aresetn) begin
            if (awvalid && !awready) assert ($stable(awaddr));
            if (wvalid && !wready) assert ($stable(wdata));
            if (arvalid && !arready) assert ($stable(araddr));
            if (bvalid) assert (bresp inside {2'b00, 2'b10});
            if (rvalid) assert (rresp inside {2'b00, 2'b10});
        end
    end
`endif
endinterface
