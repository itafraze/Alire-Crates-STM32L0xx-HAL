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
with CMSIS.Device.System;
with HAL;
with MSP_Init;

pragma Unreferenced (MSP_Init);

procedure Tests
is
   use Ada.Text_IO;
   use all type HAL.Status_Type;
begin

   CMSIS.Device.System.Init;

   if OK /= HAL.Init then
      Put_Line ("HAL initialisation failed");
   end if;

   --  Send welcome message
   Put_Line ("Tests passed");

end Tests;
