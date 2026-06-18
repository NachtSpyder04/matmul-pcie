# matmul-pcie

A PCIe-connected matrix multiplication accelerator implemented on the LiteFury Artix-7 FPGA using Xilinx XDMA and AXI-Stream interfaces with Raspberry 5 as host.

The design receives matrix data from the host through PCIe, performs hardware-accelerated matrix multiplication on the FPGA, and returns the results back to the host through XDMA.


## Hardware

- LiteFury Artix 7 FPGA (XC7A100T)
- RPi 5
- RPi 5 M.2 Hat 

## Toolchain

- Vivado 2024.2
- openFPGALoader

## Project Structure

```text
.
├── rtl/
│   ├── mat_mul.v
│   ├── row_col.v
│   └── mat_mul_wrapper.v
│
├── constraints/
│   ├── normal_constraints.xdc
│   └── late_constraints.xdc
│
├── bd/
│   └── design_1.tcl
│
├── rebuild.tcl
├── .gitignore
└── README.md
```

## Block Design

The design consists of:

- XDMA PCIe Endpoint
- AXI Stream Data FIFOs
- AXI Stream Width Converters
- Custom Matrix Multiplication Accelerator 

Data Flow:

```text
Host PC
   │
   ▼
 XDMA H2C
   │
   ▼
AXIS FIFO
   │
   ▼
Width Converter
   │
   ▼
Matrix Multiplier
   │
   ▼
AXIS FIFO
   │
   ▼
Width Converter
   │
   ▼
 XDMA C2H
   │
   ▼
Host PC
```

## Recreating the Project

Clone the repository:

```bash
git clone https://github.com/NachtSpyder04/matmul-pcie.git
cd matmul-pcie
```

Launch Vivado in batch mode:

```bash
vivado -mode batch -source rebuild.tcl
```

Or inside the Vivado Tcl Console:

```tcl
source rebuild.tcl
```

The script will:

1. Create a new Vivado project
2. Add RTL sources
3. Add constraints
4. Recreate the Block Design
5. Generate output products
6. Create the HDL wrapper
7. Configure synthesis and implementation

## Building the Bitstream

After project generation:

```text
Run Synthesis
Run Implementation
Generate Bitstream
```

## Host Software

Data transfer is performed through the XDMA Linux driver.

Typical workflow:

1. Open XDMA H2C channel
2. Transfer input matrices
3. FPGA performs matrix multiplication
4. Read output matrix from XDMA C2H channel
   
A jupyter notebook has been shared with this repository, copy it in your RPi and execute the cells in order to start data transfer

## References 

All the setup necessary for RPi to detect an FPGA along with XDMA driver was referred from [this blog](https://www.controlpaths.com/2024/02/18/connecting-litefury-to-raspberrypi5/)


