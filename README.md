# AUBIE_CPU_Architecture
This Repository contains custom-defined (AUBIE) processor components as defined by the ModelSimPE  VHDL([Very High Speed Integrated Circuit] Hardware Description Language) Simulation Environment. 

This is a custom implementation of a MIPS-based, unpipelined Architecture with an atypical 32-bit datapath. The AUBIE_CPU datapath has the following schematic:

![alt text](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/aubie_datapath.jpg)

![alt text](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/aubie_test_Screenshots/CompleteWaveT0_T6483.PNG)

## Instruction Set 
The opcode for this architecture is always found in the high order 8 bits of an instruction word (bits 31-24). Instructions can be variable length (either one dlx_word long or two words long). In addition to the opcode, the first word may hold a number of register numbers for source and destination registers. The second word contains either a 32-bit immediate value for the load immediate (LDI) instruction or it holds an address for the store (STO), load (LD), jump (JMP), or jump-if-zero (JZ) instructions.

### ALU Instructions 
ALU Instructions are one dlx_word long (1 address) and have the following format:

| Opcode       	| Dest         	| Op1          	| Op2          	| Not Used   	|
|--------------	|--------------	|--------------	|--------------	|------------	|
| Bits 31 - 24 	| Bits 23 - 19 	| Bits 18 - 14 	| Bits 13 - 9 	| Bits 8 - 0 	|


### Store Instructions (STO)
Store Instructions are two dlx_words long, stored in two consecutive addresses in memory:

Word 1 has the following format:

| Opcode       	| Dest not used	| Op1          	| Op2 not used 	| Not Used   	|
|--------------	|--------------	|--------------	|--------------	|------------	|
| Bits 31 - 24 	| Bits 23 - 19 	| Bits 18 - 14 	| Bits 13 - 9 	| Bits 8 - 0 	|

Word 2 has the following format:

| Address                                                                    	|
|---------------------------------------------------------------------------	|
| Bits 31 - 0                                                                 |

### Load Instructions (LD & LDI)
Load Instructions are two dlx_words long, stored in two consecutive addresses in memory:

Word 1 has the following format:

| Opcode       	| Dest        	| Op1 not used 	| Op2 not used 	| Not Used   	|
|--------------	|--------------	|--------------	|--------------	|------------	|
| Bits 31 - 24 	| Bits 23 - 19 	| Bits 18 - 14 	| Bits 13 - 9 	| Bits 8 - 0 	|

Word 2 has the following format:

| Address or Immediate                                                       	|
|---------------------------------------------------------------------------	|
| Bits 31 - 0                                                                   |

### Register Indirect Load and Store (STOR & LDR)
These do load and store using the contents of a register to specify the address. For STOR, the dest 
register holds the address to which to store the contents of register op1. For LDR, the op1 register holds
the address to load the contents from into the destination register:

| Opcode       	| Dest         	| Op1          	| Op2 not used 	| Not Used   	|
|--------------	|--------------	|--------------	|--------------	|------------	|
| Bits 31 - 24 	| Bits 23 - 19 	| Bits 18 - 14 	| Bits 13 - 9 	| Bits 8 - 0 	|

### Jump Operations (JMP & JZ)
Either unconditional (JMP) or condition (JZ) jump to an address given in the 2nd word of the instruction:

Word 1 has the following format:

| Opcode       	| Dest not used	| Op1          	| Op2 not used 	| Not Used   	|
|--------------	|--------------	|--------------	|--------------	|------------	|
| Bits 31 - 24 	| Bits 23 - 19 	| Bits 18 - 14 	| Bits 13 - 9 	| Bits 8 - 0 	|

Word 2 has the following format:

| Address                                                                    	|
|---------------------------------------------------------------------------	|
| Bits 31 - 0                                                                   |


### OPCODES
| Mnemonic                 	| Opcode 	| Meaning             	                                            |
|-------------------------- |--------	|-----------------------------------------------------------------	|
| ADDU   dest, op1, op2   	| 0x00   	| unsigned add        	                                            |
| SUBU   dest, op1, op2   	| 0x01   	| unsigned subtract   	                                            |
| ADD    dest, op1, op2  	| 0x02   	| two's comp add      	                                            |
| SUB    dest, op1, op2 	| 0x03   	| two's comp subtract 	                                            |
| MUL    dest, op1, op2  	| 0x04   	| two's comp multiply 	                                            |
| DIV    dest, op1, op2 	| 0x05   	| two's comp divide   	                                            |
| ANDL   dest, op1, op2     | 0x06   	| logical AND         	                                            |
| ANDB   dest, op1, op2     | 0x07   	| bitwise AND         	                                            |
| ORL    dest, op1, op2  	| 0x08   	| logical OR          	                                            |
| ORB    dest, op1, op2   	| 0x09   	| bitwise OR          	                                            |
| NOTL   dest, op1, op2     | 0x0A   	| logical NOT(OP1)    	                                            |
| NOTB   dest, op1, op2     | 0x0B   	| bitwise NOT(OP1)    	                                            |
| NOOP                     	| 0x10   	| Do nothing           	                                            |
| STO    op1, address       | 0x20   	| Put contents of reg op1 in memory specified by address word 2    	|
| LD     dest, address      | 0x30   	| Load contents of address to register destination                	|
| LDI    dest, #imm         | 0x31   	| Load value immediate into register destination                  	|
| STOR   (dest), op1        | 0x22   	| Put contents of reg op1 in address given by contents of dest reg 	|
| LDR    dest, (op1)        | 0x32   	| Load contents of address given by register op1 into register dest |
| JMP    address            | 0x40   	| Unconditional jump to address                                   	|
| JZ     op1, address       | 0x41   	| Jump to address if op1 == 0                                      	|

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for Simulation and testing purposes. The files in this repo contain a comprehensive [specification list](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/AUBIE%20CPU%20SPECIFICATION.pdf) of datapath elements and Cycle-by-Cycle [semantics](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/SEMANTICS%20%20OF%20AUBIE%20PROCESSOR%20INSTRUCTIONS.pdf) for each instruction. 

