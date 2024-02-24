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

with System.Address_To_Access_Conversions;

with CMSIS.Device;
   use CMSIS.Device;
with CMSIS.Device.TIM;
   use CMSIS.Device.TIM;
with CMSIS.Device.TIM.Instances;
   use CMSIS.Device.TIM.Instances;

package body HAL.TIM is
   --  HAL TIM Generic Driver body
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Src/stm32l0xx_hal_tim.c

   -------------------------------------------------------------------------
   procedure Base_Set_Config (Instance  : Instance_Type;
                              Base_Init : Base_Init_Type);

   procedure Base_Set_Config (Instance  : Instance_Type;
                              Base_Init : Base_Init_Type) is
   begin

      --  Select the Counter Mode if supported
      if Supports_Counter_Mode_Select (Instance)
      then
         TIMx (Instance).CR1 := (@ with delta
            DIR => (
               case Base_Init.Counter_Mode is
                  when DOWN => 2#1#,
                  when others => 2#0#),
            CMS => (
               case Base_Init.Counter_Mode is
                  when CENTER_ALIGNED_1 => 2#01#,
                  when CENTER_ALIGNED_2 => 2#10#,
                  when CENTER_ALIGNED_3 => 2#11#,
                  when others => 2#00#));
      end if;

      --  Set the clock division if supported
      if Supports_Clock_Division (Instance)
      then
         TIMx (Instance).CR1.CKD := Base_Init.Clock_Division'Enum_Rep;
      end if;

      --  Set the auto-reload preload, the auto-reload value and the
      --  pre-scaler values
      TIMx (Instance).CR1.ARPE := Base_Init.Auto_Reload_Preload'Enum_Rep;
      TIMx (Instance).ARR.ARR_L := ARR_ARR_L_Field (Base_Init.Period);
      TIMx (Instance).PSC.PSC := PSC_PSC_Field (
         Natural (Base_Init.Prescaler) - 1);

      --  Generate an update event to reload the pre-scaler and the repetition
      --  counter (only for advanced timer) value immediately
      TIMx (Instance).EGR.UG := 2#1#;

   end Base_Set_Config;

   ---------------------------------------------------------------------------
   procedure OC1_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type);

   procedure OC1_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type) is
   begin

      TIMx (Instance).CCER.CC1E := 2#0#;

      TIMx (Instance).CCMR1_Output := (@ with delta
         OC1M => Config.Mode'Enum_Rep,
         CC1S => 2#00#);

      TIMx (Instance).CCR1.CCR1_L := CCR1_CCR1_L_Field (Config.Pulse);

      TIMx (Instance).CCER.CC1P := Config.Polarity'Enum_Rep;

   end OC1_Set_Config;

   ---------------------------------------------------------------------------
   procedure OC2_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type);

   procedure OC2_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type) is
   begin

      TIMx (Instance).CCER.CC2E := 2#0#;

      TIMx (Instance).CCMR1_Output := (@ with delta
         OC2M => Config.Mode'Enum_Rep,
         CC2S => 2#00#);

      TIMx (Instance).CCR2.CCR2_L := CCR2_CCR2_L_Field (Config.Pulse);

      TIMx (Instance).CCER.CC2P := Config.Polarity'Enum_Rep;

   end OC2_Set_Config;

   ---------------------------------------------------------------------------
   procedure OC3_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type);

   procedure OC3_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type) is
   begin

      TIMx (Instance).CCER.CC3E := 2#0#;

      TIMx (Instance).CCMR2_Output := (@ with delta
         OC3M => Config.Mode'Enum_Rep,
         CC3S => 2#00#);

      TIMx (Instance).CCR3.CCR3_L := CCR3_CCR3_L_Field (Config.Pulse);

      TIMx (Instance).CCER.CC3P := Config.Polarity'Enum_Rep;

   end OC3_Set_Config;

   ---------------------------------------------------------------------------
   procedure OC4_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type);

   procedure OC4_Set_Config (Instance : Instance_Type;
                             Config   : PWM_Init_Type) is
   begin

      TIMx (Instance).CCER.CC4E := 2#0#;

      TIMx (Instance).CCMR2_Output := (@ with delta
         OC4M => Config.Mode'Enum_Rep,
         CC4S => 2#00#);

      TIMx (Instance).CCR4.CCR4_L := CCR4_CCR4_L_Field (Config.Pulse);

      TIMx (Instance).CCER.CC4P := Config.Polarity'Enum_Rep;

   end OC4_Set_Config;

   ---------------------------------------------------------------------------
   procedure CCx_Channel_Command (Instance : Instance_Type;
                                  Channel  : Channel_Type;
                                  Enable   : Boolean);
   --  Enables or disables the Timer (TIM) Capture Compare channel

   procedure CCx_Channel_Command (Instance : Instance_Type;
                                  Channel  : Channel_Type;
                                  Enable   : Boolean) is
   begin

      --  Reset the CCxE bit before applying the configuration
      case Channel is
         when CHANNEL_1 =>
            TIMx (Instance).CCER.CC1E := 2#0#;
            TIMx (Instance).CCER.CC1E := Enable'Enum_Rep;
         when CHANNEL_2 =>
            TIMx (Instance).CCER.CC2E := 2#0#;
            TIMx (Instance).CCER.CC2E := Enable'Enum_Rep;
         when CHANNEL_3 =>
            TIMx (Instance).CCER.CC3E := 2#0#;
            TIMx (Instance).CCER.CC3E := Enable'Enum_Rep;
         when CHANNEL_4 =>
            TIMx (Instance).CCER.CC4E := 2#0#;
            TIMx (Instance).CCER.CC4E := Enable'Enum_Rep;
      end case;

   end CCx_Channel_Command;

   ---------------------------------------------------------------------------
   function Is_Slave_Mode_Trigger_Enabled (Instance : Instance_Type)
      return Boolean is
      (TIMx (Instance).SMCR.SMS = 2#110#)
      with Inline;

   ---------------------------------------------------------------------------
   procedure DMA_Delay_Pulse_Callback (Handle : HAL.DMA.Handle_Type);
   --  DMA Delay Pulse complete callback
   --
   --  @param Handle Direct Memory Access (DMA) handle

   procedure DMA_Delay_Pulse_Callback (Handle : HAL.DMA.Handle_Type) is

      package Handles_Conversions is new
         System.Address_To_Access_Conversions (Handle_Type);
      use Handles_Conversions;

      use all type HAL.DMA.Mode_Type;

      TIM_Handle : constant access Handle_Type := To_Pointer (Handle.Parent);

      CCxDE_Values : constant array (Channel_Type)
         of Boolean := [
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC1DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC2DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC3DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC4DE)];
   begin

      for Channel in Channel_Type
      loop
         if CCxDE_Values (Channel)
         then
            TIM_Handle.Active_Channel := (Valid   => True,
                                          Channel => Channel);
            if Handle.Init.Mode = NORMAL
            then
               TIM_Handle.Channels_State (Channel) := READY;
            end if;

            exit;
         end if;
      end loop;

      if TIM_Handle.Pulse_Finished_Callback /= null
      then
         TIM_Handle.Pulse_Finished_Callback (TIM_Handle.all);
      end if;

      TIM_Handle.Active_Channel := (Valid => False);

   end DMA_Delay_Pulse_Callback;

   ---------------------------------------------------------------------------
   procedure DMA_Delay_Pulse_Half_Callback (Handle : HAL.DMA.Handle_Type);
   --  DMA Delay Pulse half complete callback
   --
   --  @param Handle Direct Memory Access (DMA) handle

   procedure DMA_Delay_Pulse_Half_Callback (Handle : HAL.DMA.Handle_Type) is

      package Handles_Conversions is new
         System.Address_To_Access_Conversions (Handle_Type);
      use Handles_Conversions;

      TIM_Handle : constant access Handle_Type := To_Pointer (Handle.Parent);

      CCxDE_Values : constant array (Channel_Type)
         of Boolean := [
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC1DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC2DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC3DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC4DE)];

   begin

      for Channel in Channel_Type
      loop
         if CCxDE_Values (Channel)
         then
            TIM_Handle.Active_Channel := (Valid   => True,
                                          Channel => Channel);
            exit;
         end if;
      end loop;

      if TIM_Handle.Half_Pulse_Callback /= null
      then
         TIM_Handle.Half_Pulse_Callback (TIM_Handle.all);
      end if;

      TIM_Handle.Active_Channel := (Valid => False);

   end DMA_Delay_Pulse_Half_Callback;

   ---------------------------------------------------------------------------
   procedure DMA_Error_Callback (Handle : HAL.DMA.Handle_Type);
   --  DMA Delay Pulse half complete callback
   --
   --  @param Handle Direct Memory Access (DMA) handle

   procedure DMA_Error_Callback (Handle : HAL.DMA.Handle_Type) is

      package Handles_Conversions is new
         System.Address_To_Access_Conversions (Handle_Type);
      use Handles_Conversions;

      use all type HAL.DMA.Mode_Type;

      TIM_Handle : constant access Handle_Type := To_Pointer (Handle.Parent);

      CCxDE_Values : constant array (Channel_Type)
         of Boolean := [
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC1DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC2DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC3DE),
            Boolean'Val (TIMx (TIM_Handle.Instance).DIER.CC4DE)];
   begin

      TIM_Handle.Active_Channel := (Valid => False);

      for Channel in Channel_Type
      loop
         if CCxDE_Values (Channel)
         then
            TIM_Handle.Active_Channel := (Valid   => True,
                                          Channel => Channel);
            if Handle.Init.Mode = NORMAL
            then
               TIM_Handle.Channels_State (Channel) := READY;
            end if;
            exit;
         end if;
      end loop;

      if not TIM_Handle.Active_Channel.Valid
      then
         TIM_Handle.State := READY;
      end if;

      if TIM_Handle.Error_Callback /= null
      then
         TIM_Handle.Error_Callback (TIM_Handle.all);
      end if;

      TIM_Handle.Active_Channel := (Valid => False);

   end DMA_Error_Callback;

   ---------------------------------------------------------------------------
   procedure Enable (Instance : Instance_Type);

   procedure Enable (Instance : Instance_Type) is
   begin

      TIMx (Instance).CR1.CEN := 2#1#;

   end Enable;

   ---------------------------------------------------------------------------
   procedure Disable (Instance : Instance_Type);

   procedure Disable (Instance : Instance_Type) is
   begin

      if (TIMx (Instance).CCER.CC1E = 0)
         and then (TIMx (Instance).CCER.CC2E = 0)
         and then (TIMx (Instance).CCER.CC3E = 0)
         and then (TIMx (Instance).CCER.CC4E = 0)
      then
         TIMx (Instance).CR1.CEN := 2#0#;
      end if;

   end Disable;

   ---------------------------------------------------------------------------
   procedure Set_DMA_Request (Instance : Instance_Type;
                              Request  : DMA_Request_Type;
                              Enable   : Boolean);
   --  Enable or disable the specified DMA request.

   procedure Set_DMA_Request (Instance : Instance_Type;
                              Request  : DMA_Request_Type;
                              Enable   : Boolean) is
   begin

      case Request is
         when UPDATE =>
            TIMx (Instance).DIER.UDE := Enable'Enum_Rep;
         when CAPTURE_COMPARE_1 =>
            TIMx (Instance).DIER.CC1DE := Enable'Enum_Rep;
         when CAPTURE_COMPARE_2 =>
            TIMx (Instance).DIER.CC2DE := Enable'Enum_Rep;
         when CAPTURE_COMPARE_3 =>
            TIMx (Instance).DIER.CC3DE := Enable'Enum_Rep;
         when CAPTURE_COMPARE_4 =>
            TIMx (Instance).DIER.TDE := Enable'Enum_Rep;
         when TRIGGER =>
            TIMx (Instance).DIER.CC4DE := 2#1#;
      end case;

   end Set_DMA_Request;

   ---------------------------------------------------------------------------
   procedure Enable_DMA (Instance : Instance_Type;
                         Request  : DMA_Request_Type;
                         Enable   : Boolean := True)
      renames Set_DMA_Request;

   ---------------------------------------------------------------------------
   procedure Disable_DMA (Instance : Instance_Type;
                          Request  : DMA_Request_Type;
                          Enable   : Boolean := False)
      renames Set_DMA_Request;

   -------------------------------------------------------------------------
   function PWM_Init (Handle : in out Handle_Type)
      return Status_Type is
      --  TODO:
      --  - Add support to Lock

      Success : constant Status_Type := OK;
   begin

      if Handle.State = RESET
         and then Handle.MSP_Init_Callback /= null
      then
         Handle.MSP_Init_Callback (Handle);
      end if;

      Handle.State := BUSY;

      Base_Set_Config (Handle.Instance, Handle.Init);

      Handle.Channels_State := [others => READY];
      Handle.State := READY;

      return Success;

   end PWM_Init;

   -------------------------------------------------------------------------
   function PWM_Config_Channel (Handle  : in out Handle_Type;
                                Init    : PWM_Init_Type;
                                Channel : Channel_Type)
      return Status_Type is
      --  TODO:
      --  - Add support to Lock
   begin

      case Channel is
         when CHANNEL_1 =>
            OC1_Set_Config (Handle.Instance, Init);
            TIMx (Handle.Instance).CCMR1_Output := (@ with delta
               OC1PE => 2#1#,
               OC1FE => Init.Fast_Mode'Enum_Rep);
         when CHANNEL_2 =>
            OC2_Set_Config (Handle.Instance, Init);
            TIMx (Handle.Instance).CCMR1_Output := (@ with delta
               OC2PE => 2#1#,
               OC2FE => Init.Fast_Mode'Enum_Rep);
         when CHANNEL_3 =>
            OC3_Set_Config (Handle.Instance, Init);
            TIMx (Handle.Instance).CCMR2_Output := (@ with delta
               OC3PE => 2#1#,
               OC3FE => Init.Fast_Mode'Enum_Rep);
         when CHANNEL_4 =>
            OC4_Set_Config (Handle.Instance, Init);
            TIMx (Handle.Instance).CCMR2_Output := (@ with delta
               OC4PE => 2#1#,
               OC4FE => Init.Fast_Mode'Enum_Rep);
      end case;

      return OK;

   end PWM_Config_Channel;

   ---------------------------------------------------------------------------
   function PWM_Start (Handle  : in out Handle_Type;
                       Channel : Channel_Type)
      return Status_Type is
   begin

      --  Input checks
      return ERROR when Handle.Channels_State (Channel) /= READY;

      Handle.Channels_State (Channel) := BUSY;

      --  Enable the Capture compare channel
      CCx_Channel_Command (Handle.Instance, Channel, True);

      --  Enable the Peripheral, except in trigger mode where enable is
      --  automatically done with trigger
      if not Supports_Slave_Mode (Handle.Instance)
         or else not Is_Slave_Mode_Trigger_Enabled (Handle.Instance)
      then
         Enable (Handle.Instance);
      end if;

      return OK;

   end PWM_Start;

   ---------------------------------------------------------------------------
   function PWM_Stop (Handle  : in out Handle_Type;
                      Channel : Channel_Type)
      return Status_Type is
   begin

      --  Disable the Capture compare channel and the Peripheral
      CCx_Channel_Command (Handle.Instance, Channel, False);
      Disable (Handle.Instance);

      Handle.Channels_State (Channel) := READY;

      return OK;

   end PWM_Stop;

   ---------------------------------------------------------------------------
   function PWM_Start_DMA (Handle       : in out Handle_Type;
                           Channel      : Channel_Type;
                           Data_Address : HAL.DMA.Address_Type;
                           Length       : HAL.DMA.Transfer_Length_Type)
      return Status_Type is

      DMA_Request : constant DMA_Request_Type := DMA_Request_Type'Val (
            DMA_Request_Type'Pos (CAPTURE_COMPARE_1)
            + Channel_Type'Pos (Channel) - Channel_Type'Pos (CHANNEL_1));

      CCRx_Address : constant HAL.DMA.Address_Type := HAL.DMA.Address_Type (
         case Channel is
            when CHANNEL_1 => TIMx (Handle.Instance).CCR1'Address,
            when CHANNEL_2 => TIMx (Handle.Instance).CCR2'Address,
            when CHANNEL_3 => TIMx (Handle.Instance).CCR3'Address,
            when CHANNEL_4 => TIMx (Handle.Instance).CCR4'Address);

      Channel_State : Channel_State_Type
         renames Handle.Channels_State (Channel);

      DMA_Handle : access HAL.DMA.Handle_Type
         renames Handle.DMA_Handles (DMA_Request);

      Status : Status_Type;
   begin

      return BUSY when Channel_State = BUSY;
      return ERROR when Channel_State /= READY;

      Channel_State := BUSY;

      DMA_Handle.Transfer_Complete_Callback :=
         DMA_Delay_Pulse_Callback'Access;
      DMA_Handle.Transfer_Error_Callback :=
         DMA_Error_Callback'Access;

      --  If the half pulse callback is not provided, there is not need to
      --  register it to the DMA driver
      if Handle.Half_Pulse_Callback /= null
      then
         DMA_Handle.Transfer_Half_Complete_Callback :=
            DMA_Delay_Pulse_Half_Callback'Access;
      end if;

      --  Enable the DMA channel
      Status := HAL.DMA.Start_IT (Handle => DMA_Handle.all,
                                  Source => Data_Address,
                                  Destination => CCRx_Address,
                                  Length => Length);
      return Status when Status /= OK;

      --  Enable the TIM Capture/Compare DMA request, the Output compare
      --  channel
      Enable_DMA (Handle.Instance, DMA_Request);
      CCx_Channel_Command (Handle.Instance, Channel, True);

      --  Enable the Peripheral, except in trigger mode where enable is
      --  automatically done with trigger
      if not Supports_Slave_Mode (Handle.Instance)
         or else not Is_Slave_Mode_Trigger_Enabled (Handle.Instance)
      then
         Enable (Handle.Instance);
      end if;

      return OK;

   end PWM_Start_DMA;

   ---------------------------------------------------------------------------
   function PWM_Stop_DMA (Handle  : in out Handle_Type;
                          Channel : Channel_Type)
      return Status_Type is

      DMA_Request : constant DMA_Request_Type := DMA_Request_Type'Val (
            DMA_Request_Type'Pos (CAPTURE_COMPARE_1)
            + Channel_Type'Pos (Channel) - Channel_Type'Pos (CHANNEL_1));

      DMA_Handle : access HAL.DMA.Handle_Type
         renames Handle.DMA_Handles (DMA_Request);

      UNUSED_Status : Status_Type;

   begin

      --  Disable the TIM Capture/Compare DMA request
      Disable_DMA (Handle.Instance, DMA_Request);
      UNUSED_Status := HAL.DMA.Abort_IT (DMA_Handle.all);

      --  Disable the Capture/Compare channel and the Peripheral
      CCx_Channel_Command (Handle.Instance, Channel, False);
      Disable (Handle.Instance);

      --  Set the TIM channel state
      Handle.Channels_State (Channel) := READY;

      return OK;

   end PWM_Stop_DMA;

   ---------------------------------------------------------------------------
   procedure Set_Prescaler (Handle    : in out Handle_Type;
                            Prescaler : Prescaler_Type) is
      --
   begin

      TIMx (Handle.Instance).PSC.PSC :=
         PSC_PSC_Field (Natural (Prescaler) - 1);
      Handle.Init.Prescaler := Prescaler;

   end Set_Prescaler;

   ---------------------------------------------------------------------------
   procedure Set_Autoreload (Handle     : in out Handle_Type;
                             Autoreload : Period_Type) is
      --
   begin

      TIMx (Handle.Instance).ARR.ARR_L := ARR_ARR_L_Field (Autoreload);
      Handle.Init.Period := Autoreload;

   end Set_Autoreload;

   ---------------------------------------------------------------------------
   procedure Set_Compare (Handle     : Handle_Type;
                          Channel    : Channel_Type;
                          Compare    : Pulse_Type) is
      --
   begin

      case Channel is
         when CHANNEL_1 =>
            TIMx (Handle.Instance).CCR1.CCR1_L :=
               CCR1_CCR1_L_Field (Compare);
         when CHANNEL_2 =>
            TIMx (Handle.Instance).CCR2.CCR2_L :=
               CCR2_CCR2_L_Field (Compare);
         when CHANNEL_3 =>
            TIMx (Handle.Instance).CCR3.CCR3_L :=
               CCR3_CCR3_L_Field (Compare);
         when CHANNEL_4 =>
            TIMx (Handle.Instance).CCR4.CCR4_L :=
               CCR4_CCR4_L_Field (Compare);

      end case;

   end Set_Compare;

end HAL.TIM;