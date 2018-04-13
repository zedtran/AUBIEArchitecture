# AUBIE_CPU_Architecture
This Repository contains custom-defined (AUBIE) processor components as defined by the ModelSimPE  VHDL([Very High Speed Integrated Circuit] Hardware Description Language) Simulation Environment. 

This is a custom implementation of a MIPS-based Architecture with a 32-bit datapath. The AUBIE_CPU datapath has the following schematic:

![alt text](https://github.com/zedtran/AUBIE_CPU_Architecture/blob/master/aubie_datapath.jpg)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for Simulation and testing purposes. 

### Prerequisites && Installation

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


## Built With

* [ModelSim PE Student Edition](https://www.mentor.com/company/higher_ed/modelsim-student-edition) - The HDL Simulation GUI and Test Environment
* [Atom.io](https://atom.io) - Text Editor
* [language-vhdl](https://atom.io/packages/language-vhdl) - VHDL Language Support in Atom
* [Git for Windows](https://gitforwindows.org) - Git SCM Tools and Features for Windows


