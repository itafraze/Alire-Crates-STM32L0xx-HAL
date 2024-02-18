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

with AUnit.Assertions;
with HAL.Test;
   use type HAL.Test.Reset_Fixture;

package body HAL.DMA.Test
is
   use AUnit.Assertions;

   Result : aliased AUnit.Test_Suites.Test_Suite;
   --  Statically allocated test suite

   -------------------------------------------------------------------------
   procedure Init_Success_With_Defaults (
      UNUSED_T : in out HAL.Test.Reset_Fixture)
   is
      --  HAL.Init returns no error

      Status : Status_Type;
      Handle : Handle_Type := (others => <>);
   begin

      Status := Init (Handle);

      Assert (
         Status = OK,
         "HAL.DMA.Init returned a non-successful status: " & Status'Image);

   end Init_Success_With_Defaults;

   -------------------------------------------------------------------------
   function Suite
      return AUnit.Test_Suites.Access_Test_Suite
   is
   begin

      Result.Add_Test (
        HAL.Test.Caller_Reset.Create (
            "HAL.DMA::" & "Reset_Fixture::" & "Init_Success_With_Defaults",
            Init_Success_With_Defaults'Access));

      return Result'Access;

   end Suite;

end HAL.DMA.Test;
