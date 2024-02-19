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

with CMSIS.Device.TIM;

package body HAL.TIM is
   --  HAL TIM Generic Driver body
   --
   --  Implementation notes:
   --  - Based on source files:
   --    - stm32l0xx_hal_driver:Src/stm32l0xx_hal_tim.c

   -------------------------------------------------------------------------
   procedure Base_Set_Config (Instance  : Instance_Type;
                              Base_Init : Base_Init_Type)
   is
      use CMSIS.Device.TIM;
      use CMSIS.Device.TIM.Instances;
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

   -------------------------------------------------------------------------
   function PWM_Init (Handle : in out Handle_Type)
      return Status_Type
   is
      --  TODO:
      --  - Add support to Lock

      Success : constant Status_Type := OK;
   begin

      if Handle.State = RESET
         and then Handle.Msp_Init /= null
      then
         Handle.Msp_Init (Handle);
      end if;

      Handle.State := BUSY;

      Base_Set_Config (Handle.Instance, Handle.Init);

      Handle.Channels_State := [others => READY];
      Handle.State := READY;

      return Success;

   end PWM_Init;

end HAL.TIM;