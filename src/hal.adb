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

with System;
with Stm32l0xx_Hal_Config;
with CMSIS.Device.System;
with HAL.Cortex;

package body HAL is
   --  Implementation Notes:
   --  - Based on source files
   --    - stm32l0xx_hal_driver:Src/stm32l0xx_hal.c

   Tick_Frequency : constant Tick_Frequency_Type := TICK_FREQ_1_KHZ;
   --

   ---------------------------------------------------------------------------
   function Init
      return Status_Type
   is
      use System;
      use Stm32l0xx_Hal_Config;

      Status : Status_Type := ERROR;
   begin

      --  TODO Support BUFFER_CACHE_DISABLE, PREREAD_ENABLE and
      --  PREFETCH_ENABLE
      if not Buffer_Cache_Disable
         and not Preread_Enable
         and not Prefetch_Enable
      then
         Status := Init_Tick (Tick_Init_Priority);
      end if;

      if (OK = Status)
         and then (MSP_Init'Address /= Null_Address)
      then
         MSP_Init;
      end if;

      return Status;

   end Init;

   ---------------------------------------------------------------------------
   function Init_Tick (Tick_Priority : Tick_Priority_Type)
      return Status_Type
   is
      use CMSIS.Device.System;
      use CMSIS.Core.Types;

      Status : constant Status_Type := OK;

      --  From the Core clock frequency compute the number of ticks per
      --  milliseconds
      Ticks_Per_Millisecond : constant HAL.Cortex.Ticks_Type :=
         HAL.Cortex.Ticks_Type (Core_Clock
            / (Natural'(1000) / Natural (Tick_Frequency'Enum_Rep)));
   begin

      HAL.Cortex.SYSTICK_Config (Ticks_Per_Millisecond);
      HAL.Cortex.NVIC_Set_Priority (IRQ_SYSTEM_TICK, Tick_Priority, 0);

      return Status;

   end Init_Tick;

end HAL;