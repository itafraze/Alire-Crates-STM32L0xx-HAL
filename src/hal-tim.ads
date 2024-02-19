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

with CMSIS.Device.TIM.Instances;
   use all type CMSIS.Device.TIM.Instances.Instance_Type;
   use all type CMSIS.Device.TIM.Instances.Channel_Type;
with HAL.DMA;

package HAL.TIM is
   --  HAL TIM Generic Driver
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Inc/stm32l0xx_hal_tim.h

   subtype Instance_Type is
      CMSIS.Device.TIM.Instances.Instance_Type;
   --

   subtype Channel_Type is
      CMSIS.Device.TIM.Instances.Channel_Type;
   --

   type Prescaler_Type is
      new Positive range 1 .. 2**16
      with Default_Value => 1;
   --

   type Period_Type is
      new Natural range 0 .. 2**16 - 1
      with Default_Value => 0;
   --

   type Counter_Mode_Type is
      (UP, DOWN, CENTER_ALIGNED_1, CENTER_ALIGNED_2, CENTER_ALIGNED_3)
      with Default_Value => UP;
   --
   --  @enum UP Counter used as up-counter
   --  @enum DOWN Counter used as down-counter
   --  @enum CENTERALIGNED_1 The counter counts up and down alternatively.
   --    Output compare are set only when the counter is counting down.
   --  @enum CENTERALIGNED_2 The counter counts up and down alternatively.
   --    Output compare are set only when the counter is counting up.
   --  @enum CENTERALIGNED_3 The counter counts up and down alternatively.
   --    Output compare are set both when the counter is counting up or down.

   type Clock_Division_Type is
      (DIV1, DIV2, DIV4)
      with Default_Value => DIV1;
   --

   type Auto_Reload_Preload_Type is
      new Boolean
      with Default_Value => False;

   type Base_Init_Type is
      record
         Prescaler           : Prescaler_Type;
         Period              : Period_Type;
         Counter_Mode        : Counter_Mode_Type;
         Clock_Division      : Clock_Division_Type;
         Auto_Reload_Preload : Auto_Reload_Preload_Type;
      end record;
   --
   --
   --  @field Prescaler Specifies the pre-scaler value used to divide the TIM
   --    clock
   --  @field Period Specifies the period value to be loaded into the
   --     active Auto-Reload Register at the next update  event.
   --  @field Counter_Mode
   --  @field Clock_Division
   --  @field Auto_Reload_Preload Preload buffered or unbuffered

   type Active_Channel_Type (Valid : Boolean := False) is
      record
         case Valid is
            when True  => Channel : Channel_Type;
            when False => null;
         end case;
      end record;
   --

   type State_Type is
      (RESET, READY, BUSY, TIMEOUT, ERROR)
      with Default_Value => RESET;
   --

   type Channel_State_Type is
      (RESET, READY, BUSY)
      with Default_Value => RESET;
   --

   type Channels_State_Type is
      array (Channel_Type)
      of Channel_State_Type;
   --

   type Handle_Type;
   type Callback_Access_Type is
      access procedure (Handle : Handle_Type);
   --

   type Handle_Type is
      record
         Instance : Instance_Type := Instance_Type'First;
         Init : Base_Init_Type;
         Active_Channel : Active_Channel_Type := (Valid => False);
         DMA_Handle : access HAL.DMA.Handle_Type;
         State : State_Type;
         Channels_State : Channels_State_Type;
         Msp_Init : Callback_Access_Type;
         IC_Capture : Callback_Access_Type;
         OC_Delay_Elapsed : Callback_Access_Type;
         Pulse_Finished : Callback_Access_Type;
         Half_Pulse : Callback_Access_Type;
         Error : Callback_Access_Type;
      end record;
   --  Timer (TIM) handle structure definition
   --
   --  Implementation nodes
   --  - TODO Implement Lock
   --
   --  @field Instance
   --  @field Init
   --  @field Active_Channel
   --  @field DMA_Handle
   --  @field State
   --  @field Channels_State
   --  @field Msp_Init
   --  @field IC_Capture
   --  @field OC_Delay_Elapsed
   --  @field Pulse_Finished
   --  @field Half_Pulse
   --  @field Error

   -------------------------------------------------------------------------
   function PWM_Init (Handle : in out Handle_Type)
      return Status_Type;
   --  Initialises the TIM Pulse-Width Modulation (PWM) Time Base and the
   --  associated handle
   --
   --  @param Handle
   --  @returns Operations success status

private

   for Clock_Division_Type use (
      DIV1 => 2#00#,
      DIV2 => 2#01#,
      DIV4 => 2#10#);
   --

end HAL.TIM;