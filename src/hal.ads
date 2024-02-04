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

package HAL is
   --  Hardware Abstraction Layer (HAL)

   --  The portable APIs layer provides a generic, multi instanced and simple
   --  set of APIs to interact with the upper layer (application, libraries
   --  and stacks).
   --
   --  Implementation Notes:
   --  - Based on source files
   --    - stm32l0xx_hal_driver:Inc/stm32l0xx_hal.h

   pragma Preelaborate;

   type Status_Type is (OK, ERROR, BUSY, TIMEOUT);
   --  Type of HAL Status
   --
   --  The HAL status is used by almost all HAL APIs, except for boolean
   --  functions and IRQ handler. It returns the status of the current API
   --  operations.

   ---------------------------------------------------------------------------
   function Init
      return Status_Type;
   --  HAL System Initialisation
   --
   --  This function:
   --  - initialises the data/instruction cache and the pre-fetch queue
   --  - sets SysTick timer to generate an interrupt each 1ms (based on HSI
   --    clock) with the lowest priority
   --  - calls MSP_Init() user callback function to perform system level
   --    initializations (Clock, GPIOs, DMA, interrupts)
   --
   --  Notes:
   --  - This function must be called at application startup after reset and
   --    before the clock configuration.
   --
   --  @return Status of operations

   ---------------------------------------------------------------------------
   function Init_Tick (Tick_Priority : Natural)
      return Status_Type;
   --  Initialise SysTick regular time intervals interrupt
   --
   --  Configures the source of the time base with a dedicated Tick interrupt
   --  priority. The time source is configured to have 1ms time base with a
   --  dedicated Tick interrupt priority.
   --
   --  Notes:
   --  - This function is called automatically at the beginning of program
   --    after reset by HAL_Init().
   --
   --  @param Tick_Priority Tick interrupt priority.
   --  @return Status of operations

private

   ---------------------------------------------------------------------------
   procedure MSP_Init
      with Import;
   pragma Weak_External (MSP_Init);
   --  When the callback is needed, the MSP_Init could be implemented by the
   --  user

end HAL;
