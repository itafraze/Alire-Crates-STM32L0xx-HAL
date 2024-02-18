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

with AUnit.Test_Caller;
with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

package HAL.Test is

   type Reset_Fixture is
      new AUnit.Test_Fixtures.Test_Fixture with null record;
   --  System status after reset

   -------------------------------------------------------------------------
   overriding procedure Set_Up (UNUSED_T : in out Reset_Fixture);

   package Caller_Reset
      is new AUnit.Test_Caller (Reset_Fixture);
   --

   type Init_Fixture is
      new Reset_Fixture with null record;
   --  System status after reset and HAL.Init

   -------------------------------------------------------------------------
   overriding procedure Set_Up (T : in out Init_Fixture);

   -------------------------------------------------------------------------
   function Suite
      return AUnit.Test_Suites.Access_Test_Suite;

   procedure MSP_Init
      with Export;
      --  Executed by HAL.Init

end HAL.Test;