### Prerequisites & Installation

In order to perform testing and evaluation of this code base, you will need to have an application that supports HDL designs and performs VHDL simulations. 
This project was created by and tested with ModelSim PE Student Edition, developed by Mentor Graphics. It is recommended ModelSim PE Student Edition be dowloaded onto Windows based Operating Systems
as the only available download for using the program is through a .exe executable file, which would require other operating systems to perform translations and supply non-native API support. 

If you choose to use their Software, navigate to their [site](https://www.mentor.com/company/higher_ed/modelsim-student-edition) for complete install instructions and to complete the license request form.
Product demo information can be found [here](https://www.mentor.com/products/fv/multimedia/modelsim-essentials). Further, it should be noted there is no customer support for this edition of ModelSim.

## Running the tests

Once you become familiar with how to navigate the ModelSim GUI and its menus, you can perform entity tests using the "<ENTITY>.do" files from the VSIM Transcript Window by simply executing the following command:

```
<VSIM> do <ENTITY>.do
```
<Entity>.do files are not auto-generated and simply execute on VSIM terminal commands. You can copy your "force" commands from the Transcript window and create a .do file of your own for ease of subsequent signal testing,
or you may choose to manually select entity signals (add wave) to place in the "Wave - default" window and "force" signal outputs. Navigate [here](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/alu_test_Screenshots/ALU_OP_0_TEST.PNG) to see an example of how signals would appear in the Wave output window. 
  
The component Unit Under Test (UUT) is the entity 'aubie' in the file labeled [interconnect_aubie](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/interconnect_aubie.vhd). As noted by the convention above, a sample .do file used for running the simulation is [aubie.do](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/aubie.do).

It is up to the user to choose what signals they wish to appear in their simulation wave window and what order they appear on the list. The signals used in the sample simulation consists of more than what is needed for the purpose of showing the .do file syntax. The following script from the aubie.do file will run the simulation to completion for all instructions that were loaded into memory:

```
add wave -position insertpoint \
sim:/aubie/aubie_clock \
sim:/aubie/aubie_ctl/behav/current_state \
sim:/aubie/aubie_ctl/behav/next_state \
sim:/aubie/ir_clk \
sim:/aubie/aubie_ctl/ir_control \
sim:/aubie/aubie_ctl/behav/opcode \
sim:/aubie/aubie_ctl/behav/destination \
sim:/aubie/aubie_ctl/behav/operand1 \
sim:/aubie/aubie_ctl/behav/operand2 \
sim:/aubie/mem_clk \
sim:/aubie/memaddr_mux \
sim:/aubie/memaddr_in \
sim:/aubie/mem_readnotwrite \
sim:/aubie/mem_out \
sim:/aubie/aubie_memory/mem_behav/data_memory \
sim:/aubie/addr_clk \
sim:/aubie/addr_in \
sim:/aubie/addr_out \
sim:/aubie/pc_clk \
sim:/aubie/pc_mux \
sim:/aubie/pc_in \
sim:/aubie/pc_out \
sim:/aubie/regfile_clk \
sim:/aubie/aubie_regfile/reg_file_process/registers \
sim:/aubie/regfile_index \
sim:/aubie/regfile_readnotwrite \
sim:/aubie/regfile_in \
sim:/aubie/regfile_out 
force -freeze sim:/aubie/aubie_clock 0 0, 1 {50 ns} -r 100

run 6500 ns
```
### Sample Instructions  
Sample Instructions have already been loaded into the memory unit and can be referenced in the [datapath file](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/datapath_aubie_v1.vhd). The following code segment shows the loaded instructions in the order they are executed:


![Alt Text](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/aubie_test_Screenshots/DataPathInstructions.png)

### Sample Results 

You can observe the register file values by evaluating the register file local values:

![alt text](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/aubie_test_Screenshots/RegisterFileValues.PNG)

Some instructions also write back to memory and you can also see those changes in the memory unit local values as depicted their respective [screenshots](https://github.com/zedtran/AUBIE_CPU_Architecture/tree/master/aubie_test_Screenshots) in the aubie test screenshots directory.

### Built With

* [ModelSim PE Student Edition](https://www.mentor.com/company/higher_ed/modelsim-student-edition) - The HDL Simulation GUI and Test Environment
* [Atom.io](https://atom.io) - Text Editor
* [language-vhdl](https://atom.io/packages/language-vhdl) - VHDL Language Support in Atom
* [Git for Windows](https://gitforwindows.org) - Git SCM Tools and Features for Windows


