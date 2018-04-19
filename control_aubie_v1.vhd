
use work.bv_arithmetic.all;
use work.dlx_types.all;



entity aubie_controller is
    generic(prop_delay: Time := 5 ns); -- Controller propagation delay
    port(
      ir_control            :   in dlx_word;
      alu_out               :   in dlx_word;
      alu_error             :   in error_code;
      clock                 :   in bit;
      regfilein_mux         :   out threeway_muxcode;
      memaddr_mux           :   out threeway_muxcode;
      addr_mux              :   out bit;
      pc_mux                :   out bit;
      alu_func              :   out alu_operation_code;
      regfile_index         :   out register_index;
      regfile_readnotwrite  :   out bit;
      regfile_clk           :   out bit;
      mem_clk               :   out bit;
      mem_readnotwrite      :   out bit;
      ir_clk                :   out bit;
      imm_clk               :   out bit;
      addr_clk              :   out bit;
      pc_clk                :   out bit;
      op1_clk               :   out bit;
      op2_clk               :   out bit;
      result_clk            :   out bit
    );
end aubie_controller;


architecture behavior of aubie_controller is
begin
    behav: process(clock) is

        type state_type is range 1 to 20; -- Will likely need more states if we implement jump operations
        variable state: state_type := 1;
        variable opcode: byte;
        variable destination, operand1, operand2 : register_index;

        begin
            if (clock'event and clock = '1') then
                opcode := ir_control(31 downto 24);
                destination := ir_control(23 downto 19);
                operand1 := ir_control(18 downto 14);
                operand2 := ir_control(13 downto 9);

                case (state) is
                    when 1 => -- (fetch the instruction, for all types)
                    -- Load the 32-bit memory word stored at the address in the PC to the Instruction Register:
                    -- Mem[PC] --> IR

                        --regfilein_mux	<= "##";
                        memaddr_mux <= "00" after prop_delay; -- memory threeway_mux input_0 to read from PC
                        addr_mux	<= '1' after prop_delay;
                        pc_mux	<= '1' after prop_delay; -- current addr_out
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        regfile_clk	<= '0' after prop_delay;
                        mem_clk	<= '1' after prop_delay; -- High so it can output mem_out
                        mem_readnotwrite <= '1' after prop_delay; -- In state 1, we want to read from main memory and ignore result_out
                        ir_clk <= '1' after prop_delay; -- High so IR will be receiving signal from Memory[PC]
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '1';
                        pc_clk <= '1' after prop_delay; -- High so PC will output the current address it retains
                        op1_clk	<= '0' after prop_delay;
                        op2_clk	<= '0' after prop_delay;
                        result_clk	<= '0' after prop_delay;

                        state := 2;
                    when 2 =>  -- figure out which instruction
                        if opcode(7 downto 4) = "0000" then -- ALU op
                            state := 3;
                        elsif opcode = X"20" then  -- STO
                            state := 9;
                        elsif opcode = X"30" or opcode = X"31" then -- LD or LDI
                            state := 7;
                        elsif opcode = X"22" then -- STOR
                            state := 14;
                        elsif opcode = X"32" then -- LDR
                            state := 12;
                        elsif opcode = X"40" or opcode = X"41" then -- JMP or JZ
                            state := 16;
                        elsif opcode = X"10" then -- NOOP
                            state := 19;
                        else -- error: Bad opcode -- No need to do anything
                        end if;

                    when 3 => -- ALU op (Step1):  load op1 register from the regfile

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        regfile_index <= operand1 after prop_delay; -- The register_index
                        regfile_readnotwrite <= '1' after prop_delay; -- Needs to be high because we're doing a read (ignores data_in signal)
                        regfile_clk <= '1' after prop_delay; -- Needs to be high for a regfile operation
                        mem_clk <= '0' after prop_delay;
                        --mem_readnotwrite <= '#';
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '1' after prop_delay; -- op1_register clock needs to be high so it can accept regfile data_out
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;


                        state := 4;
                    when 4 => -- ALU op (Step2): load op2 register from the regfile

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        regfile_index <= operand2 after prop_delay; -- The register_index
                        regfile_readnotwrite <= '1' after prop_delay; -- Needs to be high because we're doing a read
                        regfile_clk <= '1' after prop_delay; -- Needs to be high for regfile operation
                        mem_clk <= '0' after prop_delay;
                        --mem_readnotwrite <= '#';
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '1' after prop_delay; -- op2_register clock needs to be high for receiving reg_file data_out
                        result_clk <= '0' after prop_delay;



                        state := 5;
                    when 5 => -- ALU op (Step3):  perform ALU operation (Copy ALU output into result register)

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        alu_func <= opcode(3 downto 0) after prop_delay; -- The specific ALU operation denoted by the last 4 bits of the opcode
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        regfile_clk <= '0' after prop_delay;
                        mem_clk <= '0' after prop_delay;
                        --mem_readnotwrite <= '#';
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '1' after prop_delay; -- Need to add ALU operation value to result register




                    ------------------ State 5 Questions, Comments, & Concerns --------------------
                    -- (1) What do we do with the alu_out (dlx_word) and alu_error (4 bit error_code)
                    --     control unit input signals? Is that handled in this state?
                    --      \\ result <= alu_out; HOW DO WE ACTUALLY DO THIS? \\
                    --      \\ something <= alu_error; HOW DO WE ACTUALLY DO THIS? \\
                    -- (2) We are instructed to copy alu_out to result register, but alu_out is a dlx_word and no
                    --     output port signal matches a signal with that data width--unless these instructions are
                    --     some kind of cryptic way of simply telling us to set the result register clock to high.
                    --     The same goes for error_code output from alu operation.
                    --------------------------------------------------------------------------------

                        state := 6;
                    when 6 => -- ALU op (Step4): write back ALU operation

                        regfilein_mux <= "00" after prop_delay; -- 3-way mux select for result
                        memaddr_mux <= "10" after prop_delay; -- memory address in mux select input_2
                        --addr_mux <= '#';
                        pc_mux <= '0' after prop_delay; -- pcplusone_out
                        --alu_func <= opcode(3 downto 0);
                        regfile_index <= destination after prop_delay;
                        regfile_readnotwrite <= '0' after prop_delay; -- Write back to destination
                        regfile_clk <= '1' after prop_delay; -- Needs to be high, if not already
                        mem_clk <= '0' after prop_delay;
                        --mem_readnotwrite <= '0';
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '1' after prop_delay; -- To increment PC
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;



                    ------------------ State 6 Questions, Comments, & Concerns --------------------
                    -- (1) What do we do with the alu_out (dlx_word) and alu_error (4 bit error_code)
                    --     control unit input signals? Is that handled in this state?
                    -- (2) Does the ALU result signal get stored back in memory AND back in the register file?
                    -- (3) Should we handle memory writeback in this state? No mention in semantics of writeback to memory,
                    --     but it seems we want to write back to memory in this state.
                    -------------------------------------------------------------------------------


                        state := 1;
                    when 7 => -- LD or LDI (Step1): get the addr or immediate word

                        if (opcode = x"30") then
                        -- load contents of address to register destination
                        -- Increment PC. Copy memory specified by PC into address register
                        -- PC -> PC+1. Mem[PC] --> Addr
                            pc_clk <= '1' after prop_delay;
                            pc_mux <= '0' after prop_delay; -- pcplusone_out

                            -- CAN USE 100 ns delay to set state values within a state
                            -- FIGURE OUT HOW TO DO THIS since we might want two different values

                            --regfilein_mux <= "##";
                            memaddr_mux <= "00" after prop_delay; -- mux select read from pcplusone_out
                            addr_mux <= '1' after prop_delay; -- input_1 select of mem_out
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            regfile_clk <= '0' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay; -- Memory Read operation
                            ir_clk <= '0' after prop_delay;
                            imm_clk <= '0' after prop_delay;
                            addr_clk <= '1' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;
                        else
                        -- load immediate value into register destination
                        -- Increment PC. Copy memory specified by PC into immediate register
                        -- PC -> PC+1. Mem[PC] --> Immed
                            pc_clk <= '1' after prop_delay;
                            pc_mux <= '0' after prop_delay; -- pcplusone_out

                            -- CAN USE 100 ns delay to set state values within state
                            -- FIGURE OUT HOW TO DO THIS since we might want two different values

                            --regfilein_mux <= "##";
                            memaddr_mux <= "00" after prop_delay;
                            --addr_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            regfile_clk <= '0' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay;
                            ir_clk <= '0' after prop_delay;
                            imm_clk <= '1' after prop_delay;
                            addr_clk <= '0' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;

                        end if;

                    ------------------ State 7 Questions, Comments, & Concerns --------------------
                    -- (1) How do you increment and then copy afterwards? Are the signals synchronous (i.e.
                    --     If we assign pc_mux to '0' BEFORE setting the immediate clock to high,
                    --     will that increment the PC first?)
                    --
                    --
                    -------------------------------------------------------------------------------

                        state := 8;
                    when 8 => -- LD or LDI (Step2)

                        if (opcode = x"30") then
                        -- Copy mem location specified by Address to the destination register. Increment PC.
                        -- Mem[Addr] --> Regs[IR[dest]]. PC --> PC+1.
                            regfilein_mux <= "01" after prop_delay; -- mux selector for memory out
                            memaddr_mux <= "01" after prop_delay; -- mux selector input_1 for address register output
                            addr_mux <= '1' after prop_delay;
                            --alu_func <= opcode(3 downto 0);
                            regfile_index <= destination after prop_delay;
                            regfile_readnotwrite <= '0' after prop_delay;
                            regfile_clk <= '1' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay;
                            ir_clk <= '1' after prop_delay;
                            imm_clk <= '0' after prop_delay;
                            addr_clk <= '0' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;

                            pc_clk <= '1' after prop_delay;
                            pc_mux <= '0' after prop_delay;

                        else
                        -- Copy immediate register into the destination register. Increment PC.
                        -- Immed --> Regs[IR[dest]]. PC --> PC+1.
                            regfilein_mux <= "10" after prop_delay; -- mux selector for immediate register out
                            memaddr_mux <= "00" after prop_delay; -- mux selector input_0 for PC output
                            --addr_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            regfile_index <= destination after prop_delay;
                            regfile_readnotwrite <= '0' after prop_delay;
                            regfile_clk <= '1' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay;
                            ir_clk <= '1' after prop_delay;
                            imm_clk <= '1' after prop_delay;
                            addr_clk <= '0' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;


                            pc_clk <= '1' after prop_delay;
                            pc_mux <= '0' after prop_delay;

                        end if;

                    ------------------ State 8 Questions, Comments, & Concerns --------------------
                    -- (1) How do you copy and then increment the PC afterwards? Are the signals synchronous?
                    --     Can I assign pc_mux two different values in the same state? Initially, I need
                    --     the current PC address and then I need to increment afterwards. How would I do this?
                    --     (pc_mux <= '1' at the beginning and then pc_mux <= '0' at the end?)
                    -- (2) If the immediate register clock or address register clock (dlx_register) is
                    --     set to low in this state but was high in the last state, does it still propagate
                    --     the output signal from the last state?
                    --
                    -------------------------------------------------------------------------------

                        state := 1;
                    when 9 => -- STO (Step1): Store contents of Register op1 specified by address word 2
                    -- Increment PC.

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux  <= '#';
                        pc_mux <= '0' after prop_delay;
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        pc_clk <= '1' after prop_delay;
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 10;
                    when 10 => -- STO (Step2): Store contents of Register op1 specified by address word 2
                    -- Load memory at address given by PC to the address register: Mem[PC] --> Addr.

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;

                        state := 11;
                    when 11 => -- STO (Step3): Store contents of Register op1 specified by address word 2
                    -- Store contents of src register to address in memory given by address register,
                    -- then increment PC. Regs[IR[src]] --> Mem[Addr]. PC -> PC+1

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;

                        state := 1;
                    when 12 => -- LDR (Step1): Copy contents of op1 reg to Address register:
                    -- Regs[IR[op1]] --> Addr

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;

                        state := 13;
                    when 13 => -- LDR (Step2): Copy contents of memory specified by Address register to destination register:
                    -- Mem[Addr] --> Regs[IR[dest]]. Increment PC --> PC+1.

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;

                        state := 1;
                    when 14 => -- STOR (Step1): Copy contents of dest reg into Address Register:
                    -- Regs[IR[dest]] --> Addr
                    -- your code here

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;

                        state := 15;
                    when 15 => -- STOR (Step2): Copy contents of op1 register to Memory address specified by Address register:
                    -- Regs[IR[op1]] --> Mem[Addr]. Increment PC --> PC+1

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;


                        state := 1;
                    when 16 => -- JMP or JZ (Step1): Increment PC --> PC+1

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;

                        state := 17;
                    when 17 => -- JMP or JZ (Step2):

                        if (opcode = x"40") then -- JMP
                        -- Load memory specified by PC to Address register: Mem[PC] --> Addr

                            --regfilein_mux <= "##" after prop_delay;
                            --memaddr_mux <= "##" after prop_delay;
                            --addr_mux <= '#' after prop_delay;
                            --pc_mux <= '#' after prop_delay;
                            --alu_func <= opcode(3 downto 0) after prop_delay;
                            --regfile_index <= destination, operand1, operand2 after prop_delay;
                            --regfile_readnotwrite <= '#' after prop_delay;
                            --regfile_clk <= '#' after prop_delay;
                            --mem_clk <= '#' after prop_delay;
                            --mem_readnotwrite <= '#' after prop_delay;
                            --ir_clk <= '#' after prop_delay;
                            --imm_clk <= '#' after prop_delay;
                            --addr_clk <= '#' after prop_delay;
                            --pc_clk <= '#' after prop_delay;
                            --op1_clk <= '#' after prop_delay;
                            --op2_clk <= '#' after prop_delay;
                            --result_clk <= '#' after prop_delay;

                        else -- JZ
                        -- Load memory specified by PC to Address register: Mem[PC] --> Addr,
                        -- then copy register op1 to control: Regs[IR[op1]] --> Ctl

                            --regfilein_mux <= "##" after prop_delay;
                            --memaddr_mux <= "##" after prop_delay;
                            --addr_mux <= '#' after prop_delay;
                            --pc_mux <= '#' after prop_delay;
                            --alu_func <= opcode(3 downto 0) after prop_delay;
                            --regfile_index <= destination, operand1, operand2 after prop_delay;
                            --regfile_readnotwrite <= '#' after prop_delay;
                            --regfile_clk <= '#' after prop_delay;
                            --mem_clk <= '#' after prop_delay;
                            --mem_readnotwrite <= '#' after prop_delay;
                            --ir_clk <= '#' after prop_delay;
                            --imm_clk <= '#' after prop_delay;
                            --addr_clk <= '#' after prop_delay;
                            --pc_clk <= '#' after prop_delay;
                            --op1_clk <= '#' after prop_delay;
                            --op2_clk <= '#' after prop_delay;
                            --result_clk <= '#' after prop_delay;
                        end if;

                        state := 18;
                    when 18 => -- JMP or JZ (Step3):

                        if (opcode = x"40") then -- JMP
                        -- Load Addr to PC: Addr --> PC

                            --regfilein_mux <= "##" after prop_delay;
                            --memaddr_mux <= "##" after prop_delay;
                            --addr_mux <= '#' after prop_delay;
                            --pc_mux <= '#' after prop_delay;
                            --alu_func <= opcode(3 downto 0) after prop_delay;
                            --regfile_index <= destination, operand1, operand2 after prop_delay;
                            --regfile_readnotwrite <= '#' after prop_delay;
                            --regfile_clk <= '#' after prop_delay;
                            --mem_clk <= '#' after prop_delay;
                            --mem_readnotwrite <= '#' after prop_delay;
                            --ir_clk <= '#' after prop_delay;
                            --imm_clk <= '#' after prop_delay;
                            --addr_clk <= '#' after prop_delay;
                            --pc_clk <= '#' after prop_delay;
                            --op1_clk <= '#' after prop_delay;
                            --op2_clk <= '#' after prop_delay;
                            --result_clk <= '#' after prop_delay;

                        else -- JZ
                        -- If Result == 0, copy Addr to PC: Addr --> PC, else increment PC --> PC+1

                            --regfilein_mux <= "##" after prop_delay;
                            --memaddr_mux <= "##" after prop_delay;
                            --addr_mux <= '#' after prop_delay;
                            --pc_mux <= '#' after prop_delay;
                            --alu_func <= opcode(3 downto 0) after prop_delay;
                            --regfile_index <= destination, operand1, operand2 after prop_delay;
                            --regfile_readnotwrite <= '#' after prop_delay;
                            --regfile_clk <= '#' after prop_delay;
                            --mem_clk <= '#' after prop_delay;
                            --mem_readnotwrite <= '#' after prop_delay;
                            --ir_clk <= '#' after prop_delay;
                            --imm_clk <= '#' after prop_delay;
                            --addr_clk <= '#' after prop_delay;
                            --pc_clk <= '#' after prop_delay;
                            --op1_clk <= '#' after prop_delay;
                            --op2_clk <= '#' after prop_delay;
                            --result_clk <= '#' after prop_delay;

                        end if;

                        state := 1;
                    when 19 => -- NOOP: Only increments PC

                        --regfilein_mux <= "##" after prop_delay;
                        --memaddr_mux <= "##" after prop_delay;
                        --addr_mux <= '#' after prop_delay;
                        --pc_mux <= '#' after prop_delay;
                        --alu_func <= opcode(3 downto 0) after prop_delay;
                        --regfile_index <= destination, operand1, operand2 after prop_delay;
                        --regfile_readnotwrite <= '#' after prop_delay;
                        --regfile_clk <= '#' after prop_delay;
                        --mem_clk <= '#' after prop_delay;
                        --mem_readnotwrite <= '#' after prop_delay;
                        --ir_clk <= '#' after prop_delay;
                        --imm_clk <= '#' after prop_delay;
                        --addr_clk <= '#' after prop_delay;
                        --pc_clk <= '#' after prop_delay;
                        --op1_clk <= '#' after prop_delay;
                        --op2_clk <= '#' after prop_delay;
                        --result_clk <= '#' after prop_delay;
                        state := 1;
                    when 20 =>
                        -- May possibly use this state for jumps
                    when others => null;
                end case;
            elsif clock'event and clock = '0' then
            -- reset all register clocks and signals
            -- State 1 will set appropriate values during fetch
                regfilein_mux <= "00" after prop_delay;
                memaddr_mux <= "00" after prop_delay;
                addr_mux <= '0' after prop_delay;
                pc_mux <= '0' after prop_delay;
                alu_func <= "0000" after prop_delay;
                regfile_index <= "00000" after prop_delay;
                regfile_readnotwrite <= '0' after prop_delay;
                regfile_clk <= '0' after prop_delay;
                mem_clk <= '0' after prop_delay;
                mem_readnotwrite <= '0' after prop_delay;
                ir_clk <= '0' after prop_delay;
                imm_clk <= '0' after prop_delay;
                addr_clk <= '0' after prop_delay;
                pc_clk <= '0' after prop_delay;
                op1_clk <= '0' after prop_delay;
                op2_clk <= '0' after prop_delay;
                result_clk <= '0' after prop_delay;
            end if;
        end process behav;
end behavior;
