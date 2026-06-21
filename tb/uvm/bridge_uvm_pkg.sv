`timescale 1ns/1ps

package bridge_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum {AXI_READ, AXI_WRITE} axi_dir_e;

    class bridge_txn extends uvm_sequence_item;
        rand axi_dir_e dir;
        rand bit [7:0] addr;
        rand bit [31:0] data;
        rand bit [3:0] strb;
        bit [31:0] observed_data;
        bit [1:0] observed_resp;

        constraint aligned_c { addr[1:0] == 2'b00; }
        constraint strobe_c { strb != 4'b0000; }

        `uvm_object_utils_begin(bridge_txn)
            `uvm_field_enum(axi_dir_e, dir, UVM_ALL_ON)
            `uvm_field_int(addr, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(strb, UVM_ALL_ON)
            `uvm_field_int(observed_data, UVM_ALL_ON)
            `uvm_field_int(observed_resp, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "bridge_txn");
            super.new(name);
        endfunction
    endclass

    class bridge_sequencer extends uvm_sequencer #(bridge_txn);
        `uvm_component_utils(bridge_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class bridge_smoke_seq extends uvm_sequence #(bridge_txn);
        `uvm_object_utils(bridge_smoke_seq)
        function new(string name = "bridge_smoke_seq");
            super.new(name);
        endfunction

        task body();
            bridge_txn tx;
            tx = bridge_txn::type_id::create("write_data");
            start_item(tx);
            tx.dir = AXI_WRITE;
            tx.addr = 8'h00;
            tx.data = 32'h0000_00a5;
            tx.strb = 4'hf;
            finish_item(tx);

            tx = bridge_txn::type_id::create("read_data");
            start_item(tx);
            tx.dir = AXI_READ;
            tx.addr = 8'h00;
            tx.data = '0;
            tx.strb = 4'hf;
            finish_item(tx);
        endtask
    endclass

    class bridge_random_seq extends uvm_sequence #(bridge_txn);
        `uvm_object_utils(bridge_random_seq)
        function new(string name = "bridge_random_seq");
            super.new(name);
        endfunction

        task body();
            bridge_txn tx;
            repeat (32) begin
                tx = bridge_txn::type_id::create("random_access");
                start_item(tx);
                assert(tx.randomize() with { addr inside {8'h00, 8'h04, 8'h08, 8'h0c}; });
                finish_item(tx);
            end
        endtask
    endclass

    class bridge_driver extends uvm_driver #(bridge_txn);
        `uvm_component_utils(bridge_driver)
        virtual axi4_lite_if vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual axi4_lite_if)::get(this, "", "axi_vif", vif)) begin
                `uvm_fatal("NOVIF", "axi_vif not configured")
            end
        endfunction

        task run_phase(uvm_phase phase);
            bridge_txn tx;
            drive_idle();
            forever begin
                seq_item_port.get_next_item(tx);
                if (tx.dir == AXI_WRITE) drive_write(tx);
                else drive_read(tx);
                seq_item_port.item_done();
            end
        endtask

        task drive_idle();
            vif.awvalid <= 1'b0;
            vif.wvalid <= 1'b0;
            vif.bready <= 1'b1;
            vif.arvalid <= 1'b0;
            vif.rready <= 1'b1;
            vif.wstrb <= 4'hf;
        endtask

        task drive_write(bridge_txn tx);
            @(posedge vif.aclk);
            vif.awaddr <= tx.addr;
            vif.wdata <= tx.data;
            vif.wstrb <= tx.strb;
            vif.awvalid <= 1'b1;
            vif.wvalid <= 1'b1;
            wait (vif.awready && vif.wready);
            @(posedge vif.aclk);
            vif.awvalid <= 1'b0;
            vif.wvalid <= 1'b0;
            wait (vif.bvalid);
            tx.observed_resp = vif.bresp;
            @(posedge vif.aclk);
        endtask

        task drive_read(bridge_txn tx);
            @(posedge vif.aclk);
            vif.araddr <= tx.addr;
            vif.arvalid <= 1'b1;
            wait (vif.arready);
            @(posedge vif.aclk);
            vif.arvalid <= 1'b0;
            wait (vif.rvalid);
            tx.observed_data = vif.rdata;
            tx.observed_resp = vif.rresp;
            @(posedge vif.aclk);
        endtask
    endclass

    class bridge_monitor extends uvm_component;
        `uvm_component_utils(bridge_monitor)
        virtual axi4_lite_if vif;
        uvm_analysis_port #(bridge_txn) ap;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual axi4_lite_if)::get(this, "", "axi_vif", vif)) begin
                `uvm_fatal("NOVIF", "axi_vif not configured")
            end
        endfunction

        task run_phase(uvm_phase phase);
            bridge_txn tx;
            forever begin
                @(posedge vif.aclk);
                if (vif.bvalid && vif.bready) begin
                    tx = bridge_txn::type_id::create("observed_write_resp");
                    tx.dir = AXI_WRITE;
                    tx.observed_resp = vif.bresp;
                    ap.write(tx);
                end
                if (vif.rvalid && vif.rready) begin
                    tx = bridge_txn::type_id::create("observed_read_resp");
                    tx.dir = AXI_READ;
                    tx.observed_data = vif.rdata;
                    tx.observed_resp = vif.rresp;
                    ap.write(tx);
                end
            end
        endtask
    endclass

    class bridge_scoreboard extends uvm_component;
        `uvm_component_utils(bridge_scoreboard)
        uvm_analysis_imp #(bridge_txn, bridge_scoreboard) analysis_export;
        int unsigned observed_count;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            analysis_export = new("analysis_export", this);
        endfunction

        function void write(bridge_txn tx);
            observed_count++;
            if (!(tx.observed_resp inside {2'b00, 2'b10})) begin
                `uvm_error("BAD_RESP", $sformatf("Unexpected AXI response %0b", tx.observed_resp))
            end
        endfunction
    endclass

    class bridge_coverage extends uvm_subscriber #(bridge_txn);
        `uvm_component_utils(bridge_coverage)
        bridge_txn sampled_tx;

        covergroup bridge_cg;
            option.per_instance = 1;
            direction_cp: coverpoint sampled_tx.dir;
            response_cp: coverpoint sampled_tx.observed_resp {
                bins okay = {2'b00};
                bins slverr = {2'b10};
            }
            data_low_cp: coverpoint sampled_tx.observed_data[7:0];
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            bridge_cg = new();
        endfunction

        function void write(bridge_txn t);
            sampled_tx = t;
            bridge_cg.sample();
        endfunction
    endclass

    class bridge_env extends uvm_env;
        `uvm_component_utils(bridge_env)
        bridge_sequencer sequencer;
        bridge_driver driver;
        bridge_monitor monitor;
        bridge_scoreboard scoreboard;
        bridge_coverage coverage;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = bridge_sequencer::type_id::create("sequencer", this);
            driver = bridge_driver::type_id::create("driver", this);
            monitor = bridge_monitor::type_id::create("monitor", this);
            scoreboard = bridge_scoreboard::type_id::create("scoreboard", this);
            coverage = bridge_coverage::type_id::create("coverage", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.ap.connect(scoreboard.analysis_export);
            monitor.ap.connect(coverage.analysis_export);
        endfunction
    endclass

    class bridge_base_test extends uvm_test;
        `uvm_component_utils(bridge_base_test)
        bridge_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = bridge_env::type_id::create("env", this);
        endfunction
    endclass

    class bridge_smoke_test extends bridge_base_test;
        `uvm_component_utils(bridge_smoke_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            bridge_smoke_seq seq;
            phase.raise_objection(this);
            seq = bridge_smoke_seq::type_id::create("seq");
            seq.start(env.sequencer);
            phase.drop_objection(this);
        endtask
    endclass

    class bridge_random_rw_test extends bridge_base_test;
        `uvm_component_utils(bridge_random_rw_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            bridge_random_seq seq;
            phase.raise_objection(this);
            seq = bridge_random_seq::type_id::create("seq");
            seq.start(env.sequencer);
            phase.drop_objection(this);
        endtask
    endclass

    class bridge_error_test extends bridge_random_rw_test;
        `uvm_component_utils(bridge_error_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class bridge_wait_state_test extends bridge_random_rw_test;
        `uvm_component_utils(bridge_wait_state_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass
endpackage
