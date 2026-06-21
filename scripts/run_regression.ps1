param(
    [ValidateSet('vcs','xcelium','questa','lint')]
    [string]$Simulator = 'lint',
    [string]$Test = 'bridge_smoke_test'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

switch ($Simulator) {
    'vcs' {
        vcs -full64 -sverilog -ntb_opts uvm -f filelist.f -l "sim_results/$Test.vcs_compile.log"
        ./simv +UVM_TESTNAME=$Test -l "sim_results/$Test.vcs_run.log"
    }
    'xcelium' {
        xrun -sv -uvm -f filelist.f +UVM_TESTNAME=$Test -l "sim_results/$Test.xrun.log"
    }
    'questa' {
        vlog -sv -f filelist.f
        vsim -c tb_top +UVM_TESTNAME=$Test -do "run -all; quit -f"
    }
    'lint' {
        if (-not (Get-Command verilator -ErrorAction SilentlyContinue)) {
            throw 'verilator not found. Install Verilator for local RTL lint or use a commercial simulator for full UVM.'
        }
        verilator --lint-only -sv rtl/axi_lite_to_apb_bridge.sv rtl/apb_gpio.sv
    }
}
