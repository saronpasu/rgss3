#-*- encoding: utf-8 -*-
# for RGSS3 powored by Ruby1.9.2
# coded by saronpasu.


module Enemy_GrowUp_System
  class GrowUp_Record
    # 定数：覚えるスキルの上限
    LEARNED_SKILL_MAX   = 3
    # 定数：覚える特徴の上限
    LEARNED_FEATURE_MAX = 5
    
    attr_accessor :data, :enemy_id
    
    # スクリプト上部へ移動
    # 定数：覚えるスキルの上限
    # LEARNED_SKILL_MAX   = 3
    # 定数：覚える特徴の上限
    # LEARNED_FEATURE_MAX = 5
    
    # ２次元配列へのアドレス
    #==================================#
    def growup_type_addr();    0; end
    def growup_speed_addr();   1; end
    def growup_count_addr();   2; end
    def growup_score_addr();   3; end
    def basic_param_addr();    4; end
    def exp_addr();           12; end
    def gold_addr();          13; end
    def learned_skill_addr(); 14; end
    def learned_feature_addr()
      learned_skill_addr()+LEARNED_SKILL_MAX
    end
    def self.learned_skill_addr(); 14; end
    def self.learned_feature_addr()
      # learned_skill_addr()+LEARNED_SKILL_MAX
      14+LEARNED_SKILL_MAX-1
    end
    #==================================#
    
    def initialize(data, enemy_id = nil)
      @data = data
      @enemy_id ||= enemy_id
    end
    
    # 成長タイプID（参照用）
    def growup_type(enemy_id = @enemy_id)
      @data[enemy_id, growup_type_addr()]
    end
    
    # 成長タイプID（書き込み用）
    def growup_type=(input = 0)
      @data[enemy_id, growup_type_addr()] = input
    end
    
    # 成長速度（参照用）
    def growup_speed(enemy_id = @enemy_id)
      @data[enemy_id, growup_speed_addr()]
    end
    
    # 成長速度（書き込み用）
    def growup_speed=(input = 0)
      @data[enemy_id, growup_speed_addr()] = input
    end
    
    # 成長回数（参照用）
    def growup_count(enemy_id = @enemy_id)
      @data[enemy_id, growup_count_addr()]
    end
    
    # 成長回数（書き込み用）
    def growup_count=(input = 0)
      @data[enemy_id, growup_count_addr()] = input
    end
    
    # 成長スコア（参照用）
    def growup_score(enemy_id = @enemy_id)
      @data[enemy_id, growup_score_addr()]
    end
    
    # 成長スコア（書き込み用）
    def growup_score=(input = 0)
      @data[enemy_id, growup_score_addr()] = input
    end
    
    # 基本能力の増加値（参照用）
    def basic_param(param_id, enemy_id = @enemy_id)
      @data[enemy_id, basic_param_addr()+ param_id]
    end
    
    # 基本能力の増加値（書き込み用）
    def basic_param=(param_id, input = 0)
      param_id, input = param_id if param_id.is_a? Array
      @data[enemy_id, basic_param_addr()+param_id] = input
    end
    
    # 経験値の増加値（参照用）
    def exp(enemy_id = @enemy_id)
      @data[enemy_id, exp_addr()]
    end
    
    # 経験値の増加値（書き込み用）
    def exp=(input = 0)
      @data[enemy_id, exp_addr()] = input
    end
    
    # ゴールドの増加値（参照用）
    def gold(enemy_id = @enemy_id)
      @data[enemy_id, gold_addr()]
    end
    
    # ゴールドの増加値（書き込み用）
    def gold=(input = 0)
      @data[enemy_id, gold_addr()] = input
    end
    
    # 覚えたスキル（参照用）
    def learned_skill(skill_id, enemy_id = @enemy_id)
      @data[enemy_id, learned_skill_addr()+ skill_id]
    end
    
    # 覚えたスキル（書き込み用）
    def learned_skill=(skill_id, input = 0)
      skill_id, input = skill_id if skill_id.is_a? Array
      @data[enemy_id, learned_skill_addr()+ skill_id] = input
    end
    
    # 覚えた特徴（参照用）
    def learned_feature(feature_id, enemy_id = @enemy_id)
      @data[enemy_id, learned_feature_addr()+ feature_id]
    end
    
    # 覚えた特徴（書き込み用）
    def learned_feature=(feature_id, input = 0)
      feature_id, input = feature_id if feature_id.is_a? Array
      @data[enemy_id, learned_feature_addr()+ feature_id] = input
    end
  end
end


