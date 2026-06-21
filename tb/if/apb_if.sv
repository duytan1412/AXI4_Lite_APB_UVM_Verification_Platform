`timescale 1ns/1ps

interface apb_if #(parameter int ADDR_WIDTH = 8, parameter int DATA_WIDTH = 32) (input logic pclk, input logic presetn);
    logic [ADDR_WIDTH-1:0] paddr;
    logic psel;
    logic penable;
    logic pwrite;
    logic [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH/8-1:0] pstrb;
    logic [DATA_WIDTH-1:0] prdata;
    logic pready;
    logic pslverr;

`ifdef FORMAL_OR_SIM_ASSERT
    always_ff @(posedge pclk) begin
        if (presetn) begin
            if (penable) assert (psel);
            if (psel && !penable) assert ($stable(paddr));
        end
    end
`endif
endinterface
