library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity init_lcd_fsm is
port (
    clk : in std_logic;
    rst : in std_logic;
    rdy : in std_logic;
    init_done : out std_logic;
    data : out std_logic_vector(0 to 7);
    stb : out std_logic;
    rs : out std_logic
);
end init_lcd_fsm;

architecture behavorial of init_lcd_fsm is

type init_lcd_state is (WAIT_15M, FIRST_0x3W, WAIT_4p1M, SECOND_0x3W, WAIT_100U, THERTS_0x3W, WRITE_0x2, FUNCTON_SET_CMD, ENTRY_MODE_CMD, DISPLAY_ON_CMD, CLEAR_DISPLAY_CMD, WAIT_1p64M, INIT_FINISHED);

signal init_lcd_current_state, init_lcd_next_state : init_lcd_state;
signal count_reg, count_next : integer range 0 to 750000;

begin
    -- Transition logic
    process(clk, rst)
    begin
        if rst = '1' then
            init_lcd_current_state <= WAIT_15M;
            count_reg <= 0;
        elsif rising_edge(clk) then
            init_lcd_current_state <= init_lcd_next_state;
            count_reg <= count_next;
        end if;
    end process;

    -- Next state logic
    process(init_lcd_current_state, rdy, count_reg)
    begin
    init_lcd_next_state <= init_lcd_current_state;
	count_next <= count_reg;
        case init_lcd_current_state is
            when WAIT_15M =>
                if count_reg = 750000 then
                    count_next <= 0;
                    init_lcd_next_state <= FIRST_0x3W;
                else
                    count_next <= count_reg + 1;
                end if;
            
            when FIRST_0x3W =>
                if rdy = '1' then
                    init_lcd_next_state <= WAIT_4p1M;
                end if;

            when WAIT_4p1M =>
                if count_reg = 205000 then
                    count_next <= 0;
                    init_lcd_next_state <= SECOND_0x3W;
                else
                    count_next <= count_reg + 1;
                end if;

            when SECOND_0x3W =>
                if rdy = '1' then
                    init_lcd_next_state <= WAIT_100U;
                end if;

            when WAIT_100U =>
                if count_reg = 5000 then
                    count_next <= 0;
                    init_lcd_next_state <= THERTS_0x3W;
                else
                    count_next <= count_reg + 1;
                end if;
            
            when THERTS_0x3W =>
                if rdy = '1' then
                    init_lcd_next_state <= WRITE_0x2;
                end if;
            
            when WRITE_0x2 =>
                if rdy = '1' then
                    init_lcd_next_state <= FUNCTON_SET_CMD;
                end if;
            
            when FUNCTON_SET_CMD =>
                if rdy = '1' then
                    init_lcd_next_state <= ENTRY_MODE_CMD;
                end if;
            
            when ENTRY_MODE_CMD =>
                if rdy = '1' then
                    init_lcd_next_state <= DISPLAY_ON_CMD;
                end if;

            when DISPLAY_ON_CMD =>
                if rdy = '1' then
                    init_lcd_next_state <= CLEAR_DISPLAY_CMD;
                end if;
            
            when CLEAR_DISPLAY_CMD =>
                if rdy = '1' then
                    init_lcd_next_state <= WAIT_1p64M;
                end if;

            when WAIT_1p64M =>
                if count_reg = 82000 then
                    count_next <= 0;
                    init_lcd_next_state <= INIT_FINISHED;
                else
                    count_next <= count_reg + 1;
                end if;
            
            when INIT_FINISHED =>
                init_lcd_next_state <= INIT_FINISHED;
        end case;
    end process;

    with init_lcd_current_state select
        data <= "00000011" when FIRST_0x3W | SECOND_0x3W | THERTS_0x3W,
                "00000010" when WRITE_0x2,
                "00111000" when FUNCTON_SET_CMD,
                "00000110" when ENTRY_MODE_CMD,
                "00001100" when DISPLAY_ON_CMD,
                "00000001" when CLEAR_DISPLAY_CMD,
                "00000011" when others;
        
    with init_lcd_current_state select
        stb <= '1' when FIRST_0x3W | SECOND_0x3W | THERTS_0x3W | WRITE_0x2 | DISPLAY_ON_CMD | ENTRY_MODE_CMD | FUNCTON_SET_CMD | CLEAR_DISPLAY_CMD,
               '0' when others;

    init_done <= '1' when init_lcd_current_state = INIT_FINISHED else '0';
    rs <= '0';
    
end architecture;
