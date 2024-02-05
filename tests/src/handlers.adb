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

with Ada.Text_IO;

package body Handlers is

   type Count_1000_Type is mod 1000;

   Count_1000 : Count_1000_Type := 0;
   Count : Natural := 0;

   ---------------------------------------------------------------------------
   procedure SysTick_Handler
   is
      use Ada.Text_IO;
   begin

      if Count_1000 = 0 then
         --  Works with semihosting
         Put_Line ("SysTick_Handler trigger n." & Count'Image);
         Count := @ + 1;
      end if;
      Count_1000 := @ + 1;

   end SysTick_Handler;

end Handlers;
