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

with System;
   use type System.Address;
with CMSIS.Device.DMA.Instances;
   use all type CMSIS.Device.DMA.Instances.Instance_Type;
   use all type CMSIS.Device.DMA.Instances.Channel_Type;

package HAL.DMA is
   --  HAL Direct Memory Access (DMA) Generic Driver
   --

   subtype Instance_Type is
      CMSIS.Device.DMA.Instances.Instance_Type;
   --

   subtype Channel_Type is
      CMSIS.Device.DMA.Instances.Channel_Type;
   --

   type Request_Type is
      (REQUEST_0, REQUEST_1, REQUEST_2, REQUEST_3, REQUEST_4, REQUEST_5,
         REQUEST_6, REQUEST_7, REQUEST_8, REQUEST_9, REQUEST_10, REQUEST_11,
         REQUEST_12, REQUEST_13, REQUEST_14, REQUEST_15)
      with Default_Value => REQUEST_0;
   --  Requests for each channel
   --
   --  Notes:
   --  - Not all requests are available for all channels and devices

   type Direction_Type is
      (PERIPHERAL_TO_MEMORY, MEMORY_TO_PERIPHERAL, MEMORY_TO_MEMORY)
      with Default_Value => PERIPHERAL_TO_MEMORY;
   --  Possible data transfer directions are from memory to peripheral, from
   --  memory to memory or from peripheral to memory

   type Increment_Type is
      new Boolean
      with Default_Value => False;
   --  The peripheral or memory address register may be incremented or not

   type Data_Alignment_Type is
      (BYTE, HALF_WORD, WORD)
      with Default_Value => WORD;
   --

   type Mode_Type is
      (NORMAL, CIRCULAR)
      with Default_Value => NORMAL;
   --
   --
   --  Notes:
   --  - The circular buffer mode cannot be used if the memory-to-memory data
   --    transfer is configured on the selected channel

   type Priority_Type is
      (LOW, MEDIUM, HIGH, VERY_HIGH)
      with Default_Value => LOW;
   --

   type Init_Type is
      record
         Request : Request_Type;
         Direction : Direction_Type;
         Peripheral_Increment : Increment_Type;
         Memory_Increment : Increment_Type;
         Peripheral_Data_Alignment : Data_Alignment_Type;
         Memory_Data_Alignment : Data_Alignment_Type;
         Mode : Mode_Type;
         Priority : Priority_Type;
      end record;
   --  Direct Memory Access (DMA) communication parameters
   --
   --  @field Request Specifies the request selected for the specified channel
   --  @field Direction Specifies the data transfer direction
   --  @field Peripheral_Increment Specifies whether the address is
   --    incremented
   --  @field Memory_Increment Specifies whether the address is incremented
   --  @field Peripheral_Data_Alignment Specifies the data width
   --  @field Memory_Data_Alignment Specifies the data width
   --  @field Mode Specifies the operation mode
   --  @field Priority Specifies the software priority

   type State_Type is
      (RESET, READY, BUSY, TIMEOUT)
      with Default_Value => RESET;
   --
   --  @enum RESET Transfer not yet initialized or disabled
   --  @enum READY Initialized and ready for use
   --  @enum BUSY Process is ongoing
   --  @enum TIMEOUT Timeout state

   type Handle_Type;
   type Callback_Access_Type
      is access procedure (Handle : Handle_Type);
   --

   type Error_Code_Type is
      (NONE, TE, NO_TRANSFER, TIMEOUT, NOT_SUPPORTED);
   --

   type Handle_Type is
      record
         Instance : Instance_Type;
         Channel : Channel_Type;
         Init : Init_Type;
         State : State_Type;
         Parent : System.Address;
         Transfer_Complete : Callback_Access_Type;
         Transfer_Half_Complete : Callback_Access_Type;
         Transfer_Error : Callback_Access_Type;
         Transfer_Abort : Callback_Access_Type;
         Error_Code : Error_Code_Type;
      end record;
   --  Direct Memory Access (DMA) handle structure definition
   --
   --  Implementation nodes
   --  - TODO Implement Lock
   --
   --  @field Instance Direct Memory Access (DMA) peripheral reference
   --  @field Channel  Direct Memory Access (DMA) channel reference
   --  @field Init Communication parameters
   --  @field State Transfer state
   --  @field Parent Parent object state
   --  @field Transfer_Complete Transfer complete callback
   --  @field Transfer_Half_Complete Half transfer complete callback
   --  @field Transfer_Error Transfer error callback
   --  @field Transfer_Abort Transfer abort callback
   --  @field Error code

   ---------------------------------------------------------------------------
   function Init (Handle : in out Handle_Type)
      return Status_Type;
   --  Init
   --
   --  Initialize the specific DMA Channel
   --
   --  @param Handle Configuration information for the specified DMA Channel
   --  @return Status of operations.

private

   for Priority_Type use (
      LOW => 2#00#,
      MEDIUM => 2#01#,
      HIGH => 2#10#,
      VERY_HIGH => 2#11#);
   --

   for Data_Alignment_Type use (
      BYTE => 2#00#,
      HALF_WORD => 2#01#,
      WORD => 2#10#);
   --

   for Mode_Type use (
      NORMAL => 2#0#,
      CIRCULAR => 2#1#);
   --

end HAL.DMA;
