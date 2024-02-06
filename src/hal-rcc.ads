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

end HAL.RCC;