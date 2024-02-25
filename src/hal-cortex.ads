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

with CMSIS.Core.SysTick;

package HAL.Cortex is
   --
   --  Implementation Notes:
   --  - Based on source files
   --    - stm32l0xx_hal_driver:Inc/stm32l0xx_hal_cortex.h

   subtype Ticks_Type is CMSIS.Core.SysTick.Ticks_Type;
   --

   subtype Interrupt_Type is CMSIS.Core.Types.Interrupt_Type;
   --

   subtype Exception_Type is CMSIS.Core.Types.Exception_Type;
   --

   subtype Priority_Type is CMSIS.Core.Types.Priority_Type;
   --

   --------------------------------------------------------------------------
   procedure SYSTICK_Config (Number_Of_Ticks : Ticks_Type)
      renames CMSIS.Core.SysTick.Config;
   --  Initializes the System Timer and its interrupt, and starts the System
   --  Tick Timer.
   --
   --  Implementation notes:
   --  - No return information is provided since type of Number_Of_Ticks is
   --    implementation-defined in CMSIS
   --
   --  @param Number_Of_Ticks Specifies the number of ticks between two
   --    interrupts

   --------------------------------------------------------------------------
   procedure NVIC_Set_Priority (IRQ              : Interrupt_Type;
                                Preempt_Priority : Priority_Type;
                                Sub_Priority     : Priority_Type);
   procedure NVIC_Set_Priority (IRQ              : Exception_Type;
                                Preempt_Priority : Priority_Type;
                                Sub_Priority     : Priority_Type);
   --  Sets the priority of an interrupt.
   --
   --  @param IRQ Device specific interrupt identifier
   --  @param Preempt_Priority The interrupt priority value, whereby lower
   --    values indicate a higher priority.
   --  @param Sub_Priority This parameter is a dummy value for stm32l0xx
   --    devices

   --------------------------------------------------------------------------
   procedure NVIC_Enable_IRQ (IRQ : Interrupt_Type);

end HAL.Cortex;
