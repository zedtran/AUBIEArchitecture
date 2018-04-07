LIBRARY work;
USE work.bv_arithmetic.ALL;
USE work.dlx_types.ALL;

--------------------------- Arithmetic-Logic Unit -------------------------------------------
-- This unit takes in two 32-bit values, and a 4-bit operation code
-- that specifies which ALU operation (eg. add, subtract, multiply, etc) is to be performed
-- on the two operands. For non commutative operations like subtract or divide, operand1
-- always goes on the left of the operator and operand2 on the right.
---------------------------------------------------------------------------------------------
--  The operation codes are
--  0000 = unsigned add
--  0001 = unsigned subtract
--  0010 = two’s complement add
--  0011 = two’s complement subtract
--  0100 = two’s complement multiply
--  0101 = two’s complement divide
--  0110 = logical AND
--  0111 = bitwise AND
--  1000 = logical OR
--  1001 = bitwise OR
--  1010 = logical NOT of operand1 (ignore operand2)
--  1011 = bitwise NOT of operand1 (ignore operand2)
--  1100-1111 = just output all zeroes
---------------------------------------------------------------------------------------------
--  The unit returns the 32-bit result of the operation and a 4-bit error code. The meaning of
--  the error code should be
--  0000 = no error
--  0001 = overflow
--  0010 = underflow
--  0011 = divide by zero
---------------------------------------------------------------------------------------------
entity ALU is
    Port (
        operand1      :    in dlx_word;  -- Operand 1 input 32-bit
        operand2      :    in dlx_word;  -- Operand 2 input 32-bit
        operation     :    in alu_operation_code; -- 4-bit Op Code from dlx_types
        result        :    out dlx_word;
        error         :    out error_code
    );
end entity ALU;


architecture behavior of ALU is
    -- Define any types here that will be used

