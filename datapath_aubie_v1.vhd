-- datapath_aubie.vhd

-- entity reg_file (lab 2)
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity reg_file is
    generic(prop_delay : Time := 15 ns);
    port (
        data_in     :   in dlx_word;
        readnotwrite:   in bit;
        clock       :   in bit;
	    data_out    :   out dlx_word;
        reg_number  :   in register_index
    );
end entity reg_file;


-- entity alu (lab 3)
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity alu is
    generic(prop_delay : Time := 5 ns);
    port(
        operand1  :   in dlx_word;
        operand2  :   in dlx_word;
        operation :   in alu_operation_code;
        result    :   out dlx_word;
        error     :   out error_code
    );
end entity alu;

-- alu_operation_code values
-- 0000 unsigned add
-- 0001 signed add
-- 0010 2's compl add
-- 0011 2's compl sub
-- 0100 2's compl mul
-- 0101 2's compl divide
-- 0110 logical and
-- 0111 bitwise and
-- 1000 logical or
-- 1001 bitwise or
-- 1010 logical not (op1)
-- 1011 bitwise not (op1)
-- 1100-1111 output all zeros

-- error code values
-- 0000 = no error
-- 0001 = overflow (too big positive)
-- 0010 = underflow (too small neagative)
-- 0011 = divide by zero

-- entity dlx_register (lab 3)
use work.dlx_types.all;

entity dlx_register is
    generic(prop_delay : Time := 5 ns);
    port(
        in_val  :   in dlx_word;
        clock   :   in bit;
        out_val :   out dlx_word
    );
end entity dlx_register;



-- entity pcplusone
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity pcplusone is
	generic(prop_delay: Time := 5 ns);
	port (
        input : in dlx_word;
        clock : in bit;
        output: out dlx_word
    );
end entity pcplusone;

architecture behavior of pcplusone is
begin
    plusone: process(input, clock) is  -- add clock input to make it execute
        variable newpc: dlx_word;
        variable error: boolean;
    begin
        if clock'event and clock = '1' then
            bv_addu(input,"00000000000000000000000000000001",newpc,error);
            output <= newpc after prop_delay;
        end if;
    end process plusone;
end architecture behavior;


-- entity mux
use work.dlx_types.all;

entity mux is
     generic(prop_delay : Time := 5 ns);
     port (
            input_1 : in dlx_word;
            input_0 : in dlx_word;
            which   : in bit;
            output  : out dlx_word
     );
end entity mux;

architecture behavior of mux is
begin
   muxProcess : process(input_1, input_0, which) is
   begin
      if (which = '1') then
         output <= input_1 after prop_delay;
      else
         output <= input_0 after prop_delay;
      end if;
   end process muxProcess;
end architecture behavior;
-- end entity mux

-- entity threeway_mux
use work.dlx_types.all;

entity threeway_mux is
    generic(prop_delay : Time := 5 ns);
    port (
        input_2 : in dlx_word;
        input_1 : in dlx_word;
        input_0 : in dlx_word;
        which   : in threeway_muxcode;
        output  : out dlx_word
    );
end entity threeway_mux;

architecture behavior of threeway_mux is
begin
   muxProcess : process(input_1, input_0, which) is
   begin
      if (which = "10" or which = "11" ) then
         output <= input_2 after prop_delay;
      elsif (which = "01") then
         output <= input_1 after prop_delay;
      else
         output <= input_0 after prop_delay;
      end if;
   end process muxProcess;
end architecture behavior;
-- end entity mux


-- entity memory
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity memory is
    port (
        address       :   in dlx_word;
        readnotwrite  :   in bit;
        data_out      :   out dlx_word;
        data_in       :   in dlx_word;
        clock         :   in bit
    );
end memory;

architecture behavior of memory is

begin  -- behavior

    mem_behav: process(address,clock) is
    -- note that there is storage only for the first 1k of the memory, to speed
    -- up the simulation
        type memtype is array (0 to 1024) of dlx_word;
        variable data_memory : memtype;
    begin
    -- fill this in by hand to put some values in there
    -- some instructions
        data_memory(0) :=  X"30200000"; --LD R4, 0x100
        data_memory(1) :=  X"00000100"; -- address 0x100 for previous instruction
        data_memory(2) :=  "00000000000110000100010000000000"; -- ADDU R3,R1,R2
        -- some data
        -- note that this code runs every time an input signal to memory changes,
        -- so for testing, write to some other locations besides these
        data_memory(256) := "01010101000000001111111100000000";
        data_memory(257) := "10101010000000001111111100000000";
        data_memory(258) := "00000000000000000000000000000001";

        -- IMPORTANT NOTE: For STOR (State 15), use bits 13-9 for the ALU function Bitwise AND ("0111")
        --                 This is a format exception which will ensure that State 15 has a writeback value to memory data_in

        if clock = '1' then
          if readnotwrite = '1' then
            -- do a read
            data_out <= data_memory(bv_to_natural(address)) after 5 ns;
          else
            -- do a write
            data_memory(bv_to_natural(address)) := data_in;
          end if;
        end if;
  end process mem_behav;
end behavior;
-- end entity memory
