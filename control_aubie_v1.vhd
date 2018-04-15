
use work.bv_arithmetic.all;
use work.dlx_types.all;

entity aubie_controller is
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

------------------ GENERAL Questions, Comments, & Concerns --------------------
-- (1) threeway_muxcode is not a defined subtype in dlx_types.
--     Do we need to define it? bit_vector(1 downto 0)?
-- (2) There is no mention of adding a propagation delay for state transitions
--     for ctl output signal changes. Are we required to add a prop_delay or is this simply
--     managed by each entity's generic prop_delay of 5 ns?
-- (3) Do ALL control unit output signals need to be assigned in each state
--     OR do the signals maintain the value from their last state? (i.e. Are output ports allowed to be unmapped?)
-- (4) Lab 2 and Lab 3 did not have prop_delays in their declared entities, but the
--     datapath_aubie_v1.vhd file contains prop_delay of 5 ns for those entities. Do we need to implement
--     prop_delay behavior for our entities?
-- (5) Also, the reg_file entity declared in the datapath file does NOT have a prop_delay, whereas Lab 2
--     required us to use a 15 ns prop_delay. What do we do here? Ignore or add it to the datapath?
-- (6) State type is range 1 to 20, but State 20 does not appear to be used. Is this intentional,
--     or do we just default to others => null condition in such a case? Could State 20 perhaps be the
--     error state?
--
-------------------------------------------------------------------------------

