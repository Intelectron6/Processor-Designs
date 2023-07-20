Single cycle implementation of IITB RISC ISA </br>

Source_codes folder consists of all the Verilog codes that describe the processor. The top level module is processor.v and the rest are instantiated inside it. </br>
Testbench folder consists of a baseline Verilog testbench. It just resets the processor initially and applies a clock of period 10ns. </br>
Assember folder consists of a Python based assembler that converts assembly code to binary code. Assembly code is written in .txt format and the assembler prints the equivalent binary code, which is to be pasted in instruction_memory.v file. Few sample assembly codes are also provided in this folder. </br>

For more details regarding the ISA and the architecture, a document will be uploaded soon....</br>


PLEASE DO NOT COPY THE SOURCE CODE DIRECTLY IF THIS IS GIVEN AS AN ASSIGNMENT/PROJECT!!!
