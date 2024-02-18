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

with CMSIS.Device.DMA;

package body HAL.DMA is

   function Init (Handle : in out Handle_Type)
      return Status_Type
   is
      use CMSIS.Device.DMA;
      use CMSIS.Device.DMA.Instances;

      type All_Channel_Type is range 0 .. 6;
      --  Implementation notes:
      --  -  Aligned with CMSIS'
      --       src/stm32l0x1/category-2-3-5/cmsis-device-dma-instances.ads
      --
      --  TODO:
      --  - Find a better way to align with the available channels without
      --    having to provide two separate implementations
      --  - Add support to Lock

      CCRx : constant array (All_Channel_Type) of
            access CCR_Register := [
         DMAx (Handle.Instance).CCR1'Access,
         DMAx (Handle.Instance).CCR2'Access,
         DMAx (Handle.Instance).CCR3'Access,
         DMAx (Handle.Instance).CCR4'Access,
         DMAx (Handle.Instance).CCR5'Access,
         DMAx (Handle.Instance).CCR6'Access,
         DMAx (Handle.Instance).CCR7'Access];

      Channel : constant All_Channel_Type :=
         Channel_Type'Pos (Handle.Channel);

      CxS_Value : constant CSELR_C1S_Field :=
         Request_Type'Pos (Handle.Init.Request);
   begin

      --  Change DMA peripheral state
      Handle.State := BUSY;

      --  DMA channel configuration
      CCRx (Channel).all := (
         @ with delta
            PL => Handle.Init.Priority'Enum_Rep,
            MSIZE => Handle.Init.Memory_Data_Alignment'Enum_Rep,
            PSIZE => Handle.Init.Peripheral_Data_Alignment'Enum_Rep,
            MINC => Handle.Init.Memory_Increment'Enum_Rep,
            PINC => Handle.Init.Peripheral_Increment'Enum_Rep,
            CIRC => Handle.Init.Mode'Enum_Rep,
            DIR => (
               case Handle.Init.Direction is
                  when MEMORY_TO_PERIPHERAL => 2#1#,
                  when others => 2#0#),
            MEM2MEM => (
               case Handle.Init.Direction is
                  when MEMORY_TO_MEMORY => 2#1#,
                  when others => 2#0#));

      --  Set request selection
      if Handle.Init.Direction /= MEMORY_TO_MEMORY
      then
         case Channel is
            when 0 => DMAx (Handle.Instance).CSELR.C1S := CxS_Value;
            when 1 => DMAx (Handle.Instance).CSELR.C2S := CxS_Value;
            when 2 => DMAx (Handle.Instance).CSELR.C3S := CxS_Value;
            when 3 => DMAx (Handle.Instance).CSELR.C4S := CxS_Value;
            when 4 => DMAx (Handle.Instance).CSELR.C5S := CxS_Value;
            when 5 => DMAx (Handle.Instance).CSELR.C6S := CxS_Value;
            when 6 => DMAx (Handle.Instance).CSELR.C7S := CxS_Value;
         end case;
      end if;

      --  Initialise the error code and DMA state
      Handle.Error_Code := NONE;
      Handle.State := READY;

      return ERROR;
   end Init;

end HAL.DMA;
