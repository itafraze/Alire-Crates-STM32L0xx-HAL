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
with AUnit.Test_Caller;
with CMSIS.Device;
with CMSIS.Device.DMA;

package body HAL.DMA.Test
is
   use AUnit.Assertions;

   package Caller_Reset
      is new AUnit.Test_Caller (Reset_Fixture);
   --

   package Caller_Init_Defaults
      is new AUnit.Test_Caller (Init_Defaults_Fixture);
   --

   Result : aliased AUnit.Test_Suites.Test_Suite;
   --  Statically allocated test suite

   -------------------------------------------------------------------------
   overriding procedure Set_Up (T : in out Reset_Fixture)
   is
      use CMSIS.Device;
      use CMSIS.Device.DMA;

      CCRx_Reset_Value : constant UInt32 := 2#0#;
      CCR1 : UInt32
         with Volatile, Import, Address => DMA1_Periph.CCR1'Address;

      CSELR_Reset_Value : constant UInt32 := 2#0#;
      CSELR : UInt32
         with Volatile, Import, Address => DMA1_Periph.CSELR'Address;
   begin

      HAL.Test.Reset_Fixture (T).Set_Up;

      CCR1  := CCRx_Reset_Value;
      CSELR := CSELR_Reset_Value;

   end Set_Up;

   -------------------------------------------------------------------------
   procedure Init_Success_With_Defaults (UNUSED_T : in out Reset_Fixture)
   is
      --  HAL.DMA.Init returns no errors with default handle

      Status : Status_Type;
      Handle : Handle_Type := (others => <>);
   begin

      Status := Init (Handle);

      Assert (
         Status = OK,
         "HAL.DMA.Init returned a non-successful status: " & Status'Image);

   end Init_Success_With_Defaults;

   -------------------------------------------------------------------------
   overriding procedure Set_Up (T : in out Init_Defaults_Fixture)
   is
      UNUSED_Status : Status_Type;
      Handle : Handle_Type := (others => <>);
   begin

      Reset_Fixture (T).Set_Up;
      UNUSED_Status := Init (Handle);

   end Set_Up;

   -------------------------------------------------------------------------
   procedure CCR1_Value_After_Default_Init (
      UNUSED_T : in out Init_Defaults_Fixture)
   is
      --  Check value of CCR1 register after initialisation with default
      --  handle

      use CMSIS.Device;
      use CMSIS.Device.DMA;

      CCR1_Default_Value : CCR_Register := (
         EN => 2#0#,
         TCIE => 2#0#,
         HTIE => 2#0#,
         TEIE => 2#0#,
         DIR => 2#0#,
         CIRC => 2#0#,
         PINC => 2#0#,
         MINC => 2#0#,
         PSIZE => 2#10#,
         MSIZE => 2#10#,
         PL => 2#00#,
         MEM2MEM => 2#0#,
         Reserved_15_31 => 2#0#);
      CCR1_U32 : UInt32
         with Volatile, Import, Address => DMA1_Periph.CCR1'Address;
      CCR1_Default_Value_U32 : UInt32
         with Volatile, Import, Address => CCR1_Default_Value'Address;

      CSELR_Default_Value : CSELR_Register := (
         C1S => 2#0000#,
         C2S => 2#0000#,
         C3S => 2#0000#,
         C4S => 2#0000#,
         C5S => 2#0000#,
         C6S => 2#0000#,
         C7S => 2#0000#,
         Reserved_28_31 => 2#0#);
      CSELR_U32 : UInt32
         with Volatile, Import, Address => DMA1_Periph.CSELR'Address;
      CSELR_Default_Value_U32 : UInt32
         with Volatile, Import, Address => CSELR_Default_Value'Address;

   begin

      Assert (
         DMA1_Periph.CCR1 = CCR1_Default_Value,
         "CCR1 has unexpected value:"
            & CCR1_U32'Image & " /="
            & CCR1_Default_Value_U32'Image);

      Assert (
         DMA1_Periph.CSELR = CSELR_Default_Value,
         "CSELR has unexpected value:"
            & CSELR_U32'Image & " /="
            & CSELR_Default_Value_U32'Image);

   end CCR1_Value_After_Default_Init;

   -------------------------------------------------------------------------
   function Suite
      return AUnit.Test_Suites.Access_Test_Suite
   is
   begin

      Result.Add_Test (
        Caller_Reset.Create (
            "HAL.DMA::" & "Reset_Fixture::" & "Init_Success_With_Defaults",
            Init_Success_With_Defaults'Access));

      Result.Add_Test (
         Caller_Init_Defaults.Create (
            "HAL.DMA::" & "Init_Defaults_Fixture::"
               & "CCR1_Value_After_Default_Init",
            CCR1_Value_After_Default_Init'Access));

      return Result'Access;

   end Suite;

end HAL.DMA.Test;
