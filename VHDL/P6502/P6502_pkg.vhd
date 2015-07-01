------------------------------------------------------------------------------------------------
-- DESIGN UNIT  : 6502 Package                                                                --
-- DESCRIPTION  : Decodable instructions enumeration and control signals grouping             --
-- AUTHOR       : Everton Alceu Carara and Bernardo Favero Andreeti                           --
-- CREATED      : June 3rd, 2015                                                              --
-- VERSION      : 0.5                                                                         --
------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;

package P6502_pkg is  

    -- Constant flags
    constant CARRY     : integer := 0;
    constant ZERO      : integer := 1;
    constant INTERRUPT : integer := 2;
    constant DECIMAL   : integer := 3;
    constant BREAKF    : integer := 4;
    constant OVERFLOW  : integer := 6;
    constant NEGATIVE  : integer := 7;
    
    -- Instructions execution cycle
    type State is (IDLE, T0, T1, T2, T3, T4, T5, T6, T7, BREAK);
     
    -- Instruction_type enumeration defines the instructions decodable by the control path
    type Instruction_type is (  
        LDA, LDX, LDY,
        STA, STX, STY,
        ADC, SBC,
        INC, INX, INY,
        DEC, DEX, DEY,
        TAX, TAY, TXA, TYA,
        AAND, EOR, ORA,
        CMP, CPX, CPY, BITT,
        ASL, LSR, ROLL, RORR,
        JMP, BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS,
        TSX, TXS, PHA, PHP, PLA, PLP,
        CLC, CLD, CLI, CLV, SECi, SED, SEI,
        JSR, RTS, BRK, RTI, NOP,

        invalid_instruction
    );
    
    type AddressMode_type is (IMM, ZPG, ZPG_XY, IND_X, IND_Y, AABS, ABS_X, ABS_Y, IMP);
    
    type DecodedInstruction_type is record
        instruction        : Instruction_type;
        addressMode        : AddressMode_type; 
        size             : integer range 1 to 3;            
    end record;
 
    type Microinstruction is record
        wrAI         : std_logic;                    -- Write control for the AI register
        wrBI         : std_logic;                    -- Write control for the BI register
        wrAC         : std_logic;                    -- Write control for the AC register
        wrS          : std_logic;                    -- Write control for the S register
        wrX          : std_logic;                    -- Write control for the X register
        wrY          : std_logic;                    -- Write control for the Y register
        wrPCH        : std_logic;                    -- Write control for the PCH register
        wrPCL        : std_logic;                    -- Write control for the PCL register
        wrABH        : std_logic;                    -- Write control for the ABH register
        wrABL        : std_logic;                    -- Write control for the ABL register
        wrMAR        : std_logic;                    -- Write control for the MAR register
        mux_bi       : std_logic;                    -- Multiplexer selection input
        mux_address  : std_logic;                    -- Multiplexer selection input
        mux_mar      : std_logic_vector(1 downto 0); -- Multiplexer selection input
        mux_ai       : std_logic_vector(1 downto 0); -- Multiplexer selection input
        mux_carry    : std_logic_vector(1 downto 0); -- Multiplexer selection input
        mux_s        : std_logic;                    -- Multiplexer selection input
        mux_pc       : std_logic;                    -- Multiplexer selection input
        mux_db       : std_logic_vector(2 downto 0); -- DB Multiplexer selection input
        mux_sb       : std_logic_vector(2 downto 0); -- SB Multiplexer selection input 
        mux_adl      : std_logic_vector(1 downto 0); -- ADL Multiplexer selection input 
        mux_adh      : std_logic_vector(1 downto 0); -- ADH Multiplexer selection input 
        ALUoperation : std_logic_vector(2 downto 0);
        setP         : std_logic_vector(7 downto 0);
        rstP         : std_logic_vector(7 downto 0);
        ceP          : std_logic_vector(7 downto 0);
        rw           : std_logic;                    -- Memory control (rw = 0: WRITE; rw = 1: READ)
        ce           : std_logic;                    -- Memory enable
    end record;
    
    function InstructionDecoder(opcode: in std_logic_vector(7 downto 0)) return DecodedInstruction_type;    
end P6502_pkg;

