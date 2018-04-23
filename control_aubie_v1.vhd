
use work.bv_arithmetic.all;
use work.dlx_types.all;



entity aubie_controller is
    generic(
        prop_delay    : Time := 5 ns;
        xt_prop_delay : Time := 15 ns -- Extended prop_delay for allowing other signals to propagate first
    ); -- Controller propagation delay
    port(
      ir_control            :   in dlx_word;
      alu_out               :   in dlx_word;
      alu_error             :   in error_code;
      clock                 :   in bit;
      regfilein_mux         :   out threeway_muxcode;
      memaddr_mux           :   out threeway_muxcode;
      addr_mux              :   out bit;
      pc_mux                :   out threeway_muxcode;
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

        type state_type is range 1 to 20; -- Will possibly need more states if we implement jump operations
        variable state: state_type := 1;
        variable opcode: byte;
        variable destination, operand1, operand2 : register_index;
        variable stor_op : alu_operation_code := "0111";
        variable jz_op : alu_operation_code := "1100";
        variable logical_true : dlx_word := x"00000001";
        variable logical_false : dlx_word := x"00000000";

        begin
            if (clock'event and clock = '1') then
                opcode := ir_control(31 downto 24);
                destination := ir_control(23 downto 19);
                operand1 := ir_control(18 downto 14);
                operand2 := ir_control(13 downto 9);

                -- NOTE: Variable stor_op will be used in STOR operation State 15 so we can have a result for memory writeback.
                --       For implementation and testing, stor_op should be the ALU function code for Bitwise AND because this
                --       should ensure that the ALU output will be the exact value specified by the register index

                case (state) is
                    when 1 => -- (fetch the instruction, for all types)
                    -- Load the 32-bit memory word stored at the address in the PC to the Instruction Register:
                    -- Mem[PC] --> IR
                        memaddr_mux <= "00" after prop_delay; -- memory threeway_mux input_0 to read from PC
                        pc_mux	<= "01" after prop_delay; -- Initially, this will tell memory to output data_memory(0)
                        regfile_clk <= '0' after prop_delay;
                        mem_clk	<= '1' after prop_delay; -- High so it can output mem_out
                        mem_readnotwrite <= '1' after prop_delay; -- In state 1, we want to read from main memory and ignore data_in
                        ir_clk <= '1' after prop_delay; -- High so IR will be receiving signal from Memory[PC]
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '1' after prop_delay; -- High so PC will output the current address it retains
                        op1_clk	<= '0' after prop_delay;
                        op2_clk	<= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;
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
                        regfile_index <= operand1 after prop_delay; -- The register_index
                        -- Needs to be high because we're doing a read op (ignore data_in and send regfile[reg_number] -> to op1 register)
                        regfile_readnotwrite <= '1' after prop_delay;
                        regfile_clk <= '1' after prop_delay; -- Needs to be high for a regfile operation
                        mem_clk <= '0' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '1' after prop_delay; -- op1_register clock needs to be high so it can accept regfile data_out
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;
                        state := 4;
                    when 4 => -- ALU op (Step2): load op2 register from the regfile
                        regfile_index <= operand2 after prop_delay; -- The register_index
                        regfile_readnotwrite <= '1' after prop_delay; -- Needs to be high because we're doing a read
                        regfile_clk <= '1' after prop_delay; -- Needs to be high for regfile operation
                        mem_clk <= '0' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '1' after prop_delay; -- op2_register clock needs to be high for receiving reg_file data_out
                        result_clk <= '0' after prop_delay;
                        state := 5;
                    when 5 => -- ALU op (Step3):  perform ALU operation (Copy ALU output into result register)
                        alu_func <= opcode(3 downto 0) after prop_delay; -- The specific ALU operation denoted by the last 4 bits of the opcode
                        regfile_clk <= '0' after prop_delay;
                        mem_clk <= '0' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '1' after prop_delay; -- Need to add ALU operation value to result register
                        state := 6;
                    when 6 => -- ALU op (Step4): write back ALU operation
                        regfilein_mux <= "00" after prop_delay; -- 3-way mux select for result
                        pc_mux <= "00" after prop_delay; -- pcplusone_out
                        regfile_index <= destination after prop_delay;
                        regfile_readnotwrite <= '0' after prop_delay; -- Write back to destination
                        regfile_clk <= '1' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay;
                        pc_clk <= '1' after prop_delay; -- To increment PC
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;
                        state := 1;
                    when 7 => -- LD or LDI (Step1): get the addr or immediate word
                        if (opcode = x"30") then -- LD
                        -- load contents of address to register destination
                        -- Increment PC. Copy memory specified by PC into address register
                        -- PC -> PC+1. Mem[PC] --> Addr
                            pc_clk <= '1' after prop_delay;
                            pc_mux <= "00" after prop_delay; -- pcplusone_out
                            memaddr_mux <= "00" after prop_delay; -- mux select read from pcplusone_out
                            addr_mux <= '1' after prop_delay; -- input_1 select of mem_out
                            regfile_clk <= '0' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay; -- Memory Read operation
                            ir_clk <= '0' after prop_delay;
                            imm_clk <= '0' after prop_delay;
                            addr_clk <= '1' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;
                        elsif (opcode = x"31") then -- LDI
                        -- load immediate value into register destination
                        -- Increment PC. Copy memory specified by PC into immediate register
                        -- PC -> PC+1. Mem[PC] --> Immed
                            pc_clk <= '1' after prop_delay;
                            pc_mux <= "00" after prop_delay; -- pcplusone_out
                            memaddr_mux <= "00" after prop_delay;
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
                        state := 8;
                    when 8 => -- LD or LDI (Step2)

                        if (opcode = x"30") then -- LD
                        -- Copy mem location specified by Address to the destination register. Increment PC.
                        -- Mem[Addr] --> Regs[IR[dest]]. PC --> PC+1.
                            regfilein_mux <= "01" after prop_delay; -- mux selector for memory out
                            memaddr_mux <= "01" after prop_delay; -- mux selector input_1 for address register output
                            --addr_mux <= '#' after prop_delay;
                            regfile_index <= destination after prop_delay;
                            regfile_readnotwrite <= '0' after prop_delay;
                            regfile_clk <= '1' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay;
                            ir_clk <= '0' after prop_delay;
                            imm_clk <= '0' after prop_delay;
                            addr_clk <= '0' after prop_delay; -- Addr clk should retain its old value
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;
                            pc_clk <= '0' after prop_delay, '1' after xt_prop_delay;
                            pc_mux <= "00" after xt_prop_delay;
                            -- NOTE: We don't want to increment PC until AFTER other values are propagated because we want the mux to read from the address register first.

                        elsif (opcode = x"31") then -- LDI
                        -- Copy immediate register into the destination register. Increment PC.
                        -- Immed --> Regs[IR[dest]]. PC --> PC+1.
                            regfilein_mux <= "10" after prop_delay; -- mux selector for immediate register out
                            regfile_index <= destination after prop_delay;
                            regfile_readnotwrite <= '0' after prop_delay;
                            regfile_clk <= '1' after prop_delay;
                            mem_clk <= '0' after prop_delay;
                            ir_clk <= '0' after prop_delay;
                            imm_clk <= '1' after prop_delay;
                            addr_clk <= '0' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;
                            pc_clk <= '1' after prop_delay; -- Set clock to high
                            pc_mux <= "00" after prop_delay; -- Increment PC (Note: Since we're not relying on a PC address, we can increment the PC at any time in this sub-state. We just have to make sure it's done at some point.)

                        end if;

                        state := 1;
                    when 9 => -- STO (Step1): Store contents of Register op1 specified by address word 2
                    -- Increment PC.
                        pc_mux <= "00" after prop_delay;
                        pc_clk <= '1' after prop_delay;
                        state := 10;
                    when 10 => -- STO (Step2): Store contents of Register op1 specified by address word 2
                    -- Load memory at address given by PC to the address register: Mem[PC] --> Addr.

                        memaddr_mux <= "00" after prop_delay; -- We want mem_address specified by PC
                        addr_mux <= '1' after prop_delay; -- Address register needs to accept value from memory
                        regfile_clk <= '0' after prop_delay;
                        mem_clk <= '1' after prop_delay; -- Memory unit needs to be on
                        mem_readnotwrite <= '1' after prop_delay; -- For reading to address register
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '1' after prop_delay; -- We're writing to address register so the register needs to be on
                        pc_clk <= '1' after prop_delay; -- We incremented in the last state, so PC should have an out value
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;

                        state := 11;
                    when 11 => -- STO (Step3): Store contents of Register op1 specified by address word 2
                    -- Store contents of src register to address in memory given by address register,
                    -- then increment PC. Regs[IR[src]] --> Mem[Addr]. PC -> PC+1
                    ------------------AKA Regs[IR[op1 (Bits 18-14)]] --> Mem[Addr]

                        memaddr_mux <= "00" after prop_delay;
                        pc_mux <= "01" after prop_delay, "00" after xt_prop_delay;
                        regfile_index <= operand1 after prop_delay;
                        regfile_readnotwrite <= '1' after prop_delay; -- We're reading from register file at index operand1
                        regfile_clk <= '1' after prop_delay;
                        mem_clk <= '1' after prop_delay; -- Turn on memory component
                        mem_readnotwrite <= '0' after prop_delay; -- Here we want to write to Memory
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay; -- Turn off addr cause we want to retain its output from State 10
                        pc_clk <= '1' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;
                        state := 1;
                    when 12 => -- LDR (Step1): Copy contents of op1 reg to Address register:
                    -- Regs[IR[op1]] --> Addr
                        addr_mux <= '0' after prop_delay; -- Here we want the register file output
                        regfile_index <= operand1 after prop_delay;
                        regfile_readnotwrite <= '1' after prop_delay;
                        regfile_clk <= '1' after prop_delay;
                        mem_clk <= '0' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '1' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;

                        state := 13;
                    when 13 => -- LDR (Step2): Copy contents of memory specified by Address register to destination register:
                    -- Mem[Addr] --> Regs[IR[dest]]. Increment PC --> PC+1.

                        regfilein_mux <= "01" after prop_delay; -- mux selector for memory out
                        memaddr_mux <= "01" after prop_delay; -- mux selector input_1 for address register output
                        --addr_mux <= '#' after prop_delay;
                        regfile_index <= destination after prop_delay;
                        regfile_readnotwrite <= '0' after prop_delay;
                        regfile_clk <= '1' after prop_delay;
                        mem_clk <= '1' after prop_delay;
                        mem_readnotwrite <= '1' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay; -- Addr clk should retain its old value
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;
                        pc_clk <= '0' after prop_delay, '1' after xt_prop_delay;
                        pc_mux <= "00" after xt_prop_delay;
                        -- NOTE: We don't want to increment PC until AFTER other values are propagated because we want the mux to read from the address register first.

                        state := 1;
                    when 14 => -- STOR (Step1): Copy contents of dest reg into Address Register:
                    -- Regs[IR[dest]] --> Addr

                        addr_mux <= '0' after prop_delay;
                        regfile_index <= destination after prop_delay;
                        regfile_readnotwrite <= '1' after prop_delay;
                        regfile_clk <= '1' after prop_delay;
                        mem_clk <= '0' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '1' after prop_delay;
                        pc_clk <= '0' after prop_delay;
                        op1_clk <= '0' after prop_delay;
                        op2_clk <= '0' after prop_delay;
                        result_clk <= '0' after prop_delay;

                        state := 15;
                    when 15 => -- STOR (Step2): Copy contents of op1 register to Memory address specified by Address register:
                    -- Regs[IR[op1]] --> Mem[Addr]. Increment PC --> PC+1

                        -- FOR STOR to work, we need to do Bitwise AND of op1 and op2 so the result will be whatever unchanged value we read from the specified register file index.

                        memaddr_mux <= "00" after prop_delay;
                        pc_mux <= "01" after prop_delay, "00" after xt_prop_delay;
                        alu_func <= stor_op after prop_delay;
                        regfile_index <= operand1 after prop_delay;
                        regfile_readnotwrite <= '1' after prop_delay;
                        regfile_clk <= '1' after prop_delay;
                        mem_clk <= '1' after prop_delay;
                        mem_readnotwrite <= '0' after prop_delay;
                        ir_clk <= '0' after prop_delay;
                        imm_clk <= '0' after prop_delay;
                        addr_clk <= '0' after prop_delay; -- Turn off addr to retain output from State 14
                        pc_clk <= '1' after prop_delay;
                        op1_clk <= '1' after prop_delay; -- op1 AND op2 is either of op1 OR op2, it doesn't matter here
                        op2_clk <= '1' after prop_delay;
                        result_clk <= '1' after prop_delay;
                        state := 1;
                    when 16 => -- JMP or JZ (Step1): Increment PC --> PC+1
                        pc_mux <= "00" after prop_delay;
                        pc_clk <= '1' after prop_delay;
                        state := 17;
                    when 17 => -- JMP or JZ (Step2):

                        if (opcode = x"40") then -- JMP
                        -- Load memory specified by PC to Address register: Mem[PC] --> Addr
                        -- Same thing as State 7 except no need to increment since that was already done in State 16

                            pc_clk <= '0' after prop_delay;
                            memaddr_mux <= "00" after prop_delay; -- mux select read from pcplusone_out
                            addr_mux <= '1' after prop_delay; -- input_1 select of mem_out
                            regfile_clk <= '0' after prop_delay;
                            mem_clk <= '1' after prop_delay;
                            mem_readnotwrite <= '1' after prop_delay; -- Memory Read operation
                            ir_clk <= '0' after prop_delay;
                            imm_clk <= '0' after prop_delay;
                            addr_clk <= '1' after prop_delay;
                            op1_clk <= '0' after prop_delay;
                            op2_clk <= '0' after prop_delay;
                            result_clk <= '0' after prop_delay;
                        end if;
                        if (opcode = x"41") then -- JZ --> DO everything in the above condition +
                        -- copy register op1 to control: Regs[IR[op1]] --> Ctl
                            alu_func <= jz_op after xt_prop_delay;
                            regfile_index <= operand1 after xt_prop_delay;
                            regfile_readnotwrite <= '1' after xt_prop_delay;
                            regfile_clk <= '1' after xt_prop_delay;
                            mem_clk <= '0' after xt_prop_delay;
                            ir_clk <= '0' after xt_prop_delay;
                            imm_clk <= '0' after xt_prop_delay;
                            addr_clk <= '0' after xt_prop_delay;
                            pc_clk <= '0' after xt_prop_delay;
                            op1_clk <= '1' after xt_prop_delay;
                            op2_clk <= '1' after xt_prop_delay;
                            result_clk <= '0' after xt_prop_delay;

                            -- ??? Verify correctness for sub-state JZ (this) --
                            -- The idea we are going with is that the alu_out signal is received by ctl
                            -- This is validated by the interconnect port mapping (line 45)
                            -- We are attempting to send logical_true/logical_false for op1 == 0 so we can retrieve
                            -- the result in state 18. We'll check alu_out in state 18
                        end if;
                        state := 18;
                    when 18 => -- JMP or JZ (Step3):
                        if (opcode = x"40") then -- JMP
                        -- Load Addr to PC: Addr --> PC
                            pc_mux <= "01" after prop_delay;
                            pc_clk <= '1' after prop_delay;
                        elsif (opcode = x"41") then-- JZ
                        -- If Result == 0, copy Addr to PC: Addr --> PC, else increment PC --> PC+1
                            if (alu_out = logical_true) then
                                pc_mux <= "01" after prop_delay;
                                pc_clk <= '1' after prop_delay;
                            elsif (alu_out = logical_false) then
                                pc_clk <= '1' after prop_delay;
                                pc_mux <= "00" after prop_delay;
                            end if;
                        end if;
                        state := 1;
                    when 19 => -- NOOP: Only increments PC
                        pc_mux <= "00" after prop_delay;
                        pc_clk <= '1' after prop_delay;
                        state := 1;
                    when others => null;
                end case;
            elsif clock'event and clock = '0' then
            -- reset all register clocks. State 1 should set appropriate values during fetch
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