begin
    alu_process: process(operand1, operand2, operation) is
          -- Declare any local variables here
          variable temp_result: dlx_word := x"00000000";
          variable logical_true: dlx_word := x"00000001";
          variable logical_false: dlx_word := x"00000000";
          variable overflow_flag_set: boolean;
          variable div_by_zero: boolean;
          variable op1_logical_status: bit; -- 0 means false; 1 means true
          variable op2_logical_status: bit; -- 0 means false; 1 means true

          begin
              error <= "0000"; -- Default value for port signal output error
              case(operation) is
                  when "0000" => -- UNSIGNED ADD
                      bv_addu(operand1, operand2, temp_result, overflow_flag_set);
                      if overflow_flag_set then
                          error <= "0001";
                      end if;
                      result <= temp_result;
                  when "0001" => -- UNSIGNED SUBTRACT
                      bv_subu(operand1, operand2, temp_result, overflow_flag_set);
                      if overflow_flag_set then
                          error <= "0010";
                          -- Unsigned subtract is only concerned with underflow
                      end if;
                      result <= temp_result;
                  when "0010" => -- TWO'S COMPLEMENT ADD
                      bv_add(operand1, operand2, temp_result, overflow_flag_set);
                      if overflow_flag_set then
                          -- IF (+A) + (+B) = -C
                          if operand1'high = '0' and operand2'high = '0' then
                              if temp_result'high = '1' then
                                  error <= "0001"; -- overflow occurred
                              end if;
                          -- (-A) + (−B) = +C
                          elsif operand1'high = '1' and operand2'high = '1' then
                              if temp_result'high = '0' then
                                  error <= "0010"; -- underflow occurred
                              end if;
                          end if;
                      end if;
                      result <= temp_result;
                  when "0011" => -- TWO'S COMPLEMENT SUBTRACT
                      bv_sub(operand1, operand2, temp_result, overflow_flag_set);
                      if overflow_flag_set then
                          -- IF (-A) - (+B) = +C
                          if operand1'high = '1' and operand2'high = '0' then
                              if temp_result'high = '0' then
                                  error <= "0010"; -- underflow occurred
                              end if;
                          -- (+A) − (−B) = −C
                          elsif operand1'high = '0' and operand2'high = '1' then
                              if temp_result'high = '1' then
                                  error <= "0001"; -- overflow occurred
                              end if;
                          end if;
                      end if;
                      result <= temp_result;
                  when "0100" => -- TWO'S COMPLEMENT MULTIPLY
                      bv_mult(operand1, operand2, temp_result, overflow_flag_set);
                      if overflow_flag_set then
                          if operand1'high = '1' and operand2'high = '0' then -- (-A x +B) = +C
                              error <= "0010"; -- underflow
                          elsif operand1'high '0' and operand2'high = '1' then -- (+A x -B) = +C
                              error <= "0010"; -- underflow
                          else -- (+A x +B) = -C OR (-A x -B) = -C
                              error <= "0001"; -- overflow
                          end if;
                      end if;
                      result <= temp_result;
                  when "0101" => -- TWO'S COMPLEMENT DIVIDE
                  ----------------------------------------------------------------------------------------
                  -- The only way a two's complement divide can underflow is if you divide the most
                  -- negative value by -ve 1. Divide underflow occurs when the divisor is much smaller
                  -- than the dividend. The result is almost zero. Test with 80000000 / FFFFFFFF
                  -- (Quotient will be smaller than the dividend)
                  -- NOTE: For grading purposes, this condition will not be tested but must be implemented
                  -----------------------------------------------------------------------------------------
                      bv_div(operand1, operand2, temp_result, div_by_zero, overflow_flag_set);
                      if div_by_zero then
                          error <= "0011"; --
                      elsif overflow_flag_set then
                          error <= "0010"; -- only an underflow can occur with divide (see note above)
                      end if;
                      result <= temp_result;
                  when "0110" => -- PERFORM LOGICAL AND
                  ------------------------------------------------------------------------
                  -- For logical operations, anything resulting in a non-zero value is 1,
                  -- for true. Anything resulting in a zero is assigned 0, false.
                  -- Logical operation always results in true (1) or false (0).
                  ------------------------------------------------------------------------
                      op1_logical_status := 0; -- Default logical status for operand1
                      op2_logical_status := 0; -- Default logical status for operand2
                      -- check if operand1 is a non-zero value --
                      for i in operand1'low to operand1'high loop -- 31 downto 0 loop
                          -- If non-zero value, operand1 is logical true;
                          if operand1(i) = '1' then
                              op1_logical_status := 1;
                              exit;
                          end if;
                      end loop;
                      -- check if operand2 is a non-zero value
                      for i in operand2'low to operand2'high loop -- 31 downto 0 loop
                          -- If non-zero value, operand2 is logical true;
                          if operand2(i) = '1' then
                              op2_logical_status := 1;
                              exit;
                          end if;
                      end loop;
                      -- IF operand statuses result in --> '1' && '1' = '1'
                      if ((op1_logical_status AND op2_logical_status) = '1') then
                          result <= logical_true; -- The result is logical true x"00000001"
                      else
                          result <= logical_false; -- Else result is logical false  x"00000000"
                      end if;
                  when "0111" => -- PERFORM BITWISE AND
                      for i in 31 downto 0 loop
                          temp_result(i) := operand1(i) AND operand2(i);
                      end loop;
                      result <= temp_result;
                  when "1000" => -- PERFORM LOGICAL OR
                  ------------------------------------------------------------------------
                  -- For logical operations, anything resulting in a non-zero value is 1,
                  -- for true. Anything resulting in a zero is assigned 0, false.
                  -- Logical operation always results in true (1) or false (0).
                  ------------------------------------------------------------------------
                      op1_logical_status := 0; -- Default logical status for operand 1
                      op2_logical_status := 0; -- Default logical status for operand 2
                      -- check if operand1 is a non-zero value --
                      for i in operand1'low to operand1'high loop -- 31 downto 0 loop
                          -- If non-zero value, operand1 is logical true;
                          if operand1(i) = '1' then
                              op1_logical_status := 1;
                              exit;
                          end if;
                      end loop;
                      -- check if operand2 is a non-zero value
                      for i in operand2'low to operand2'high loop -- 31 downto 0 loop
                          -- If non-zero value, operand2 is logical true;
                          if operand2(i) = '1' then
                              op2_logical_status := 1;
                              exit;
                          end if;
                      end loop;
                      -- IF operand statuses result in --> ('1'||'1' OR '1'||'0' OR '0'||'1' ) = '1'
                      if ((op1_logical_status OR op2_logical_status) = '1') then
                          result <= logical_true; -- The result is logical true x"00000001"
                      else
                          result <= logical_false; -- Else result is logical false  x"00000000"
                      end if;
                  when "1001" => -- PERFORM BITWISE OR
                      for i in 31 downto 0 loop
                          temp_result(i) := operand1(i) OR operand2(i);
                      end loop;
                      result <= temp_result;
                  when "1010" => -- PERFORM LOGICAL NOT OF OPERAND1 (ignore operand2)
                      temp_result := logical_false; -- Initially assigned to false (i.e. 32'h00000000)
                      for i in operand1'low to operand1'high loop -- 31 downto 0 loop
                          if NOT operand1(i) = '1' then
                              temp_result := logical_true; -- logical NOT resulted in true, assign true (i.e. 32'h00000001)
                              exit;
                          end if;
                      end loop;
                      result <= temp_result;
                  when "1011" => -- PERFORM BITWISE NOT OF OPERAND1 (ignore operand2)
                      for i in 31 downto 0 loop
                          temp_result(i) := NOT operand1(i);
                      end loop;
                      result <= temp_result;
                  when others => -- 1100 thru 1111 outputs all zeroes
                      result <= x"00000000";
              end case;
   end process alu_process;
end architecture behavior;