architecture behavior of aubie_controller is
begin
    behav: process(clock) is

        type state_type is range 1 to 20;
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
                        memaddr_mux <= "00"; -- memory threeway_mux input_0 to read from PC
                        addr_mux	<= '1';
                        pc_mux	<= '1'; -- current addr_out
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        regfile_clk	<= '0';
                        mem_clk	<= '1'; -- High so it can output mem_out
                        mem_readnotwrite <= '1'; -- In state 1, we want to read from main memory and ignore result_out
                        ir_clk <= '1'; -- High so IR will be receiving signal from Memory[PC]
                        imm_clk <= '0';
                        addr_clk <= '1';
                        pc_clk <= '1'; -- High so PC will output the current address it retains
                        op1_clk	<= '0';
                        op2_clk	<= '0';
                        result_clk	<= '0';

                        state := 2;

                    ------------------ State 1 Questions, Comments, & Concerns --------------------
                    -- (1) Refer to State 3, question 1.
                    --
                    -------------------------------------------------------------------------------
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
                        else -- error

                        end if;

                    ------------------ STATE 2 Questions, Comments, & Concerns --------------------
                    -- (1) How do we handle the last "error" condition where a bad opcode is provided from memory?
                    --     Would we need to handle this with an assert and report statement? If so, what severity level?
                    --
                    -------------------------------------------------------------------------------
                    when 3 => -- ALU op (Step1):  load op1 register from the regfile

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        regfile_index <= operand1; -- The register_index
                        regfile_readnotwrite <= '1'; -- Needs to be high because we're doing a read (ignores data_in signal)
                        regfile_clk <= '1'; -- Needs to be high for a regfile operation
                        mem_clk <= '0';
                        --mem_readnotwrite <= '#';
                        ir_clk <= '0';
                        imm_clk <= '0';
                        addr_clk <= '0';
                        pc_clk <= '0';
                        op1_clk <= '1'; -- op1_register clock needs to be high so it can accept regfile data_out
                        op2_clk <= '0';
                        result_clk <= '0';


                    ------------------ STATE 3 Questions, Comments, & Concerns --------------------
                    -- (1) The cycle-by-cycle semantics does not state we write to the register file before reading from it
                    --     at the specified register index. When is the write operation supposed to occur?
                    -- (2) Does op2_register clock need to be set to low?
                    -------------------------------------------------------------------------------

                        state := 4;
                    when 4 => -- ALU op (Step2): load op2 register from the regfile

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        regfile_index <= operand2; -- The register_index
                        regfile_readnotwrite <= '1'; -- Needs to be high because we're doing a read
                        regfile_clk <= '1'; -- Needs to be high for regfile operation
                        mem_clk <= '0';
                        --mem_readnotwrite <= '#';
                        ir_clk <= '0';
                        imm_clk <= '0';
                        addr_clk <= '0';
                        pc_clk <= '0';
                        op1_clk <= '0';
                        op2_clk <= '1'; -- op2_register clock needs to be high for receiving reg_file data_out
                        result_clk <= '0';


                    ------------------ State 4 Questions, Comments, & Concerns --------------------
                    -- (1) Does op1_register clock need to be set to low so its value from State 3 is retained?
                    --     If op1_clk is instead low, does its register's out_val change or is the register
                    --     output signal somehow no longer being propagated?
                    --
                    -------------------------------------------------------------------------------

                        state := 5;
                    when 5 => -- ALU op (Step3):  perform ALU operation (Copy ALU output into result register)

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        alu_func <= opcode(3 downto 0); -- The specific ALU operation denoted by the last 4 bits of the opcode
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        regfile_clk <= '0';
                        mem_clk <= '0';
                        --mem_readnotwrite <= '#';
                        ir_clk <= '0';
                        imm_clk <= '0';
                        addr_clk <= '0';
                        pc_clk <= '0';
                        op1_clk <= '0';
                        op2_clk <= '0';
                        result_clk <= '1'; -- Need to add ALU operation value to result register




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

                        regfilein_mux <= "00"; -- 3-way mux select for result
                        memaddr_mux <= "10"; -- memory address in mux select input_2
                        --addr_mux <= '#';
                        pc_mux <= '0'; -- pcplusone_out
                        --alu_func <= opcode(3 downto 0);
                        regfile_index <= destination;
                        regfile_readnotwrite <= '0'; -- Write back to destination
                        regfile_clk <= '1'; -- Needs to be high, if not already
                        mem_clk <= '0';
                        --mem_readnotwrite <= '0';
                        ir_clk <= '0';
                        imm_clk <= '0';
                        addr_clk <= '0';
                        pc_clk <= '1'; -- To increment PC
                        op1_clk <= '0';
                        op2_clk <= '0';
                        result_clk <= '0';



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
                            pc_clk <= '1';
                            pc_mux <= '0'; -- pcplusone_out

                            --regfilein_mux <= "##";
                            memaddr_mux <= "01"; -- mux select read from address register output
                            addr_mux <= '1'; -- input_1 select of mem_out
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            regfile_clk <= '0';
                            mem_clk <= '1';
                            mem_readnotwrite <= '1'; -- Memory Read operation
                            ir_clk <= '0';
                            imm_clk <= '0';
                            addr_clk <= '1';
                            op1_clk <= '0';
                            op2_clk <= '0';
                            result_clk <= '0';
                        else
                        -- load immediate value into register destination
                        -- Increment PC. Copy memory specified by PC into immediate register
                        -- PC -> PC+1. Mem[PC] --> Immed
                            pc_clk <= '1';
                            pc_mux <= '0'; -- pcplusone_out

                            --regfilein_mux <= "##";
                            memaddr_mux <= "00";
                            --addr_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            regfile_clk <= '0';
                            mem_clk <= '1';
                            mem_readnotwrite <= '1';
                            ir_clk <= '0';
                            imm_clk <= '1';
                            addr_clk <= '0';
                            op1_clk <= '0';
                            op2_clk <= '0';
                            result_clk <= '0';

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
                            regfilein_mux <= "01"; -- mux selector for memory out
                            memaddr_mux <= "01"; -- mux selector input_1 for address register output
                            addr_mux <= '1';
                            --alu_func <= opcode(3 downto 0);
                            regfile_index <= destination;
                            regfile_readnotwrite <= '0';
                            regfile_clk <= '1';
                            mem_clk <= '1';
                            mem_readnotwrite <= '1';
                            ir_clk <= '1';
                            imm_clk <= '0';
                            addr_clk <= '0';
                            op1_clk <= '0';
                            op2_clk <= '0';
                            result_clk <= '0';

                            pc_clk <= '1';
                            pc_mux <= '0';

                        else
                        -- Copy immediate register into the destination register. Increment PC.
                        -- Immed --> Regs[IR[dest]]. PC --> PC+1.
                            regfilein_mux <= "10"; -- mux selector for immediate register out
                            memaddr_mux <= "00"; -- mux selector input_0 for PC output
                            --addr_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            regfile_index <= destination;
                            regfile_readnotwrite <= '0';
                            regfile_clk <= '1';
                            mem_clk <= '1';
                            mem_readnotwrite <= '1';
                            ir_clk <= '1';
                            imm_clk <= '1';
                            addr_clk <= '0';
                            op1_clk <= '0';
                            op2_clk <= '0';
                            result_clk <= '0';


                            pc_clk <= '1';
                            pc_mux <= '0';

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
                        pc_mux <= '0';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        pc_clk <= '1';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 10;
                    when 10 => -- STO (Step2): Store contents of Register op1 specified by address word 2
                    -- Load memory at address given by PC to the address register: Mem[PC] --> Addr.

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 11;
                    when 11 => -- STO (Step3): Store contents of Register op1 specified by address word 2
                    -- Store contents of src register to address in memory given by address register,
                    -- then increment PC. Regs[IR[src]] --> Mem[Addr]. PC -> PC+1

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 1;
                    when 12 => -- LDR (Step1): Copy contents of op1 reg to Address register:
                    -- Regs[IR[op1]] --> Addr

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 13;
                    when 13 => -- LDR (Step2): Copy contents of memory specified by Address register to destination register:
                    -- Mem[Addr] --> Regs[IR[dest]]. Increment PC --> PC+1.

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 1;
                    when 14 => -- STOR (Step1): Copy contents of dest reg into Address Register:
                    -- Regs[IR[dest]] --> Addr
                    -- your code here

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 15;
                    when 15 => -- STOR (Step2): Copy contents of op1 register to Memory address specified by Address register:
                    -- Regs[IR[op1]] --> Mem[Addr]. Increment PC --> PC+1

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';


                        state := 1;
                    when 16 => -- JMP or JZ (Step1): Increment PC --> PC+1

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';

                        state := 17;
                    when 17 => -- JMP or JZ (Step2):

                        if (opcode = x"40") then -- JMP
                        -- Load memory specified by PC to Address register: Mem[PC] --> Addr

                            --regfilein_mux <= "##";
                            --memaddr_mux <= "##";
                            --addr_mux <= '#';
                            --pc_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            --regfile_clk <= '#';
                            --mem_clk <= '#';
                            --mem_readnotwrite <= '#';
                            --ir_clk <= '#';
                            --imm_clk <= '#';
                            --addr_clk <= '#';
                            --pc_clk <= '#';
                            --op1_clk <= '#';
                            --op2_clk <= '#';
                            --result_clk <= '#';

                        else -- JZ
                        -- Load memory specified by PC to Address register: Mem[PC] --> Addr,
                        -- then copy register op1 to control: Regs[IR[op1]] --> Ctl

                            --regfilein_mux <= "##";
                            --memaddr_mux <= "##";
                            --addr_mux <= '#';
                            --pc_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            --regfile_clk <= '#';
                            --mem_clk <= '#';
                            --mem_readnotwrite <= '#';
                            --ir_clk <= '#';
                            --imm_clk <= '#';
                            --addr_clk <= '#';
                            --pc_clk <= '#';
                            --op1_clk <= '#';
                            --op2_clk <= '#';
                            --result_clk <= '#';

                        end if;

                        state := 18;
                    when 18 => -- JMP or JZ (Step3):

                        if (opcode = x"40") then -- JMP
                        -- Load Addr to PC: Addr --> PC

                            --regfilein_mux <= "##";
                            --memaddr_mux <= "##";
                            --addr_mux <= '#';
                            --pc_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            --regfile_clk <= '#';
                            --mem_clk <= '#';
                            --mem_readnotwrite <= '#';
                            --ir_clk <= '#';
                            --imm_clk <= '#';
                            --addr_clk <= '#';
                            --pc_clk <= '#';
                            --op1_clk <= '#';
                            --op2_clk <= '#';
                            --result_clk <= '#';

                        else -- JZ
                        -- If Result == 0, copy Addr to PC: Addr --> PC, else increment PC --> PC+1

                            --regfilein_mux <= "##";
                            --memaddr_mux <= "##";
                            --addr_mux <= '#';
                            --pc_mux <= '#';
                            --alu_func <= opcode(3 downto 0);
                            --regfile_index <= destination, operand1, operand2;
                            --regfile_readnotwrite <= '#';
                            --regfile_clk <= '#';
                            --mem_clk <= '#';
                            --mem_readnotwrite <= '#';
                            --ir_clk <= '#';
                            --imm_clk <= '#';
                            --addr_clk <= '#';
                            --pc_clk <= '#';
                            --op1_clk <= '#';
                            --op2_clk <= '#';
                            --result_clk <= '#';

                        end if;

                        state := 1;
                    when 19 => -- NOOP: Only increments PC

                        --regfilein_mux <= "##";
                        --memaddr_mux <= "##";
                        --addr_mux <= '#';
                        --pc_mux <= '#';
                        --alu_func <= opcode(3 downto 0);
                        --regfile_index <= destination, operand1, operand2;
                        --regfile_readnotwrite <= '#';
                        --regfile_clk <= '#';
                        --mem_clk <= '#';
                        --mem_readnotwrite <= '#';
                        --ir_clk <= '#';
                        --imm_clk <= '#';
                        --addr_clk <= '#';
                        --pc_clk <= '#';
                        --op1_clk <= '#';
                        --op2_clk <= '#';
                        --result_clk <= '#';
                        state := 1;
                    when 20 =>
                    -- Unsure if this state is used or unused yet.
                    when others => null;
                end case;
            elsif clock'event and clock = '0' then
            -- reset all the register clocks
                regfile_clk <= '0';
                mem_clk <= '0';
                mem_readnotwrite <= '0';
                ir_clk <= '0';
                imm_clk <= '0';
                addr_clk <= '0';
                pc_clk <= '0';
                op1_clk <= '0';
                op2_clk <= '0';
                result_clk <= '0';
            end if;
        end process behav;
end behavior;