package body P6502_pkg is

    function InstructionDecoder(opcode: in std_logic_vector(7 downto 0)) return DecodedInstruction_type is
    
        variable di: DecodedInstruction_type;
        
    begin
    
        case opcode is
            --------------------------
            -- Load and Store Group --
            --------------------------
            -- LDA
            when x"AD" =>   di.instruction := LDA;  di.addressMode := AABS;     di.size := 3;
            when x"A5" =>   di.instruction := LDA;  di.addressMode := ZPG;      di.size := 2;
            when x"A9" =>   di.instruction := LDA;  di.addressMode := IMM;      di.size := 2;
            when x"BD" =>   di.instruction := LDA;  di.addressMode := ABS_X;    di.size := 3;
            when x"B9" =>   di.instruction := LDA;  di.addressMode := ABS_Y;    di.size := 3;
            when x"B5" =>   di.instruction := LDA;  di.addressMode := ZPG_XY;   di.size := 2;
            when x"A1" =>   di.instruction := LDA;  di.addressMode := IND_X;    di.size := 2;
            when x"B1" =>   di.instruction := LDA;  di.addressMode := IND_Y;    di.size := 2;
                       
            -- LDX
            when x"AE" =>   di.instruction := LDX;  di.addressMode := AABS;     di.size := 3;
            when x"A6" =>   di.instruction := LDX;  di.addressMode := ZPG;      di.size := 2;
            when x"A2" =>   di.instruction := LDX;  di.addressMode := IMM;      di.size := 2;
            when x"BE" =>   di.instruction := LDX;  di.addressMode := ABS_Y;   di.size := 3;
            when x"B6" =>   di.instruction := LDX;  di.addressMode := ZPG_XY;   di.size := 2;
                                 
            -- LDY
            when x"AC" =>   di.instruction := LDY;  di.addressMode := AABS;     di.size := 3;
            when x"A4" =>   di.instruction := LDY;  di.addressMode := ZPG;      di.size := 2;
            when x"A0" =>   di.instruction := LDY;  di.addressMode := IMM;      di.size := 2;
            when x"BC" =>   di.instruction := LDY;  di.addressMode := ABS_X;   di.size := 3;
            when x"B4" =>   di.instruction := LDY;  di.addressMode := ZPG_XY;   di.size := 2;
            
            -- STA
            when x"8D" =>   di.instruction := STA;  di.addressMode := AABS;     di.size := 3;
            when x"85" =>   di.instruction := STA;  di.addressMode := ZPG;      di.size := 2;
            when x"9D" =>   di.instruction := STA;  di.addressMode := ABS_X;   di.size := 3;
            when x"99" =>   di.instruction := STA;  di.addressMode := ABS_Y;   di.size := 3;
            when x"95" =>   di.instruction := STA;  di.addressMode := ZPG_XY;   di.size := 2;
            when x"81" =>   di.instruction := STA;  di.addressMode := IND_X;    di.size := 2;
            when x"91" =>   di.instruction := STA;  di.addressMode := IND_Y;    di.size := 2;
            
            -- STX
            when x"8E" =>   di.instruction := STX;  di.addressMode := AABS;     di.size := 3;
            when x"86" =>   di.instruction := STX;  di.addressMode := ZPG;      di.size := 2;
            when x"96" =>   di.instruction := STX;  di.addressMode := ZPG_XY;   di.size := 2;
            
            -- STY
            when x"8C" =>   di.instruction := STY;  di.addressMode := AABS;     di.size := 3;
            when x"84" =>   di.instruction := STY;  di.addressMode := ZPG;      di.size := 2;
            when x"94" =>   di.instruction := STY;  di.addressMode := ZPG_XY;   di.size := 2;
            
            
            ----------------------
            -- Arithmetic Group --
            ----------------------
            -- ADC
            when x"6D" =>   di.instruction := ADC;  di.addressMode := AABS;     di.size := 3;
            when x"65" =>   di.instruction := ADC;  di.addressMode := ZPG;      di.size := 2;
            when x"69" =>   di.instruction := ADC;  di.addressMode := IMM;      di.size := 2;
            when x"7D" =>   di.instruction := ADC;  di.addressMode := ABS_X;    di.size := 3;
            when x"79" =>   di.instruction := ADC;  di.addressMode := ABS_Y;    di.size := 3;
            when x"75" =>   di.instruction := ADC;  di.addressMode := ZPG_XY;   di.size := 2;
            when x"61" =>   di.instruction := ADC;  di.addressMode := IND_X;    di.size := 2;
            when x"71" =>   di.instruction := ADC;  di.addressMode := IND_Y;    di.size := 2;
            
            -- SBC
            when x"ED" =>   di.instruction := SBC;  di.addressMode := AABS;     di.size := 3;
            when x"E5" =>   di.instruction := SBC;  di.addressMode := ZPG;      di.size := 2;
            when x"E9" =>   di.instruction := SBC;  di.addressMode := IMM;      di.size := 2;
            when x"FD" =>   di.instruction := SBC;  di.addressMode := ABS_X;    di.size := 3;
            when x"F9" =>   di.instruction := SBC;  di.addressMode := ABS_Y;    di.size := 3;
            when x"F5" =>   di.instruction := SBC;  di.addressMode := ZPG_XY;   di.size := 2;
            when x"E1" =>   di.instruction := SBC;  di.addressMode := IND_X;    di.size := 2;
            when x"F1" =>   di.instruction := SBC;  di.addressMode := IND_Y;    di.size := 2;
           
           
            -----------------------------------
            -- Increment and Decrement Group --
            -----------------------------------
            -- INC
            when x"EE" =>   di.instruction := INC;  di.addressMode := AABS;     di.size := 3;
            when x"E6" =>   di.instruction := INC;  di.addressMode := ZPG;      di.size := 2;
            when x"FE" =>   di.instruction := INC;  di.addressMode := ABS_X;    di.size := 3;
            when x"F6" =>   di.instruction := INC;  di.addressMode := ZPG_XY;   di.size := 2;
            
            -- INX
            when x"E8" =>   di.instruction := INX;  di.addressMode := IMP;      di.size := 1;
            
            -- INY
            when x"C8" =>   di.instruction := INY;  di.addressMode := IMP;      di.size := 1;
            
            -- DEC
            when x"CE" =>   di.instruction := DEC;  di.addressMode := AABS;     di.size := 3;
            when x"C6" =>   di.instruction := DEC;  di.addressMode := ZPG;      di.size := 2;
            when x"DE" =>   di.instruction := DEC;  di.addressMode := ABS_X;    di.size := 3;
            when x"D6" =>   di.instruction := DEC;  di.addressMode := ZPG_XY;   di.size := 2;
            
            -- DEX
            when x"CA" =>   di.instruction := DEX;  di.addressMode := IMP;      di.size := 1;
            
            -- DEY
            when x"88" =>   di.instruction := DEY;  di.addressMode := IMP;      di.size := 1;
            
            
            -----------------------------
            -- Register Transfer Group --
            -----------------------------
            -- TAX
            when x"AA" =>   di.instruction := TAX;  di.addressMode := IMP;      di.size := 1;
            
            -- TAY
            when x"A8" =>   di.instruction := TAY;  di.addressMode := IMP;      di.size := 1;
            
            -- TXA
            when x"8A" =>   di.instruction := TXA;  di.addressMode := IMP;      di.size := 1;
            
            -- TYA
            when x"98" =>   di.instruction := TYA;  di.addressMode := IMP;      di.size := 1;
            
            
            -------------------
            -- Logical Group --
            -------------------
            -- AND
            when x"2D" =>   di.instruction := AAND;  di.addressMode := AABS;     di.size := 3;
            when x"25" =>   di.instruction := AAND;  di.addressMode := ZPG;      di.size := 2;
            when x"29" =>   di.instruction := AAND;  di.addressMode := IMM;      di.size := 2;
            when x"3D" =>   di.instruction := AAND;  di.addressMode := ABS_X;    di.size := 3;
            when x"39" =>   di.instruction := AAND;  di.addressMode := ABS_Y;    di.size := 3;
            when x"35" =>   di.instruction := AAND;  di.addressMode := ZPG_XY;   di.size := 2;
            when x"21" =>   di.instruction := AAND;  di.addressMode := IND_X;    di.size := 2;
            when x"31" =>   di.instruction := AAND;  di.addressMode := IND_Y;    di.size := 2;
            
            -- EOR
            when x"4D" =>   di.instruction := EOR;  di.addressMode := AABS;      di.size := 3;
            when x"45" =>   di.instruction := EOR;  di.addressMode := ZPG;       di.size := 2;
            when x"49" =>   di.instruction := EOR;  di.addressMode := IMM;       di.size := 2;
            when x"5D" =>   di.instruction := EOR;  di.addressMode := ABS_X;     di.size := 3;
            when x"59" =>   di.instruction := EOR;  di.addressMode := ABS_Y;     di.size := 3;
            when x"55" =>   di.instruction := EOR;  di.addressMode := ZPG_XY;    di.size := 2;
            when x"41" =>   di.instruction := EOR;  di.addressMode := IND_X;     di.size := 2;
            when x"51" =>   di.instruction := EOR;  di.addressMode := IND_Y;     di.size := 2;
            
            -- ORA
            when x"0D" =>   di.instruction := ORA;  di.addressMode := AABS;      di.size := 3;
            when x"05" =>   di.instruction := ORA;  di.addressMode := ZPG;       di.size := 2;
            when x"09" =>   di.instruction := ORA;  di.addressMode := IMM;       di.size := 2;
            when x"1D" =>   di.instruction := ORA;  di.addressMode := ABS_X;     di.size := 3;
            when x"19" =>   di.instruction := ORA;  di.addressMode := ABS_Y;     di.size := 3;
            when x"15" =>   di.instruction := ORA;  di.addressMode := ZPG_XY;    di.size := 2;
            when x"01" =>   di.instruction := ORA;  di.addressMode := IND_X;     di.size := 2;
            when x"11" =>   di.instruction := ORA;  di.addressMode := IND_Y;     di.size := 2;
            
           
            --------------------------------
            -- Compare and Bit Test Group --
            --------------------------------
            -- CMP
            when x"CD" =>   di.instruction := CMP;  di.addressMode := AABS;      di.size := 3;
            when x"C5" =>   di.instruction := CMP;  di.addressMode := ZPG;       di.size := 2;
            when x"C9" =>   di.instruction := CMP;  di.addressMode := IMM;       di.size := 2;
            when x"DD" =>   di.instruction := CMP;  di.addressMode := ABS_X;     di.size := 3;
            when x"D9" =>   di.instruction := CMP;  di.addressMode := ABS_Y;     di.size := 3;
            when x"D5" =>   di.instruction := CMP;  di.addressMode := ZPG_XY;    di.size := 2;
            when x"C1" =>   di.instruction := CMP;  di.addressMode := IND_X;     di.size := 2;
            when x"D1" =>   di.instruction := CMP;  di.addressMode := IND_Y;     di.size := 2;
            
            -- CPX
            when x"EC" =>   di.instruction := CPX;  di.addressMode := AABS;      di.size := 3;
            when x"E4" =>   di.instruction := CPX;  di.addressMode := ZPG;       di.size := 2;
            when x"E0" =>   di.instruction := CPX;  di.addressMode := IMM;       di.size := 2;
             
            -- CPY
            when x"CC" =>   di.instruction := CPY;  di.addressMode := AABS;      di.size := 3;
            when x"C4" =>   di.instruction := CPY;  di.addressMode := ZPG;       di.size := 2;
            when x"C0" =>   di.instruction := CPY;  di.addressMode := IMM;       di.size := 2;
            
            
            ------------------------------
            -- Status Flag Change Group --
            ------------------------------
            -- CLC
            when x"18" =>   di.instruction := CLC;  di.addressMode := IMP;       di.size := 1;
            
            -- CLD
            when x"D8" =>   di.instruction := CLD;  di.addressMode := IMP;       di.size := 1;
            
            -- CLI
            when x"58" =>   di.instruction := CLI;  di.addressMode := IMP;       di.size := 1;
            
            -- CLV
            when x"B8" =>   di.instruction := CLV;  di.addressMode := IMP;       di.size := 1;
            
            -- SEC
            when x"38" =>   di.instruction := SECi;  di.addressMode := IMP;      di.size := 1;
            
            -- SED
            when x"F8" =>   di.instruction := SED;  di.addressMode := IMP;       di.size := 1;
            
            -- SEI
            when x"78" =>   di.instruction := SEI;  di.addressMode := IMP;       di.size := 1;
            
            
            
            --------------------------------------
            -- Subroutine and Interrupt Group --
            --------------------------------------
            -- JSR
            when x"20" =>   di.instruction := JSR;  di.addressMode := AABS;      di.size := 3;
            
            -- RTS
            when x"60" =>   di.instruction := RTS;  di.addressMode := IMP;          di.size := 1;
                       
            -- BRK
            when x"00" =>   di.instruction := BRK;  di.addressMode := IMP;          di.size := 1;
            
            --RTI
            when x"40" =>   di.instruction := RTI;  di.addressMode := IMP;          di.size := 1;
            
            --NOP
            when x"EA" =>   di.instruction := NOP;  di.addressMode := IMP;          di.size := 1;
            
            when others =>   di.instruction := invalid_instruction;
        end case;                     
        return di;
        
    end InstructionDecoder;
    
    
end P6502_pkg;