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

with CMSIS.Device;
with CMSIS.Device.DMA;
   use CMSIS.Device.DMA;
with CMSIS.Device.DMA.Instances;
   use CMSIS.Device.DMA.Instances;
with System.Storage_Elements;

package body HAL.DMA is

   type Interrupt_Type is
      (TRANSFER_COMPLETE, HALF_TRANSFER, TRANSFER_ERROR);
   --

   ---------------------------------------------------------------------------
   procedure Set_Channel (Handle : Handle_Type;
                          Enable : Boolean);
   --  Enable or disable the specified DMA Channel

   procedure Set_Channel (Handle : Handle_Type;
                          Enable : Boolean) is

      CCRx : constant not null access CCR_Register := (
         case All_Channel_Type (Handle.Channel) is
            when CHANNEL_1 => DMAx (Handle.Instance).CCR1'Access,
            when CHANNEL_2 => DMAx (Handle.Instance).CCR2'Access,
            when CHANNEL_3 => DMAx (Handle.Instance).CCR3'Access,
            when CHANNEL_4 => DMAx (Handle.Instance).CCR4'Access,
            when CHANNEL_5 => DMAx (Handle.Instance).CCR5'Access,
            when CHANNEL_6 => DMAx (Handle.Instance).CCR6'Access,
            when CHANNEL_7 => DMAx (Handle.Instance).CCR7'Access);
   begin

         CCRx.EN := Enable'Enum_Rep;

   end Set_Channel;

   ---------------------------------------------------------------------------
   procedure Enable (Handle : Handle_Type;
                     Enable : Boolean := True)
      renames Set_Channel;

   ---------------------------------------------------------------------------
   procedure Disable (Handle : Handle_Type;
                      Enable : Boolean := False)
      renames Set_Channel;

   ---------------------------------------------------------------------------
   procedure Set_Channel_IT (Handle    : Handle_Type;
                             Interrupt : Interrupt_Type;
                             Enable    : Boolean);
   --  Enable the specified DMA Channel interrupts

   procedure Set_Channel_IT (Handle    : Handle_Type;
                             Interrupt : Interrupt_Type;
                             Enable    : Boolean) is

      CCRx : constant not null access CCR_Register := (
         case All_Channel_Type (Handle.Channel) is
            when CHANNEL_1 => DMAx (Handle.Instance).CCR1'Access,
            when CHANNEL_2 => DMAx (Handle.Instance).CCR2'Access,
            when CHANNEL_3 => DMAx (Handle.Instance).CCR3'Access,
            when CHANNEL_4 => DMAx (Handle.Instance).CCR4'Access,
            when CHANNEL_5 => DMAx (Handle.Instance).CCR5'Access,
            when CHANNEL_6 => DMAx (Handle.Instance).CCR6'Access,
            when CHANNEL_7 => DMAx (Handle.Instance).CCR7'Access);
   begin

      case Interrupt is
         when TRANSFER_COMPLETE => CCRx.TCIE := Enable'Enum_Rep;
         when HALF_TRANSFER => CCRx.HTIE := Enable'Enum_Rep;
         when TRANSFER_ERROR => CCRx.TEIE := Enable'Enum_Rep;
      end case;

   end Set_Channel_IT;

   ---------------------------------------------------------------------------
   procedure Enable_IT (Handle    : Handle_Type;
                        Interrupt : Interrupt_Type;
                        Enable    : Boolean := True)
      renames Set_Channel_IT;

   ---------------------------------------------------------------------------
   procedure Disable_IT (Handle    : Handle_Type;
                         Interrupt : Interrupt_Type;
                         Enable    : Boolean := False)
      renames Set_Channel_IT;

   ---------------------------------------------------------------------------
   procedure Set_Config (Handle      : Handle_Type;
                         Source      : Address_Type;
                         Destination : Address_Type;
                         Length      : Transfer_Length_Type);
   --  Sets the DMA Transfer parameter

   procedure Set_Config (Handle      : Handle_Type;
                         Source      : Address_Type;
                         Destination : Address_Type;
                         Length      : Transfer_Length_Type) is

      use CMSIS.Device;

      Peripheral_Address : constant UInt32 := UInt32 (
         System.Storage_Elements.To_Integer (
            case Handle.Init.Direction is
               when MEMORY_TO_PERIPHERAL => Destination,
               when others => Source));
      Memory_Address : constant UInt32 := UInt32 (
         System.Storage_Elements.To_Integer (
            case Handle.Init.Direction is
               when MEMORY_TO_PERIPHERAL => Source,
               when others => Destination));
   begin

      --  Clear all flags and configure DMA Channel data length
      case All_Channel_Type (Handle.Channel) is
         when CHANNEL_1 =>
            DMAx (Handle.Instance).IFCR.CGIF1 := 2#1#;
            DMAx (Handle.Instance).CNDTR1.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR1 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR1 := Memory_Address;
         when CHANNEL_2 =>
            DMAx (Handle.Instance).IFCR.CGIF2 := 2#1#;
            DMAx (Handle.Instance).CNDTR2.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR2 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR2 := Memory_Address;
         when CHANNEL_3 =>
            DMAx (Handle.Instance).IFCR.CGIF3 := 2#1#;
            DMAx (Handle.Instance).CNDTR3.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR3 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR3 := Memory_Address;
         when CHANNEL_4 =>
            DMAx (Handle.Instance).IFCR.CGIF4 := 2#1#;
            DMAx (Handle.Instance).CNDTR4.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR4 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR4 := Memory_Address;
         when CHANNEL_5 =>
            DMAx (Handle.Instance).IFCR.CGIF5 := 2#1#;
            DMAx (Handle.Instance).CNDTR5.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR5 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR5 := Memory_Address;
         when CHANNEL_6 =>
            DMAx (Handle.Instance).IFCR.CGIF6 := 2#1#;
            DMAx (Handle.Instance).CNDTR6.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR6 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR6 := Memory_Address;
         when CHANNEL_7 =>
            DMAx (Handle.Instance).IFCR.CGIF7 := 2#1#;
            DMAx (Handle.Instance).CNDTR7.NDT := CNDTR_NDT_Field (Length);
            DMAx (Handle.Instance).CPAR7 := Peripheral_Address;
            DMAx (Handle.Instance).CMAR7 := Memory_Address;
      end case;

   end Set_Config;

   ---------------------------------------------------------------------------
   function Init (Handle : in out Handle_Type)
      return Status_Type is
      --  Implementation notes:
      --  -  Aligned with CMSIS'
      --       src/stm32l0x1/category-2-3-5/cmsis-device-dma-instances.ads
      --
      --  TODO:
      --  - Find a better way to align with the available channels without
      --    having to provide two separate implementations
      --  - Add support to Lock

      CCRx : constant not null access CCR_Register := (
         case All_Channel_Type (Handle.Channel) is
            when CHANNEL_1 => DMAx (Handle.Instance).CCR1'Access,
            when CHANNEL_2 => DMAx (Handle.Instance).CCR2'Access,
            when CHANNEL_3 => DMAx (Handle.Instance).CCR3'Access,
            when CHANNEL_4 => DMAx (Handle.Instance).CCR4'Access,
            when CHANNEL_5 => DMAx (Handle.Instance).CCR5'Access,
            when CHANNEL_6 => DMAx (Handle.Instance).CCR6'Access,
            when CHANNEL_7 => DMAx (Handle.Instance).CCR7'Access);

      CxS_Value : constant CSELR_C1S_Field :=
         Request_Type'Pos (Handle.Init.Request);
   begin

      --  Change DMA peripheral state
      Handle.State := BUSY;

      --  DMA channel configuration
      CCRx.all := (
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
         case All_Channel_Type (Handle.Channel) is
            when CHANNEL_1 => DMAx (Handle.Instance).CSELR.C1S := CxS_Value;
            when CHANNEL_2 => DMAx (Handle.Instance).CSELR.C2S := CxS_Value;
            when CHANNEL_3 => DMAx (Handle.Instance).CSELR.C3S := CxS_Value;
            when CHANNEL_4 => DMAx (Handle.Instance).CSELR.C4S := CxS_Value;
            when CHANNEL_5 => DMAx (Handle.Instance).CSELR.C5S := CxS_Value;
            when CHANNEL_6 => DMAx (Handle.Instance).CSELR.C6S := CxS_Value;
            when CHANNEL_7 => DMAx (Handle.Instance).CSELR.C7S := CxS_Value;
         end case;
      end if;

      --  Initialise the error code and DMA state
      Handle.Error_Code := NONE;
      Handle.State := READY;

      return OK;
   end Init;

   ---------------------------------------------------------------------------
   function Start_IT (Handle      : in out Handle_Type;
                      Source      : Address_Type;
                      Destination : Address_Type;
                      Length      : Transfer_Length_Type)
      return Status_Type is
      --  TODO:
      --  - Add Lock support
   begin

      return BUSY when Handle.State /= READY;

      --  Reset status
      Handle.State := BUSY;
      Handle.Error_Code := NONE;

      --  Disable the peripheral before configuring the source, destination
      --  address and the data length and clear flags
      Disable (Handle);
      Set_Config (Handle, Source, Destination, Length);

      --  Enable interrupts
      Enable_IT (Handle, TRANSFER_COMPLETE);
      Enable_IT (Handle, TRANSFER_ERROR);
      if Handle.Transfer_Half_Complete_Callback /= null
      then
         Enable_IT (Handle, HALF_TRANSFER);
      else
         Disable_IT (Handle, HALF_TRANSFER);
      end if;

      Enable (Handle);

      return OK;

   end Start_IT;

   ---------------------------------------------------------------------------
   function Abort_IT  (Handle : in out Handle_Type)
      return Status_Type is
   begin

      if Handle.State /= BUSY
      then
         Handle.Error_Code := NO_TRANSFER;
         return ERROR;
      end if;

      --  Disable DMA IT and channel
      for Interrupt in Interrupt_Type'Range loop
         Disable_IT (Handle, Interrupt);
      end loop;
      Disable (Handle);

      --  Clear all flags
      case All_Channel_Type (Handle.Channel) is
         when CHANNEL_1 => DMAx (Handle.Instance).IFCR.CGIF1 := 2#1#;
         when CHANNEL_2 => DMAx (Handle.Instance).IFCR.CGIF2 := 2#1#;
         when CHANNEL_3 => DMAx (Handle.Instance).IFCR.CGIF3 := 2#1#;
         when CHANNEL_4 => DMAx (Handle.Instance).IFCR.CGIF4 := 2#1#;
         when CHANNEL_5 => DMAx (Handle.Instance).IFCR.CGIF5 := 2#1#;
         when CHANNEL_6 => DMAx (Handle.Instance).IFCR.CGIF6 := 2#1#;
         when CHANNEL_7 => DMAx (Handle.Instance).IFCR.CGIF7 := 2#1#;
      end case;

      --  Change the DMA state
      Handle.State := READY;

      if Handle.Transfer_Abort_Callback /= null
      then
         Handle.Transfer_Abort_Callback (Handle);
      end if;

      return OK;

   end Abort_IT;

end HAL.DMA;
