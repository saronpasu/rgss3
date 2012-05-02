#-*- encoding: utf-8 -*-
# for RGSS3 powored by Ruby1.9.2
# coded by saronpasu.


module Enemy_GrowUp_System
  # 戦闘内容の記録
  class Battle_Record
    attr_accessor :data, :enemy_id
    
    # ２次元配列へのアドレス
    #==================================#
    def hp_damage_addr();        0; end
    def mp_damage_addr();        1; end
    def physical_damage_addr();  2; end
    def magical_damage_addr();   3; end
    def mp_payment_addr();       4; end
    def tp_payment_addr();       5; end
    def dead_count_addr();       6; end
    def alive_turn_addr();       7; end
    def round_alive_turn_addr(); 8; end
    def elemental_damage_addr(); 8; end
    def receive_state_addr()
      elemental_damage_addr()+$data_system.elements.size-1
    end
    def self.elemental_damage_addr(); 8; end
    def self.receive_state_addr()
      elemental_damage_addr()+$data_system.elements.size-1
    end
    #==================================#
    
    def initialize(data, enemy_id = nil)
      @data = data
      @enemy_id ||= enemy_id
    end
    
    # 累計HPダメージ（参照用）
    def hp_damage(enemy_id = @enemy_id)
      @data[enemy_id, hp_damage_addr]
    end
    
    # 累計HPダメージ（書き込み用）
    def hp_damage=(input = 0)
      @data[enemy_id, hp_damage_addr] = input
    end
    
    # 累計MPダメージ（参照用）
    def mp_damage(enemy_id = @enemy_id)
      @data[enemy_id, mp_damage_addr]
    end
    
    # 累計MPダメージ（書き込み用）
    def mp_damage=(input = 0)
      @data[enemy_id, mp_damage_addr] = input
    end
    
    # 累計物理ダメージ（参照用）
    def physical_damage(enemy_id = @enemy_id)
      @data[enemy_id, physical_damage_addr]
    end
    
    # 累計物理ダメージ（書き込み用）
    def physical_damage=(input = 0)
      @data[enemy_id, physical_damage_addr] = input
    end
    
    # 累計魔法ダメージ（参照用）
    def magical_damage(enemy_id = @enemy_id)
      @data[enemy_id, magical_damage_addr]
    end
    
    # 累計魔法ダメージ（書き込み用）
    def magical_damage=(input = 0)
      @data[enemy_id, magical_damage_addr] = input
    end
    
    # 累計属性ダメージ/属性別（参照用）
    def elemental_damage(element_id = 2, enemy_id = @enemy_id)
      @data[enemy_id, elemental_damage_addr+element_id]
    end
    
    # 累計属性ダメージ/属性別（書き込み用）
    def elemental_damage=(element_id, input = 0)
      @data[enemy_id, elemental_damage_addr+element_id] = input
    end
    
    # 累計消費MPコスト（参照用）
    def mp_payment(enemy_id = @enemy_id)
      @data[enemy_id, mp_payment_addr]
    end
    
    # 累計消費MPコスト（書き込み用）
    def mp_payment=(input = 0)
      @data[enemy_id, mp_payment_addr] = input
    end
    
    # 累計消費TPコスト（参照用）
    def tp_payment(enemy_id = @enemy_id)
      @data[enemy_id, tp_payment_addr]
    end
    
    # 累計消費TPコスト（書き込み用）
    def tp_payment=(input = 0)
      @data[enemy_id, tp_payment_addr] = input
    end
    
    # 受けたことのあるステート（参照用）
    def receive_state(state_id = 0, enemy_id = @enemy_id)
      @data[enemy_id, receive_state_addr+state_id]
    end
    
    # 受けたことのあるステート（書き込み用）
    def receive_state=(state_id = 0, input = 0)
      state_id, input = state_id if state_id.is_a? Array
      @data[enemy_id, receive_state_addr+state_id] = input
    end
    
    # 戦闘不能になった累計回数（参照用）
    def dead_count(enemy_id = @enemy_id)
      @data[enemy_id, dead_count_addr]
    end
    
    # 戦闘不能になった累計回数（書き込み用）
    def dead_count=(input = 0)
      @data[enemy_id, dead_count_addr] = input
    end
    
    # 生存ターン数累計（参照用）
    def alive_turn(enemy_id = @enemy_id)
      @data[enemy_id, alive_turn_addr]
    end
    
    # 生存ターン数累計（書き込み用）
    def alive_turn=(input = 0)
      @data[enemy_id, alive_turn_addr] = input
    end
    
    # 平均生存ターン数（参照用）
    def round_alive_turn(enemy_id = @enemy_id)
      @data[enemy_id, round_alive_turn_addr]
    end
    
    # 平均生存ターン数を算出
    def round_alive_turn_calcurate
      total_turns = alive_turn
      round_turns = total_turns.div(dead_count)
      @data[enemy_id, round_alive_turn_addr] = round_turns
    end
  end
end


