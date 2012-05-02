#-*- encoding: utf-8 -*-
# for RGSS3 powored by Ruby1.9.2
# coded by saronpasu.

module Enemy_GrowUp_System
  # 成長タイプの原型
  class GrowUp_Type
    # スキル検索の内容
    attr_accessor :skill_select_conditions
    # 特徴合成の内容
    attr_accessor :feature_sources
    # 基本能力の成長率
    attr_accessor :basic_param_rate
    # 成長スコアの加算率
    attr_accessor :growup_score_rate
    
    # スキル検索の実行
    def skill_select
      @skill_select_conditions.inject([]){|result, item|
        result += $data_skills[1..-1].select(&item).map{|i|i.id}
      }.uniq.compact
    end
    
    # 特徴合成の実行
    def generate_feature
      @feature_sources.map{|s|
        f = RPG::BaseItem::Feature.new
        f.code    = s[0]
        f.data_id = s[1]
        f.value   = s[2]
        f
      }.compact
    end
  end
  
  # 平凡タイプ
  class Basic_Enemy < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ対象はランダム、効果はHP回復
        lambda {|i|i.battle_ok? && i.for_random? && i.damage.recover?},
        # 覚えるスキル「戦闘時可能かつ対象は味方、TP消費は１以上
        lambda {|i|i.battle_ok? && i.for_friend? && i.tp_cost >= 1}
      ]
      @feature_sources = [
        # 覚える特徴「TP再生率１０～３０％
        [22, 9, (10.upto(30).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.2, # mhp
        1.1, # mmp
        1.2, # atk
        1.1, # def
        1.2, # mat
        1.1, # mdf
        1.0, # agi
        1.4  # luk
      ]
      @growup_score_rate = [
         1.2, # hp_damage
         1.2, # mp_damage
         1.0, # physical_damage
         1.2, # magical_damage
         5.2, # mp_payment
        12.8  # tp_payment
      ]
    end
  end
  
  # 攻撃タイプ
  class Offenser < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、命中判定は物理
        lambda {|i|i.battle_ok? && i.for_opponent? && i.physical?},
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、効果はHPダメージ
        lambda {|i|i.battle_ok? && i.for_opponent? && i.damage.to_hp?},
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、TP消費が１以上
        lambda {|i|i.battle_ok? && i.for_opponent? && i.tp_cost >= 1}
      ]
      @feature_sources = [
        # 覚える特徴「会心率１０～３０％
        [22, 2, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「反撃率１０～３０％
        [22, 6, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「TP再生率１０～３０％
        [22, 9, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「物理ダメージ率１１０～１３０％
        [23, 6, (110.upto(130).to_a.sample / 100.0)],
        # 覚える特徴「攻撃時属性（物理以外ランダム）
        [31, 
         2.upto($data_system.elements.size-1).to_a.sample, 0],
        # 覚える特徴「攻撃追加回数１
        [34, 0, 1]
      ]
      @basic_param_rate = [
        1.3, # mhp
        1.0, # mmp
        1.4, # atk
        1.3, # def
        1.0, # mat
        1.0, # mdf
        1.2, # agi
        1.1  # luk
      ]
      @growup_score_rate = [
         1.3, # hp_damage
         0.6, # mp_damage
         0.4, # physical_damage
         0.2, # magical_damage
         3.1, # mp_payment
        14.3  # tp_payment
      ]
    end
  end
  
  # 防御タイプ
  class Diffeser < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は自分自身
        lambda {|i|i.battle_ok? && i.for_user?},
        # 覚えるスキル「戦闘時可能かつTP消費が１以上
        lambda {|i|i.battle_ok? && i.tp_cost >= 1}
      ]
      @feature_sources = [
        # 覚える特徴「会心回避率１０～３０％
        [22, 3, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「魔法回避率１０～３０％
        [22, 4, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「魔法反射率１０～３０％
        [22, 5, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「HP再生率１０～３０％
        [22, 7, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「回復効果率１１０～１３０％
        [23, 2, (110.upto(130).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.4, # mhp
        1.0, # mmp
        1.0, # atk
        1.4, # def
        1.0, # mat
        1.3, # mdf
        1.0, # agi
        1.1  # luk
      ]
      @growup_score_rate = [
         1.4, # hp_damage
         0.2, # mp_damage
         0.9, # physical_damage
         0.8, # magical_damage
         1.0, # mp_payment
        12.2  # tp_payment
      ]
    end
  end
  
  # 魔法タイプ
  class Magic < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、命中判定は魔法
        lambda {|i|i.battle_ok? && i.for_opponent? && i.magical?},
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、消費MP１以上
        lambda {|i|i.battle_ok? && i.for_opponent? && i.mp_cost >= 1}
      ]
      @feature_sources = [
        # 覚える特徴「魔法反射率１０～３０％
        [22, 5, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「MP再生率１０～３０％
        [22, 8, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「魔法ダメージ率１１０～１３０％
        [23, 7, (110.upto(130).to_a.sample / 100.0)],
        # 覚える特徴「行動回数追加４０～７０％
        [61, 0, (40.upto(70).to_a.sample / 100.0)],
      ]
      @basic_param_rate = [
        1.0, # mhp
        1.3, # mmp
        1.0, # atk
        1.1, # def
        1.4, # mat
        1.2, # mdf
        1.0, # agi
        1.1  # luk
      ]
      @growup_score_rate = [
         0.8, # hp_damage
         1.3, # mp_damage
         0.6, # physical_damage
         0.8, # magical_damage
        23.3, # mp_payment
         6.4  # tp_payment
      ]
    end
  end
  
  # 回復タイプ
  class Recoverer < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は味方、効果は回復
        lambda {|i|i.battle_ok? && i.for_friend? && i.damage.recover?},
        # 覚えるスキル「戦闘時可能かつ使用対象は味方、消費MPは１以上
        lambda {|i|i.battle_ok? && i.for_friend? && i.mp_cost >= 1},
        # 覚えるスキル「戦闘時可能かつHP回復効果
        lambda {|i|i.battle_ok? && i.effects.find{|j|j.code.eql?(11)}},
        # 覚えるスキル「戦闘時可能かつ状態回復効果
        lambda {|i|i.battle_ok? && i.effects.find{|j|j.code.eql?(22)}}
      ]
      @feature_sources = [
        # 覚える特徴「MP再生率１０～３０％
        [22,8,(10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「追加行動４０～７０％
        [61,0,(40.upto(70).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.1, # mhp
        1.4, # mmp
        1.0, # atk
        1.2, # def
        1.4, # mat
        1.2, # mdf
        1.0, # agi
        1.1  # luk
      ]
      @growup_score_rate = [
         0.8, # hp_damage
         1.2, # mp_damage
         0.4, # physical_damage
         0.6, # magical_damage
        22.5, # mp_payment
         8.3  # tp_payment
      ]
    end
  end
  
  # 補助タイプ
  class Supporter < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は味方、消費MP１以上
        lambda {|i|i.battle_ok? && i.for_friend? && i.mp_cost >= 1},
        # 覚えるスキル「戦闘時可能かつ使用対象は味方、効果はステート追加
        lambda {|i|i.battle_ok? && 
          i.for_friend? && i.effects.find{|j|j.code.eql?(21)}},
        # 覚えるスキル「戦闘時可能かつ効果は能力強化
        lambda {|i|i.battle_ok? && i.effects.find{|j|j.code.eql?(31)}}
      ]
      @feature_sources = [
        # 覚える特徴「魔法反射率１０～３０％
        [22, 5, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「MP再生率１０～３０％
        [22, 8, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「行動回数追加４０～７０％
        [61, 0, (40.upto(70).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.1, # mhp
        1.4, # mmp
        1.0, # atk
        1.2, # def
        1.0, # mat
        1.0, # mdf
        1.2, # agi
        1.1  # luk
      ]
      @growup_score_rate = [
        0.8, # hp_damage
        0.9, # mp_damage
        0.4, # physical_damage
        0.6, # magical_damage
        8.3, # mp_payment
        4.4  # tp_payment
      ]
    end
  end
  
  # 阻害タイプ
  class Blocker < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、消費MP１以上
        lambda {|i|i.battle_ok? && i.for_opponent? && i.mp_cost >= 1},
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、効果はステート付与
        lambda {|i|i.battle_ok? && 
          i.for_opponent? && i.effects.find{|j|j.code.eql?(21)}},
        # 覚えるスキル「戦闘時可能かつ効果は弱体
        lambda {|i|i.battle_ok? && i.effects.find{|j|j.code.eql?(32)}}
      ]
      @feature_sources = [
        # 覚える特徴「MP再生率１０～３０％
        [22, 8, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「攻撃時属性（物理以外ランダム）
        [31, 
         2.upto($data_system.elements.size-1).to_a.sample, 0],
        # 覚える特徴「攻撃時追加ステート（戦闘不能以外ランダム）
        [32, 
         $data_states[2..-1].sample.id, (30.upto(50).to_a.sample / 100.0)],
        # 覚える特徴「追加行動４０～７０％
        [61, 0, (40.upto(70).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.2, # mhp
        1.4, # mmp
        1.0, # atk
        1.2, # def
        1.1, # mat
        1.1, # mdf
        1.0, # agi
        1.1  # luk
      ]
      @growup_score_rate = [
        0.8, # hp_damage
        0.7, # mp_damage
        0.6, # physical_damage
        0.4, # magical_damage
        9.3, # mp_payment
        4.4  # tp_payment
      ]
    end
  end
  
  # 特殊タイプ
  class Special < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ使用対象は敵、命中判定は必中
        lambda {|i|i.battle_ok? && i.for_opponent? && i.certain?},
        # 覚えるスキル「戦闘時可能かつ使用対象はランダム
        lambda {|i|i.battle_ok? && i.for_random?},
        # 覚えるスキル「戦闘時可能かつ使用対象は全体
        lambda {|i|i.battle_ok? && i.for_all?},
        # 覚えるスキル「戦闘時可能かつダメージなし
        lambda {|i|i.battle_ok? && i.damage.none?},
        # 覚えるスキル「戦闘時可能かつTP消費が１以上
        lambda {|i|i.battle_ok? && i.tp_cost >= 1},
        # 覚えるスキル「戦闘時可能かつ連続回数が２以上
        lambda {|i|i.battle_ok? && i.repeats >= 2}
      ]
      @feature_sources = [
        # 覚える特徴「魔法反射率１０～３０％
        [22, 5, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「反撃率１０～３０％
        [22, 6, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「TP再生率１０～３０％
        [22, 9, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「攻撃時属性（物理以外ランダム）
        [31, 
         2.upto($data_system.elements.size-1).to_a.sample, 0],
        # 覚える特徴「行動回数追加４０～７０％
        [61, 0, (40.upto(70).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.2, # mhp
        1.2, # mmp
        1.0, # atk
        1.1, # def
        1.0, # mat
        1.1, # mdf
        1.0, # agi
        1.3  # luk
      ]
      @growup_score_rate = [
         0.7, # hp_damage
         1.2, # mp_damage
         0.8, # physical_damage
         0.9, # magical_damage
         4.7, # mp_payment
        12.9  # tp_payment
      ]
    end
  end
  
  # 特徴特化タイプ
  class Featurer < GrowUp_Type
    def initialize
      @skill_select_conditions = [
        # 覚えるスキル「戦闘時可能かつ命中判定は物理、ダメージなし
        lambda {|i|i.battle_ok? && i.physical && i.damage.none?}
      ]
      @feature_sources = [
        # 覚える特徴「魔法反射率１０～３０％
        [22, 5, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「反撃率１０～３０％
        [22, 6, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「TP再生率１０～３０％
        [22, 9, (10.upto(30).to_a.sample / 100.0)],
        # 覚える特徴「攻撃時属性（物理以外ランダム）
        [31, 
         2.upto($data_system.elements.size-1).to_a.sample, 0],
        # 覚える特徴「攻撃時追加ステート（戦闘不能以外ランダム）
        [32, 
         $data_states[2..-1].sample.id, (30.upto(50).to_a.sample / 100.0)],
        # 覚える特徴「追加攻撃１
        [34, 0, 1.0],
        # 覚える特徴「追加行動４０～７０％
        [61,0,(40.upto(70).to_a.sample / 100.0)]
      ]
      @basic_param_rate = [
        1.2, # mhp
        1.1, # mmp
        1.0, # atk
        1.0, # def
        1.1, # mat
        1.0, # mdf
        1.1, # agi
        1.2  # luk
      ]
      @growup_score_rate = [
        0.8, # hp_damage
        0.9, # mp_damage
        0.9, # physical_damage
        1.2, # magical_damage
        4.7, # mp_payment
        8.9  # tp_payment
      ]
    end
  end
end


