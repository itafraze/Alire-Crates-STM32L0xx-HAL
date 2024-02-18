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

package body HAL.Test
is
   use AUnit.Assertions;

   package Caller_Init
      is new AUnit.Test_Caller (Init_Fixture);
   --

   Result : aliased AUnit.Test_Suites.Test_Suite;
   --  Statically allocated test suite

   MSP_Init_Calls : Natural := 0;
   --  Count the execution of procedure MSP_Init

   -------------------------------------------------------------------------
   overriding procedure Set_Up (UNUSED_T : in out Reset_Fixture)
   is
   begin

      MSP_Init_Calls := 0;

   end Set_Up;

   -------------------------------------------------------------------------
   overriding procedure Set_Up (T : in out Init_Fixture)
   is
      UNUSED_Status : Status_Type;
   begin

      Reset_Fixture (T).Set_Up;
      UNUSED_Status := HAL.Init;

   end Set_Up;

   -------------------------------------------------------------------------
   procedure MSP_Init
   is
   begin
      MSP_Init_Calls := @ + 1;
   end MSP_Init;

   -------------------------------------------------------------------------
   procedure Init_Successful (UNUSED_T : in out Reset_Fixture)
   is
      --  HAL.Init returns no error

      Status : Status_Type;
   begin

      Status := Init;

      Assert (
         Status = OK,
         "HAL.Init returned a non-successful status: " & Status'Image);

   end Init_Successful;

   -------------------------------------------------------------------------
   procedure Init_Calls_MSP_Init (UNUSED_T : in out Init_Fixture)
   is
      --  HAL.Init executes MSP_Init
   begin

      Assert (
         MSP_Init_Calls = 1,
         "Executions count of MSP_Init after HAL.Init is not 1: "
            & MSP_Init_Calls'Image);

   end Init_Calls_MSP_Init;

   -------------------------------------------------------------------------
   function Suite
      return AUnit.Test_Suites.Access_Test_Suite
   is
   begin

      Result.Add_Test (
        Caller_Reset.Create (
            "HAL::" & "Reset_Fixture::" & "Init_Successful",
            Init_Successful'Access));
      Result.Add_Test (
        Caller_Init.Create (
            "HAL::" & "Init_Fixture::" & "Init_Calls_MSP_Init",
            Init_Calls_MSP_Init'Access));

      return Result'Access;

   end Suite;

end HAL.Test;
