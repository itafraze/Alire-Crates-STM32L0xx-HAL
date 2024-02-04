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

with CMSIS.Core.NVIC;

package body HAL.Cortex is
   --  Implementation Notes:
   --  - Based on source files
   --    - stm32l0xx_hal_driver:Src/stm32l0xx_hal_cortex.c

   --------------------------------------------------------------------------
   procedure NVIC_Set_Priority (IRQ              : Interrupt_Type;
                                Preempt_Priority : Priority_Type;
                                Sub_Priority     : Priority_Type)
   is
      pragma Unreferenced (Sub_Priority);
   begin

      CMSIS.Core.NVIC.Set_Priority (IRQ, Preempt_Priority);

   end NVIC_Set_Priority;
   procedure NVIC_Set_Priority (IRQ              : Exception_Type;
                                Preempt_Priority : Priority_Type;
                                Sub_Priority     : Priority_Type)
   is
      pragma Unreferenced (Sub_Priority);
   begin

      CMSIS.Core.NVIC.Set_Priority (IRQ, Preempt_Priority);

   end NVIC_Set_Priority;
end HAL.Cortex;
