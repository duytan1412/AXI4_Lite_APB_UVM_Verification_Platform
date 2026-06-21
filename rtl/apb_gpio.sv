`timescale 1ns/1ps

module apb_gpio #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input  logic                  pclk,
    input  logic                  presetn,
    input  logic [ADDR_WIDTH-1:0] paddr,
    input  logic                  psel,
    input  logic                  penable,
    input  logic                  pwrite,
    input  logic [DATA_WIDTH-1:0] pwdata,
    input  logic [DATA_WIDTH/8-1:0] pstrb,
    output logic [DATA_WIDTH-1:0] prdata,
    output logic                  pready,
    output logic                  pslverr,
    output logic [DATA_WIDTH-1:0] gpio_data,
    output logic [DATA_WIDTH-1:0] gpio_dir
);

    localparam logic [7:0] ADDR_DATA = 8'h00;
    localparam logic [7:0] ADDR_DIR  = 8'h04;
    localparam logic [7:0] ADDR_SET  = 8'h08;
    localparam logic [7:0] ADDR_CLR  = 8'h0c;

    logic transfer;
    assign transfer = psel && penable;
    assign pready = 1'b1;

    always_comb begin
        prdata = '0;
        pslverr = 1'b0;
        unique case (paddr[7:0])
            ADDR_DATA: prdata = gpio_data;
            ADDR_DIR:  prdata = gpio_dir;
            ADDR_SET:  prdata = '0;
            ADDR_CLR:  prdata = '0;
            default: begin
                prdata = '0;
                pslverr = transfer;
            end
        endcase
    end

    always_ff @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            gpio_data <= '0;
            gpio_dir <= '0;
        end else if (transfer && pwrite && !pslverr) begin
            unique case (paddr[7:0])
                ADDR_DATA: gpio_data <= apply_wstrb(gpio_data, pwdata, pstrb);
                ADDR_DIR:  gpio_dir  <= apply_wstrb(gpio_dir, pwdata, pstrb);
                ADDR_SET:  gpio_data <= gpio_data | pwdata;
                ADDR_CLR:  gpio_data <= gpio_data & ~pwdata;
                default: begin end
            endcase
        end
    end

    function automatic logic [DATA_WIDTH-1:0] apply_wstrb(
        input logic [DATA_WIDTH-1:0] old_value,
        input logic [DATA_WIDTH-1:0] new_value,
        input logic [DATA_WIDTH/8-1:0] strobe
    );
        logic [DATA_WIDTH-1:0] merged;
        merged = old_value;
        for (int byte_idx = 0; byte_idx < DATA_WIDTH/8; byte_idx++) begin
            if (strobe[byte_idx]) begin
                merged[byte_idx*8 +: 8] = new_value[byte_idx*8 +: 8];
            end
        end
        return merged;
    endfunction

endmodule
