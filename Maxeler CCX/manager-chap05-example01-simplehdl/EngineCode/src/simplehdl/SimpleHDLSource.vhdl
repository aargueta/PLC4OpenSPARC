-- Document: Manager Compiler Tutorial (maxcompiler-manager-tutorial.pdf)
-- Chapter: 7      Example: 1      Name: Simple HDL
-- MaxFile name: SimpleHDL
-- Summary:
--     VHDL code for a counter that counts up to max_data and back down again.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_hdl is
    port (
        -- external IP block can have any number of clock domains
        -- each streaming interface is synchronous to one of the clock domains
        -- each clock domain has a synchronous reset (controllable by host software)
        clk : in std_logic;
        rst : in std_logic;

        -- pull input streaming interface "max" (synchronous to clock)
        max_empty : in std_logic;
        max_almost_empty : in std_logic;
        max_read : out std_logic;
        max_data : in std_logic_vector(31 downto 0);

        -- push output streaming interface "count" (synchronous to clock)
        count_valid : out std_logic;
        count_stall : in std_logic;
        count_data : out std_logic_vector(31 downto 0)
    );
end entity simple_hdl;

architecture rtl of simple_hdl is
    signal counter : unsigned(31 downto 0) := (others => '0');
    signal hold_counter : unsigned(31 downto 0) := (others => '0');
    constant hold_count : integer := 2;
    signal data_ready : std_logic := '0';
    signal output_data : unsigned(31 downto 0) := (others => '0');
    signal output_valid : std_logic := '0';
    type MODE_TYPE is ( COUNTING_UP, COUNTING_DOWN, HOLD );
    signal mode : MODE_TYPE;
begin

    -- set the read signal if the input is not empty and the output is not stalled
    max_read <= not max_empty and not count_stall;

    counter_process : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= (others => '0');
                hold_counter <= (others => '0');
                data_ready <= '0';
                output_data <= (others => '0');
                output_valid <= '0';
                mode <= COUNTING_UP;
            else
                -- we will only have data if the input is not empty and the output is not stalled
                data_ready <= not max_empty and not count_stall;
                
                output_valid <= '0';
                if (data_ready = '1') then
                    counter <= counter;
                    case mode is
                        when COUNTING_UP =>
                            if counter = unsigned(max_data) then
                                mode <= HOLD;
                            else
                                if counter > unsigned(max_data) then
                                    counter <= unsigned(max_data);
                                    mode <= HOLD;
                                else
                                    counter <= counter + 1;
                                end if;
                            end if;
                        when COUNTING_DOWN =>
                            if counter = 0 then
                                counter <= counter + 1;
                                mode <= COUNTING_UP;
                            else
                                counter <= counter - 1;
                            end if;
                        when others =>
                            if hold_counter = hold_count then
                                hold_counter <= (others => '0');
                                mode <= COUNTING_DOWN;
                            else
                                hold_counter <= hold_counter+1;
                            end if;
                    end case;
                    output_valid <= '1';
                    output_data <= counter;
                end if;
            end if;
        end if;
    end process;

    -- pass on the registered values of the outputs
    count_valid <= output_valid;
    count_data <= std_logic_vector(output_data);
end rtl;
