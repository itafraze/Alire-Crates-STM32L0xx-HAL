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

package HAL.Flash is
   --  FLASH Firmware driver API description
   --
   --  The Flash memory interface manages CPU AHB I-Code and D-Code accesses
   --  to the Flash memory. It implements the erase and program Flash memory
   --  operations and the read and write protection mechanisms.
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Inc/stm32l0xx_hal_flash.h

   type Latency_Type is (LATENCY_0, LATENCY_1);
   --  FLASH Latency type
   --
   --  Specifies if zero or one wait-state is necessary to read the NVM
   --
   --  @enum LATENCY_0 Zero Latency cycle
   --  @enum LATENCY_1 One Latency cycle

   ---------------------------------------------------------------------------
   function Get_Latency
      return Latency_Type;
   --  Get the FLASH Latency
   --
   --  @return FLASH Latency

   ---------------------------------------------------------------------------
   procedure Set_Latency (Latency : Latency_Type);
   --  Set the FLASH Latency
   --
   --  @param Latency FLASH Latency

private

   for Latency_Type use (
      LATENCY_0 => 2#0#,
      LATENCY_1 => 2#1#);

end HAL.Flash;