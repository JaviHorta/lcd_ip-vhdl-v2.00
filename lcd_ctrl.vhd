
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity lcd_ctrl is
  port (clk : in std_logic;
        rst : in std_logic;
        data_in : in std_logic_vector(0 to 7);
        stb : in std_logic;
        rs : in std_logic;
        rdy : out std_logic;
        lcd_rs : out std_logic;
        lcd_en : out std_logic;
        lcd_rw : out std_logic;
        data_out : out std_logic_vector(0 to 7)
  );
end entity;

architecture rtl of lcd_ctrl is

component lcd_tx_fsm is
    port(
        clk : in std_logic;
        rst : in std_logic;
        byte_in : in std_logic_vector(0 to 7);  
        stb : in std_logic;                     
        rs : in std_logic;                      
        rdy : out std_logic;                    
        lcd_rs : out std_logic;                 
        lcd_en : out std_logic;                 
        lcd_rw : out std_logic;                 
        lcd_data: out std_logic_vector(0 to 7)  
    );
end component;

component init_lcd_fsm is
port (
    clk : in std_logic;
    rst : in std_logic;
    rdy : in std_logic;
    init_done : out std_logic;
    data : out std_logic_vector(0 to 7);
    stb : out std_logic;
    rs : out std_logic
);
end component;

signal sig_rdy, sig_rs, rs_init_fsm, init_done, stb_init_fsm, stb_tx : std_logic;
signal init_data, data_tx : std_logic_vector(0 to 7);

begin

    inst_lcd_tx_fsm: lcd_tx_fsm
    port map(
        clk => clk,
        rst => rst,
        byte_in => data_tx,
        stb => stb_tx,
        rs => sig_rs,
        rdy => sig_rdy,
        lcd_rs => lcd_rs,
        lcd_en => lcd_en,
        lcd_rw => lcd_rw,
        lcd_data => data_out
    );

    inst_init_lcd_fsm: init_lcd_fsm
    port map(
        clk => clk,
        rst => rst,
        rdy => sig_rdy,
        init_done => init_done,
        data => init_data,
        stb => stb_init_fsm,
        rs => rs_init_fsm
    );

    stb_tx <= stb when init_done = '1' else stb_init_fsm;
    data_tx <= data_in when init_done = '1' else init_data;
    sig_rs <= rs when init_done = '1' else rs_init_fsm;
    rdy <= sig_rdy;

end architecture;
