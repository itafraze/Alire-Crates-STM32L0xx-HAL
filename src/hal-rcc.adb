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

with Stm32l0xx_Hal_Config;

with CMSIS.Device;
   use CMSIS.Device;
with CMSIS.Device.System;
with CMSIS.Device.RCC;

package body HAL.RCC is
   --  HAL Reset and Clock Control (RCC) Generic Driver body
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Src/stm32l0xx_hal_rcc.c

   package RCC renames CMSIS.Device.RCC;
   package HAL_Config renames Stm32l0xx_Hal_Config;
   --

   ---------------------------------------------------------------------------
   function Get_System_Clock_Source
      return System_Clock_Source_Type is
      (System_Clock_Source_Type'Val (RCC.RCC_Periph.CFGR.SWS))
      with Inline;

   ---------------------------------------------------------------------------
   function Get_PLL_Osc_Source
      return PLL_Clock_Source_Type is
      (PLL_Clock_Source_Type'Val (RCC.RCC_Periph.CFGR.PLLSRC))
      with Inline;

   ---------------------------------------------------------------------------
   function HSI_Config (State       : HSI_Config_Type;
                        Calibration : HSI_Calibration_Type)
      return Status_Type;
   --  High-Speed Internal (HSI) oscillator configuration

   function HSI_Config (State       : HSI_Config_Type;
                        Calibration : HSI_Calibration_Type)
      return Status_Type is
   --  Implementation notes:
   --  - Based on HSI code section from function HAL_RCC_OscConfig
   --
   --  TODO:
   --  - Add timeout in HSI ready wait

      Success : Status_Type := OK;

      System_Clock_Source : constant System_Clock_Source_Type :=
         Get_System_Clock_Source;
   begin

      --  Check if HSI is used as system clock or as PLL source when PLL is
      --  selected as system clock
      if (System_Clock_Source = HSI)
         or else ((System_Clock_Source = PLLCLK)
                  and then (Get_PLL_Osc_Source = HSI))
      then

         --  When HSI is used as system clock it will not be disabled
         return ERROR when
            (Boolean'Val (RCC.RCC_Periph.CR.HSI16RDYF) /= False)
            and then (State = OFF);

         --  Otherwise, just the calibration and HSI or HSIdiv4 are allowed
         RCC.RCC_Periph.ICSCR := (@ with delta
            HSI16TRIM  => RCC.ICSCR_HSI16TRIM_Field (Calibration));

         --  Enable the Internal High Speed oscillator (HSI or HSIdiv4)
         RCC.RCC_Periph.CR := (@ with delta
            HSI16ON  => (case State is
                         when ON | DIV4 => 2#1#,
                         when others => 2#0#),
            HSI16DIVEN => (case State is
                           when DIV4 => 2#1#,
                           when others => 2#0#));

         --  Update current System_Core_Clock global variable
         CMSIS.Device.System.Core_Clock := Natural (Shift_Right (
            UInt32 (Get_System_Clock_Frequency),
            Natural (
               case RCC.RCC_Periph.CFGR.HPRE
               is
               when 16#0# .. 16#7# => 0,
               when 16#8# .. 16#B# => RCC.RCC_Periph.CFGR.HPRE - 16#7#,
               when 16#C# .. 16#F# => RCC.RCC_Periph.CFGR.HPRE - 16#6#)));

         --  Configure the source of time base considering new system clocks
         --  settings
         Success := HAL.Init_Tick (HAL_Config.Tick_Init_Priority);
         return Success when Success /= OK;

      --  Enable the Internal High Speed oscillator (HSI or HSIdiv4)
      elsif State /= OFF
      then

         RCC.RCC_Periph.CR := (@ with delta
            HSI16ON  => (case State is
                         when ON | DIV4 => 2#1#,
                         when others => 2#0#),
            HSI16DIVEN => (case State is
                           when DIV4 => 2#1#,
                           when others => 2#0#));

         --  Wait until HSI is ready
         loop
            exit when Boolean'Val (RCC.RCC_Periph.CR.HSI16RDYF) = True;
            --  TODO add timeout
         end loop;

         --  Adjusts the Internal High Speed oscillator (HSI) calibration value
         RCC.RCC_Periph.ICSCR := (@ with delta
            HSI16TRIM  => RCC.ICSCR_HSI16TRIM_Field (Calibration));

      --  Disable the Internal High Speed oscillator (HSI).
      else

         RCC.RCC_Periph.CR.HSI16ON := 2#0#;

         --  Wait untill HSI is disabled
         loop
            exit when Boolean'Val (RCC.RCC_Periph.CR.HSI16RDYF) = False;
            --  TODO add timeout
         end loop;

      end if;

      return Success;

   end HSI_Config;

   ---------------------------------------------------------------------------
   function MSI_Config (State       : MSI_Config_Type;
                        Calibration : MSI_Calibration_Type;
                        Clock_Range : MSI_Clock_Range_Type)
      return Status_Type;
   --  Multi-Speed Internal (MSI) oscillator configuration

   function MSI_Config (State       : MSI_Config_Type;
                        Calibration : MSI_Calibration_Type;
                        Clock_Range : MSI_Clock_Range_Type)
      return Status_Type is
   --  Implementation notes:
   --  - Based on MSI code section from function HAL_RCC_OscConfig
   --
   --  TODO:
   --  - Add timeout in MSI ready wait

      Success : Status_Type := OK;
   begin

      --  When the MSI is used as system clock it will not be disabled
      if Get_System_Clock_Source = MSI
      then

         return ERROR
            when (Boolean'Val (RCC.RCC_Periph.CR.MSIRDY) /= False)
               and then (State = OFF);

         RCC.RCC_Periph.ICSCR := (@ with delta
            MSIRANGE => RCC.ICSCR_MSIRANGE_Field (Clock_Range),
            MSITRIM  => RCC.ICSCR_MSITRIM_Field (Calibration));

         --  Update current System.Core_Clock variable
         CMSIS.Device.System.Core_Clock := Natural (Shift_Right (
            UInt32 (Get_System_Clock_Frequency),
            Natural (
               case RCC.RCC_Periph.CFGR.HPRE
               is
               when 16#0# .. 16#7# => 0,
               when 16#8# .. 16#B# => RCC.RCC_Periph.CFGR.HPRE - 16#7#,
               when 16#C# .. 16#F# => RCC.RCC_Periph.CFGR.HPRE - 16#6#)));

         --  Configure the source of time base considering new system
         --  clocks settings
         Success := HAL.Init_Tick (HAL_Config.Tick_Init_Priority);

      --  Enable the Multi-Speed Internal (MSI) oscillator
      elsif State /= OFF
      then

         RCC.RCC_Periph.CR.MSION := 2#1#;

         --  Wait until MSI is ready
         loop
            exit when Boolean'Val (RCC.RCC_Periph.CR.MSIRDY) = True;
            --  TODO add timeout
         end loop;

         RCC.RCC_Periph.ICSCR := (@ with delta
            MSIRANGE => RCC.ICSCR_MSIRANGE_Field (Clock_Range),
            MSITRIM  => RCC.ICSCR_MSITRIM_Field (Calibration));

      --  Disable the Multi-Speed Internal (MSI) oscillator
      else

         RCC.RCC_Periph.CR.MSION := 2#0#;

         --  Wait until MSI is ready
         loop
            exit when Boolean'Val (RCC.RCC_Periph.CR.MSIRDY) = False;
            --  TODO add timeout
         end loop;

      end if;

      return Success;

   end MSI_Config;

   ---------------------------------------------------------------------------
   function Oscillators_Config (Init : Oscillators_Init_Type)
      return Status_Type is

      Success : Status_Type := ERROR;
   begin

      --  TODO Implement HSE, LSE and LSI configuration
      return ERROR
         when (Init.Oscillator (HSE) = True)
         or else (Init.Oscillator (LSE) = True)
         or else (Init.Oscillator (LSI) = True);

      --  High-Speed Internal (HSI) oscillator -----------------------------
      if Init.Oscillator (HSI) = True
      then

         Success := HSI_Config (
            State       => Init.HSI_State,
            Calibration => Init.HSI_Calibration_Value);

         return Success when Success /= OK;

      end if;

      --  Multi-Speed Internal (MSI) oscillator configuration  -------------
      if Init.Oscillator (MSI) = True
      then

         Success := MSI_Config (
            State       => Init.MSI_State,
            Calibration => Init.MSI_Calibration_Value,
            Clock_Range => Init.MSI_Clock_Range);

         return Success when Success /= OK;

      end if;

      return OK;

   end Oscillators_Config;

   ---------------------------------------------------------------------------
   function Clocks_Config (Init          : Clocks_Init_Type;
                           Flash_Latency : Latency_Type)
      return Status_Type is
   --  TODO:
   --  - Add timeout in ready waits

   begin

      --  Increasing the number of wait states because of higher CPU frequency
      if Flash_Latency > HAL.Flash.Get_Latency
      then
         HAL.Flash.Set_Latency (Flash_Latency);

         loop
            exit when HAL.Flash.Get_Latency = Flash_Latency;
            --  TODO add timeout
         end loop;
      end if;

      --  HCLK Configuration  ----------------------------------------------
      if Init.Clock (HCLK) = True
      then

         RCC.RCC_Periph.CFGR.HPRE :=
            AHB_Clock_Divider_Type'Pos (Init.AHB_Clock_Divider)
            + (case Init.AHB_Clock_Divider is
               when DIV1 => 2#0000#,
               when others => 2#0111#);

      end if;

      --  SYSCLK Configuration  --------------------------------------------
      if Init.Clock (SYSCLK) = True
      then

         --  Check the selected clock is active
         case Init.System_Clock_Source is
         when MSI =>
            return ERROR when not Boolean'Val (RCC.RCC_Periph.CR.MSIRDY);
         when HSI =>
            return ERROR when not Boolean'Val (RCC.RCC_Periph.CR.HSI16RDYF);
         when HSE =>
            return ERROR when not Boolean'Val (RCC.RCC_Periph.CR.HSERDY);
         when PLLCLK =>
            return ERROR when not Boolean'Val (RCC.RCC_Periph.CR.PLLRDY);
         end case;

         RCC.RCC_Periph.CFGR.SW :=
            System_Clock_Source_Type'Enum_Rep (Init.System_Clock_Source);

         loop
            exit when Get_System_Clock_Source = Init.System_Clock_Source;
            --  TODO add timeout
         end loop;
      end if;

      --  Decreasing the number of wait states because of lower CPU frequency
      if Flash_Latency < HAL.Flash.Get_Latency
      then
         HAL.Flash.Set_Latency (Flash_Latency);

         loop
            exit when HAL.Flash.Get_Latency = Flash_Latency;
            --  TODO add timeout
         end loop;
      end if;

      --  PCLK1 Configuration  ---------------------------------------------
      if Init.Clock (HCLK) = True
      then

         RCC.RCC_Periph.CFGR.PPRE.Arr (1) :=
            APB_Clock_Divider_Type'Pos (Init.APB1_Clock_Divider)
            + (case Init.APB1_Clock_Divider is
               when DIV1 => 2#000#,
               when others => 2#011#);

      end if;

      --  PCLK2 Configuration  ---------------------------------------------
      if Init.Clock (HCLK) = True
      then

         RCC.RCC_Periph.CFGR.PPRE.Arr (2) :=
            APB_Clock_Divider_Type'Pos (Init.APB2_Clock_Divider)
            + (case Init.APB2_Clock_Divider is
               when DIV1 => 2#000#,
               when others => 2#011#);

      end if;

      --  Update current System_Core_Clock global variable
      CMSIS.Device.System.Core_Clock := Natural (Shift_Right (
         UInt32 (Get_System_Clock_Frequency),
         Natural (
            case RCC.RCC_Periph.CFGR.HPRE
            is
            when 16#0# .. 16#7# => 0,
            when 16#8# .. 16#B# => RCC.RCC_Periph.CFGR.HPRE - 16#7#,
            when 16#C# .. 16#F# => RCC.RCC_Periph.CFGR.HPRE - 16#6#)));

      --  Configure the source of time base considering new system clocks
      --  settings
      return HAL.Init_Tick (HAL_Config.Tick_Init_Priority);

   end Clocks_Config;

   ---------------------------------------------------------------------------
   function Get_System_Clock_Frequency
      return Natural is
   --  TODO:
   --  - Implement HSE and PLLCLK

      Frequency : Natural := 0;
   begin

      case Get_System_Clock_Source
      is
      when MSI => Frequency := Natural (
         Shift_Left (UInt32 (32_768),
                     Natural (RCC.RCC_Periph.ICSCR.MSIRANGE) + 1));

      when HSI => Frequency := 16_000_000 / (
         if Boolean'Val (RCC.RCC_Periph.CR.HSI16DIVF) = True
         then 4
         else 1);

      when HSE | PLLCLK =>
         --  TODO: To be implemented
         null;

      end case;

      return Frequency;

   end Get_System_Clock_Frequency;

   ---------------------------------------------------------------------------
   function Get_HCLK_Frequency
      return Natural is
      (CMSIS.Device.System.Core_Clock);

   ---------------------------------------------------------------------------
   function Get_PCLK1_Frequency
      return Natural is
      --
      use CMSIS.Device.RCC;

      Prescaler : constant Natural :=
         Natural (RCC_Periph.CFGR.PPRE.Arr (1));
      Frequency : Natural := Get_HCLK_Frequency;
   begin

      if Prescaler >= 2#100#
      then
         Frequency := @ / (2 ** (Prescaler - 2#011#));
      end if;

      return Frequency;

   end Get_PCLK1_Frequency;

   ---------------------------------------------------------------------------
   function Get_PCLK2_Frequency
      return Natural is
      --
      use CMSIS.Device.RCC;

      Prescaler : constant Natural :=
         Natural (RCC_Periph.CFGR.PPRE.Arr (2));
      Frequency : Natural := Get_HCLK_Frequency;
   begin

      if Prescaler >= 2#100#
      then
         Frequency := @ / (2 ** (Prescaler - 2#011#));
      end if;

      return Frequency;

   end Get_PCLK2_Frequency;

   ---------------------------------------------------------------------------
   --  DMA_Clock_Enable
   --
   procedure DMA_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.AHBENR.DMAEN := 2#1#;
   end DMA_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM2_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.APB1ENR.TIM2EN := 2#1#;
   end TIM2_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM3_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.APB1ENR.TIM3EN := 2#1#;
   end TIM3_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM21_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.APB2ENR.TIM21EN := 2#1#;
   end TIM21_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM22_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.APB2ENR.TIM22EN := 2#1#;
   end TIM22_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM6_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.APB1ENR.TIM6EN := 2#1#;
   end TIM6_Clock_Enable;

   ---------------------------------------------------------------------------
   procedure TIM7_Clock_Enable is
      --
      use CMSIS.Device.RCC;
   begin
      RCC_Periph.APB1ENR.TIM7EN := 2#1#;
   end TIM7_Clock_Enable;

end HAL.RCC;