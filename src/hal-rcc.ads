------------------------------------------------------------------------------
--  Copyright 2024, Emanuele Zarfati
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--
------------------------------------------------------------------------------
--
--  Revision History:
--    2024.02 E. Zarfati
--       - First version
--
------------------------------------------------------------------------------

with HAL.Flash;
   use all type HAL.Flash.Latency_Type;

package HAL.RCC is
   --  HAL Reset and Clock Control (RCC) Generic Driver
   --
   --  After reset the device is running from multispeed internal oscillator
   --  clock (MSI 2.097MHz) with Flash 0 wait state and Flash prefetch buffer
   --  is disabled, and all peripherals are off except internal SRAM, Flash
   --  and JTAG. Once the device started from reset, the user application has
   --  to:
   --  - configure the clock source to be used to drive the System clock;
   --  - configure the System clock frequency and Flash settings;
   --  - configure the AHB and APB buses prescalers;
   --  - enable the clock for the peripheral(s) to be used;
   --  - configure the clock source(s) for peripherals whose clocks are not
   --    derived from the System clock.
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Inc/stm32l0xx_hal_rcc.h

   type Oscillator_Type is (HSE, HSI, LSE, LSI, MSI);
   --  Reset and Clock Control (RCC) oscillator type
   --
   --  @enum HSE High-Speed External oscillator
   --  @enum HSI High-Speed Internal oscillator
   --  @enum LSE Low-Speed External oscillator
   --  @enum LSI Low-Speed Internal oscillator
   --  @enum MSI Multi-Speed internal oscillator

   type Oscillator_Select_Type is array (Oscillator_Type) of Boolean
      with Pack, Default_Component_Value => False;
   --  Reset and Clock Control (RCC) oscillator selection type
   --
   --  Each element of the array flags the selection for configuration of the
   --  corresponding RCC oscillator

   type HSE_Config_Type is (OFF, ON, BYPASS)
      with Default_Value => OFF;
   --  High-Speed External (HSE) oscillator configuration type
   --
   --  @enum OFF HSE clock deactivation
   --  @enum ON HSE clock activation
   --  @enum BYPASS External clock source for HSE clock

   type LSE_Config_Type is (OFF, ON, BYPASS)
      with Default_Value => OFF;
   --  Low-Speed External (LSE) oscillator configuration type
   --
   --  @enum OFF LSE clock deactivation
   --  @enum ON LSE clock activation
   --  @enum BYPASS External clock source for LSE clock

   type HSI_Config_Type is (OFF, ON, DIV4)
      with Default_Value => OFF;
   --  High-Speed Internal (HSI) oscillator configuration type
   --
   --  @enum OFF HSI clock deactivation
   --  @enum ON HSI clock activation
   --  @enum DIV4 HSI clock activation divided by 4

   type HSI_Calibration_Type is range 0 .. 16#1F#
      with Default_Value => 16#10#;
   --  High-Speed Internal (HSI) oscillator calibration trimming value type

   type LSI_Config_Type is (OFF, ON)
      with Default_Value => OFF;
   --  Low-Speed Internal (LSI) oscillator configuration type
   --
   --  @enum OFF LSI clock deactivation
   --  @enum ON LSI clock activation

   type MSI_Config_Type is (OFF, ON)
      with Default_Value => OFF;
   --  Multi-Speed Internal (MSI) oscillator configuration type
   --
   --  @enum OFF MSI clock deactivation
   --  @enum ON MSI clock activation

   type MSI_Calibration_Type is range 0 .. 16#FF#
      with Default_Value => 0;
   --  Multi-Speed Internal (MSI) oscillator calibration trimming value
   --  type

   type MSI_Clock_Range_Type is range 0 .. 6
      with Default_Value => 5;
   --  Multi-Speed Internal (MSI) oscillator clock range type

   type PLL_Config_Type is (NONE, OFF, ON)
      with Default_Value => OFF;
   --  Phase-Locked Loop (PLL) configuration type
   --
   --  @enum NONE PLL is not configured
   --  @enum OFF PLL deactivation
   --  @enum ON PLL activation

   type PLL_Clock_Source_Type is (HSI, HSE)
      with Default_Value => HSI;
   --  Phase-Locked Loop (PLL) clock source type
   --
   --  @enum HSI HSI clock selected as PLL entry clock source
   --  @enum HSE HSE clock selected as PLL entry clock source

   type PLL_Multiplication_Factor_Type is (MUL_3, MUL_4, MUL_6, MUL_8, MUL_12,
      MUL_16, MUL_24, MUL_32, MUL_48)
      with Default_Value => MUL_3;
   --  Phase-Locked Loop (PLL) multiplication factor type
   --
   --  @enum MUL_3 PLL input clock * 3
   --  @enum MUL_4 PLL input clock * 4
   --  @enum MUL_6 PLL input clock * 6
   --  @enum MUL_8 PLL input clock * 8
   --  @enum MUL_12 PLL input clock * 12
   --  @enum MUL_16 PLL input clock * 16
   --  @enum MUL_24 PLL input clock * 24
   --  @enum MUL_32 PLL input clock * 32
   --  @enum MUL_48 PLL input clock * 48

   type PLL_Division_Factor_Type is (DIV_2, DIV_3, DIV_4)
      with Default_Value => DIV_2;
   --  Phase-Locked Loop (PLL) division factor type
   --
   --  @enum DIV_2 PLL clock output = CKVCO / 2
   --  @enum DIV_3 PLL clock output = CKVCO / 3
   --  @enum DIV_4 PLL clock output = CKVCO / 4

   type PLL_Init_Type is
      record
         State  : PLL_Config_Type;
         Source : PLL_Clock_Source_Type;
         MUL    : PLL_Multiplication_Factor_Type;
         DIV    : PLL_Division_Factor_Type;
      end record
      with Pack;
   --  Phase-Locked Loop (PLL) configuration type
   --
   --  @field State The new state of the PLL
   --  @field Source PLL entry clock source
   --  @field MUL Multiplication factor for PLL VCO input clock
   --  @field DIV Division factor for PLL VCO input clock

   type Oscillators_Init_Type is
      record
         Oscillator            : Oscillator_Select_Type;
         HSE_State             : HSE_Config_Type;
         LSE_State             : LSE_Config_Type;
         HSI_State             : HSI_Config_Type;
         HSI_Calibration_Value : HSI_Calibration_Type;
         LSI_State             : LSI_Config_Type;
         MSI_State             : MSI_Config_Type;
         MSI_Calibration_Value : MSI_Calibration_Type;
         MSI_Clock_Range       : MSI_Clock_Range_Type;
         PLL_Init              : PLL_Init_Type;
      end record
      with Pack;
   --  Reset and Clock Control (RCC) oscillators configuration type
   --
   --  @field Oscillator The oscillators to be configured
   --  @field HSE_State The new state of the HSE
   --  @field LSE_State The new state of the LSE
   --  @field HSI_State The new state of the HSI
   --  @field HSI_Calibration_Value The HSI calibration trimming value
   --  @field LSI_State The new state of the LSI
   --  @field MSI_State The new state of the MSI
   --  @field MSI_Calibration_Value The MSI calibration trimming value
   --  @field MSI_Clock_Range The MSI frequency range
   --  @field PLL_Init PLL structure parameters

   type Clock_Type is (SYSCLK, HCLK, PCLK1, PCLK2);
   --  System Clock Type
   --
   --  @enum SYSCLK System Clock
   --  @enum HCLK Internal AHB clock
   --  @enum PCLK1 Internal APB1 clock
   --  @enum PCLK2 Internal APB2 clock

   type Clock_Select_Type is array (Clock_Type) of Boolean
      with Pack, Default_Component_Value => False;
   --  Reset and Clock Control (RCC) clock selection type
   --
   --  Each element of the array flags the selection for configuration of the
   --  corresponding RCC oscillator

   type System_Clock_Source_Type is (MSI, HSI, HSE, PLLCLK);
   --  Type of the clock source used as system clock
   --
   --  @enum MSI MSI selected as system clock
   --  @enum HSI HSI selected as system clock
   --  @enum HSE HSE selected as system clock
   --  @enum PLLCLK PLL selected as system clock

   type AHB_Clock_Divider_Type is (DIV1, DIV2, DIV4, DIV8, DIV16, DIV64,
      DIV128, DIV256, DIV512);
   --  AHB Clock Source type
   --
   --  @enum DIV1 SYSCLK not divided
   --  @enum DIV2 SYSCLK divided by 2
   --  @enum DIV4 SYSCLK divided by 4
   --  @enum DIV8 SYSCLK divided by 8
   --  @enum DIV16 SYSCLK divided by 16
   --  @enum DIV64 SYSCLK divided by 64
   --  @enum DIV128 SYSCLK divided by 128
   --  @enum DIV256 SYSCLK divided by 256
   --  @enum DIV512 SYSCLK divided by 512

   type APB_Clock_Divider_Type is (DIV1, DIV2, DIV4, DIV8, DIV16);
   --  APB1 APB2 Clock Source type
   --
   --  @enum DIV1 HCLK not divided
   --  @enum DIV2 HCLK divided by 2
   --  @enum DIV4 HCLK divided by 4
   --  @enum DIV8 HCLK divided by 8
   --  @enum DIV16 HCLK divided by 16

   type Clocks_Init_Type is
      record
         Clock               : Clock_Select_Type;
         System_Clock_Source : System_Clock_Source_Type;
         AHB_Clock_Divider   : AHB_Clock_Divider_Type;
         APB1_Clock_Divider  : APB_Clock_Divider_Type;
         APB2_Clock_Divider  : APB_Clock_Divider_Type;
      end record;
   --  Reset and Clock Control (RCC) System, AHB and APB busses clock
   --  configuration type
   --
   --  @field Clock The clock to be configured
   --  @field System_Clock_Source The clock source used as system clock
   --  @field AHB_Clock_Divider The AHB clock (HCLK) divider
   --  @field APB1_Clock_Divider The APB1 clock (PCLK1) divider
   --  @field APB2_Clock_Divider The APB2 clock (PCLK2) divider

   subtype Latency_Type is HAL.Flash.Latency_Type;
   --  FLASH Latency type

   ---------------------------------------------------------------------------
   function Oscillators_Config (Init : Oscillators_Init_Type)
      return Status_Type;
   --  Oscillators Configuration
   --
   --  Initializes the RCC Oscillators according to the specified parameters.
   --
   --  Implementation notes:
   --  - Based on function HAL_RCC_OscConfig;
   --  - For HSI and HSE, transitions between ON and BYPASS are not supported.
   --    These oscillators shall be first transitioned to OFF and then to
   --    either ON or BYPASS;
   --
   --  @param Init Configuration information for the RCC oscillators
   --  @return Status of operations.

   ---------------------------------------------------------------------------
   function Clocks_Config (Init          : Clocks_Init_Type;
                           Flash_Latency : Latency_Type)
      return Status_Type;
   --  Initializes the CPU, AHB and APB buses clocks according to the
   --  specified parameters.
   --
   --  Implementation notes:
   --  - Based on function HAL_RCC_ClockConfig;
   --
   --  @param Init Configuration information for the RCC oscillators
   --  @param Flash_Latency FLASH Latency
   --  @return Status of operations.

   ---------------------------------------------------------------------------
   function Get_System_Clock_Frequency
      return Natural;
   --  Returns the SYSCLK frequency
   --
   --  The system frequency computed by this function is not the real
   --  frequency in the chip. It is calculated based on the predefined
   --  constant and the selected clock source.
   --
   --  @return SYSCLK frequency

   ---------------------------------------------------------------------------
   function Get_HCLK_Frequency
      return Natural;
   --  Returns the HCLK frequency

   ---------------------------------------------------------------------------
   function Get_PCLK1_Frequency
      return Natural;
   --  Returns the PCLK1 frequency

   ---------------------------------------------------------------------------
   function Get_PCLK2_Frequency
      return Natural;
   --  Returns the PCLK2 frequency

   ---------------------------------------------------------------------------
   procedure DMA_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM2_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM3_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM21_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM22_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM6_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM7_Clock_Enable;

private

   for System_Clock_Source_Type use (
      MSI => 2#00#,
      HSI => 2#01#,
      HSE => 2#10#,
      PLLCLK => 2#11#);
   --  System clock switch status

   for PLL_Clock_Source_Type use (
      HSI => 2#0#,
      HSE => 2#1#);
   --  PLL entry clock source

end HAL.RCC;