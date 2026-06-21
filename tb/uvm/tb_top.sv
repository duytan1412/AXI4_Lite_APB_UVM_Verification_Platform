`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import bridge_uvm_pkg::*;

    logic clk;
    logic resetn;
    logic [31:0] gpio_data;
    logic [31:0] gpio_dir;

    axi4_lite_if axi_if(.aclk(clk), .aresetn(resetn));
    apb_if apb_bus(.pclk(clk), .presetn(resetn));

    axi_lite_to_apb_bridge dut_bridge (
        .aclk(clk),
        .aresetn(resetn),
        .s_axi_awaddr(axi_if.awaddr),
        .s_axi_awvalid(axi_if.awvalid),
        .s_axi_awready(axi_if.awready),
        .s_axi_wdata(axi_if.wdata),
        .s_axi_wstrb(axi_if.wstrb),
        .s_axi_wvalid(axi_if.wvalid),
        .s_axi_wready(axi_if.wready),
        .s_axi_bresp(axi_if.bresp),
        .s_axi_bvalid(axi_if.bvalid),
        .s_axi_bready(axi_if.bready),
        .s_axi_araddr(axi_if.araddr),
        .s_axi_arvalid(axi_if.arvalid),
        .s_axi_arready(axi_if.arready),
        .s_axi_rdata(axi_if.rdata),
        .s_axi_rresp(axi_if.rresp),
        .s_axi_rvalid(axi_if.rvalid),
        .s_axi_rready(axi_if.rready),
        .paddr(apb_bus.paddr),
        .psel(apb_bus.psel),
        .penable(apb_bus.penable),
        .pwrite(apb_bus.pwrite),
        .pwdata(apb_bus.pwdata),
        .pstrb(apb_bus.pstrb),
        .prdata(apb_bus.prdata),
        .pready(apb_bus.pready),
        .pslverr(apb_bus.pslverr)
    );

    apb_gpio dut_gpio (
        .pclk(clk),
        .presetn(resetn),
        .paddr(apb_bus.paddr),
        .psel(apb_bus.psel),
        .penable(apb_bus.penable),
        .pwrite(apb_bus.pwrite),
        .pwdata(apb_bus.pwdata),
        .pstrb(apb_bus.pstrb),
        .prdata(apb_bus.prdata),
        .pready(apb_bus.pready),
        .pslverr(apb_bus.pslverr),
        .gpio_data(gpio_data),
        .gpio_dir(gpio_dir)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        resetn = 1'b0;
        axi_if.bready = 1'b1;
        axi_if.rready = 1'b1;
        repeat (5) @(posedge clk);
        resetn = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual axi4_lite_if)::set(null, "uvm_test_top.env.*", "axi_vif", axi_if);
        run_test();
    end
endmodule
