----------------------------------------------------------------------------------
-- Company: Technical University of Cluj-Napoca 
-- Engineer: Cristian Vancea
-- 
-- Module Name: test_env - Behavioral
-- Description: 
--      MIPS 32, single-cycle
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( btn : in std_logic_vector(4 downto 0);
         clk : in std_logic;
         rst: out std_logic;
         enable: out std_logic );
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component IDecode
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           RegWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0);
           WriteAddress: in STD_LOGIC_VECTOR(4 downto 0));
end component;

component UC
    Port ( Instr : in STD_LOGIC_VECTOR(5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component EX is
    Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC);
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

signal REG_IF_ID:STD_LOGIC_VECTOR(63 downto 0);
signal REG_ID_EX:STD_LOGIC_VECTOR(157 downto 0);
signal REG_EX_MEM:STD_LOGIC_VECTOR(105 downto 0);
signal REG_MEM_WB:STD_LOGIC_VECTOR(70 downto 0);
signal WriteAddress: STD_LOGIC_VECTOR(4 downto 0);

begin

    monopulse : MPG port map(btn, clk, rst, en);
    
    
    inst_IFetch : IFetch port map(
        clk => clk, 
        rst => btn(1), 
        en => en, 
        BranchAddress => REG_EX_MEM(101 downto 70), 
        JumpAddress => JumpAddress,                 
        Jump => Jump,                               
        PCSrc => PCSrc,                             
        Instruction => Instruction,                 
        PCp4 => PCp4                                
    );

   
    inst_UC : UC port map(
        Instr => REG_IF_ID(63 downto 58), 
        RegDst => RegDst, ExtOp => ExtOp, ALUSrc => ALUSrc, 
        Branch => Branch, Jump => Jump, ALUOp => ALUOp, 
        MemWrite => MemWrite, MemtoReg => MemtoReg, RegWrite => RegWrite
    );

    inst_ID : IDecode port map(
        clk => clk, 
        en => en, 
        Instr => REG_IF_ID(57 downto 32), 
        WD => WD,                         
        RegWrite => REG_MEM_WB(69),       
        RegDst => RegDst,                 
        ExtOp => ExtOp,                   
        RD1 => RD1,                       
        RD2 => RD2,                       
        Ext_Imm => Ext_imm,               
        func => func,                     
        sa => sa,                         
        WriteAddress => REG_MEM_WB(4 downto 0) 
    );

    
    inst_EX : EX port map(
        PCp4 => REG_ID_EX(148 downto 117), 
        RD1 => REG_ID_EX(116 downto 85), 
        RD2 => REG_ID_EX(84 downto 53), 
        Ext_Imm => REG_ID_EX(47 downto 16), 
        func => REG_ID_EX(15 downto 10), 
        sa => REG_ID_EX(52 downto 48), 
        ALUSrc => REG_ID_EX(150), 
        ALUOp => REG_ID_EX(153 downto 151), 
        BranchAddress => BranchAddress,   
        ALURes => ALURes,                 
        Zero => Zero                     
    ); 

    
    inst_MEM : MEM port map(
        clk => clk, 
        en => en, 
        ALUResIn => REG_EX_MEM(68 downto 37), 
        RD2 => REG_EX_MEM(36 downto 5), 
        MemWrite => REG_EX_MEM(103), 
        MemData => MemData,               
        ALUResOut => ALURes1              
    );

    WD <= REG_MEM_WB(68 downto 37) when REG_MEM_WB(70) = '1' else REG_MEM_WB(36 downto 5); 

    
    PCSrc <= REG_EX_MEM(69) and REG_EX_MEM(102); 

    
    JumpAddress <= REG_IF_ID(31 downto 28) & REG_IF_ID(57 downto 32) & "00";

    
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCp4 when "001",
                   RD1 when "010",
                   RD2 when "011",
                   Ext_Imm when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => 'X') when others; 

    display : SSD port map(clk, digits, an, cat);
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

    process(clk)
    begin
       if rising_edge(clk) then
          if en='1' then
             REG_IF_ID(63 downto 32) <= Instruction;
             REG_IF_ID(31 downto 0)  <= PCp4;
          end if;
       end if;
    end process;
    
    
    process(clk)
    begin
       if rising_edge(clk) then
          if en='1' then
             
             REG_ID_EX(157) <= MemToReg;
             REG_ID_EX(156) <= RegWrite;
             REG_ID_EX(155) <= MemWrite;
             REG_ID_EX(154) <= Branch;
             REG_ID_EX(153 downto 151) <= ALUOp;
             REG_ID_EX(150) <= ALUSrc;
             REG_ID_EX(149) <= RegDst;
             
             
             REG_ID_EX(148 downto 117) <= REG_IF_ID(31 downto 0); -- PCp4 din IF/ID
             REG_ID_EX(116 downto 85)  <= RD1;
             REG_ID_EX(84 downto 53)   <= RD2;
             REG_ID_EX(47 downto 16)   <= Ext_Imm;
             
             
             REG_ID_EX(52 downto 48) <= REG_IF_ID(42 downto 38); -- sa   (Instr[10:6])
             REG_ID_EX(15 downto 10) <= REG_IF_ID(37 downto 32); -- func (Instr[5:0])
             REG_ID_EX(9 downto 5)   <= REG_IF_ID(52 downto 48); -- rt   (Instr[20:16])
             REG_ID_EX(4 downto 0)   <= REG_IF_ID(47 downto 43); -- rd   (Instr[15:11])
          end if;
       end if;
    end process;
    
    
    process(clk)
    begin
       if rising_edge(clk) then
          if en = '1' then
             
             REG_EX_MEM(105) <= REG_ID_EX(157); -- MemToReg
             REG_EX_MEM(104) <= REG_ID_EX(156); -- RegWrite
             REG_EX_MEM(103) <= REG_ID_EX(155); -- MemWrite
             REG_EX_MEM(102) <= REG_ID_EX(154); -- Branch
             
             
             REG_EX_MEM(101 downto 70) <= BranchAddress;
             REG_EX_MEM(69)            <= Zero;
             REG_EX_MEM(68 downto 37)  <= ALURes;
             REG_EX_MEM(36 downto 5)   <= REG_ID_EX(84 downto 53); -- RD2 propulsat
             
             
             if REG_ID_EX(149) = '0' then
                 REG_EX_MEM(4 downto 0) <= REG_ID_EX(9 downto 5); -- rt
             else
                 REG_EX_MEM(4 downto 0) <= REG_ID_EX(4 downto 0); -- rd
             end if;
          end if;
       end if;
    end process;
    
    
    process(clk)
    begin
       if rising_edge(clk) then
          if en = '1' then
             
             REG_MEM_WB(70) <= REG_EX_MEM(105); -- MemtoReg
             REG_MEM_WB(69) <= REG_EX_MEM(104); -- RegWrite
             
             
             REG_MEM_WB(68 downto 37) <= MemData;              
             REG_MEM_WB(36 downto 5)  <= REG_EX_MEM(68 downto 37); -- ALURes propulsat din EX/MEM
             REG_MEM_WB(4 downto 0)   <= REG_EX_MEM(4 downto 0);   -- WriteAddress propulsat
          end if;
       end if;
    end process;
    
end Behavioral;