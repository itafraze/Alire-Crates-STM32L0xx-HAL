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

with CMSIS.Device.Flash;

package body HAL.Flash is
   --  FLASH Firmware driver API description body
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Src/stm32l0xx_hal_flash.c

   package FLASH renames CMSIS.Device.Flash;
   --

   ---------------------------------------------------------------------------
   function Get_Latency
      return Latency_Type
   is
   begin

      return Latency_Type'Enum_Val (FLASH.Flash_Periph.ACR.LATENCY);

   end Get_Latency;

   ---------------------------------------------------------------------------
   procedure Set_Latency (Latency : Latency_Type)
   is
   begin

      FLASH.Flash_Periph.ACR.LATENCY :=
         FLASH.ACR_LATENCY_Field (Latency'Enum_Rep);

   end Set_Latency;

end HAL.Flash;