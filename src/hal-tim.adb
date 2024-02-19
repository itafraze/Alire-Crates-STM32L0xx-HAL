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

      DIR_Value : constant CR1_DIR_Field := (case Base_Init.Counter_Mode is
         when DOWN => 2#1#,
         when others => 2#0#);
      --

      CMS_Value : constant CR1_CMS_Field := (case Base_Init.Counter_Mode is
         when CENTER_ALIGNED_1 => 2#01#,
         when CENTER_ALIGNED_2 => 2#10#,
         when CENTER_ALIGNED_3 => 2#11#,
         when others => 2#00#);
      --

      CKD_Value : constant CR1_CKD_Field := (case Base_Init.Clock_Division is
         when DIV1 => 2#00#,
         when DIV2 => 2#01#,
         when DIV4 => 2#10#);
      --

      ARPE_Value : constant CR1_ARPE_Field :=
         Base_Init.Auto_Reload_Preload'Enum_Rep;
      --

      ARR_L_Value : constant ARR_ARR_L_Field :=
         ARR_ARR_L_Field (Base_Init.Period);
      --

      PSC_Value : constant PSC_PSC_Field :=
         PSC_PSC_Field (Natural (Base_Init.Prescaler) - 1);
      --
   begin

      --  I supported, select the counter mode and clock division. Then set
      --  the auto-reload preload, the auto-reload value. Finally generate an
      --  update event to reload the pre-scaler and the repetition counter
      --  (only for advanced timer) value immediately
      case All_Instance_Type (Instance) is
         when TIM2 =>
            TIM2_Periph.CR1 := (@ with delta
               DIR => DIR_Value,
               CMS => CMS_Value,
               CKD => CKD_Value,
               ARPE => ARPE_Value);
            TIM2_Periph.ARR.ARR_L := ARR_L_Value;
            TIM2_Periph.PSC.PSC := PSC_Value;
            TIM2_Periph.EGR.UG := 2#1#;
         when TIM3 =>
            TIM3_Periph.CR1 := (@ with delta
               DIR => DIR_Value,
               CMS => CMS_Value,
               CKD => CKD_Value,
               ARPE => ARPE_Value);
            TIM3_Periph.ARR.ARR_L := ARR_L_Value;
            TIM3_Periph.PSC.PSC := PSC_Value;
            TIM3_Periph.EGR.UG := 2#1#;
         when TIM21 =>
            TIM21_Periph.CR1 := (@ with delta
               DIR => DIR_Value,
               CMS => CMS_Value,
               CKD => CKD_Value,
               ARPE => ARPE_Value);
            TIM21_Periph.ARR.ARR := ARR_L_Value;
            TIM21_Periph.PSC.PSC := PSC_Value;
            TIM21_Periph.EGR.UG := 2#1#;
         when TIM22 =>
            TIM22_Periph.CR1 := (@ with delta
               DIR => DIR_Value,
               CMS => CMS_Value,
               CKD => CKD_Value,
               ARPE => ARPE_Value);
            TIM22_Periph.ARR.ARR := ARR_L_Value;
            TIM22_Periph.PSC.PSC := PSC_Value;
            TIM22_Periph.EGR.UG := 2#1#;
         when TIM6 =>
            TIM6_Periph.CR1.ARPE := ARPE_Value;
            TIM6_Periph.ARR.ARR := ARR_L_Value;
            TIM6_Periph.PSC.PSC := PSC_Value;
            TIM6_Periph.EGR.UG := 2#1#;
         when TIM7 =>
            TIM7_Periph.CR1.ARPE := ARPE_Value;
            TIM7_Periph.ARR.ARR := ARR_L_Value;
            TIM7_Periph.PSC.PSC := PSC_Value;
            TIM7_Periph.EGR.UG := 2#1#;
      end case;

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