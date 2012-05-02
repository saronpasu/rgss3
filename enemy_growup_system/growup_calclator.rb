#-*- encoding: utf-8 -*-
# for RGSS3 powored by Ruby1.9.2
# coded by saronpasu.


module Enemy_GrowUp_System
  # 成長関係の処理を行うモジュール Game_Enemy[Instance]#extend(mod) して使う
  module GrowUp_Calculator
    # 定数：成長タイプの一覧
    GROWUP_TYPES = [
      # 平凡タイプ
      :Basic_Enemy, # type_id == 1
      # 攻撃タイプ
      :Offenser,    # type_id == 2
      # 魔法タイプ
      :Magic,       # type_id == 3
      # 防御タイプ
      :Diffeser,    # type_id == 4
      # 回復タイプ
      :Recoverer,   # type_id == 5
      # 補助タイプ
      :Supporter,   # type_id == 6
      # 阻害タイプ
      :Blocker,     # type_id == 7
      # 特殊タイプ
      :Special,     # type_id == 8
      # 特徴特化タイプ
      :Featurer     # type_id == 9
    ]
    
    # 成長タイプを決定する(初回の成長時にのみ実行)
    def growup_type_categorize
      params_sum = [atk, param(3), mat, mdf, agi, luk].inject(:+).to_f
      # 必須条件
      second_conditions = [
        false,                           # 平凡タイプ
        (atk / params_sum) >= 0.15,      # 攻撃タイプ
        (mat / params_sum) >= 0.15,      # 魔法タイプ
        (param(3) / params_sum) >= 0.15, # 防御タイプ
        (mmp / mhp) >= 0.1,              # 回復タイプ
        (mmp / mhp) >= 0.1,              # 補助タイプ
        (mmp / mhp) >= 0.1,              # 阻害タイプ
        enemy.actions.size >= 3,         # 特殊タイプ
        enemy.features.size >= 6         # 特徴特化タイプ
      ]
      # 確定条件
      first_conditions = [
        # 平凡タイプは確定条件なし
        false,
        # 攻撃タイプは確定条件なし
        false,
        # 魔法タイプは魔法スキルを所持していれば確定
        !!enemy.actions.find{|i|$data_skills[i.skill_id].magical?},
        # 防御タイプは確定条件なし
        false,
        # 回復タイプは回復スキルを所持していれば確定
        (!!enemy.actions.find{|i|
          $data_skills[i.skill_id].damage.recover?
        } or !!enemy.actions.find{|i|
          $data_skills[i.skill_id].effects.find{|j|j.code.eql?(11)}
        }),
        # 補助タイプは能力強化スキルを所持していれば確定
        !!enemy.actions.find{|i|
          $data_skills[i.skill_id].effects.find{|j|j.code.eql?(31)}},
        # 阻害タイプは能力弱体スキルを所持していれば確定
        !!enemy.actions.find{|i|
          $data_skills[i.skill_id].effects.find{|j|j.code.eql?(32)}},
        # 特殊タイプは確定条件なし
        false,
        # 特徴特化タイプは確定条件なし
        false
      ]
      
      print("成長タイプの判別を実行\n") if $DEBUG
      list = []
      second_conditions.each_with_index{|n,idx|list.push(idx)if n}
      print("判別処理その１\n") if $DEBUG
      print("結果[#{list.inspect}]\n") if $DEBUG
      first_conditions.each_with_index{|n,idx|list.push(idx)if n} if list.empty?
      print("判別処理その２\n") if $DEBUG
      print("結果[#{list.inspect}]\n") if $DEBUG
      list.push(0) if list.empty?
      print("判別処理その３\n") if $DEBUG
      print("結果[#{list.inspect}]\n") if $DEBUG
      
      list.sample+1
    end
    
    # 成長速度を算出
    def calcurate_growup_speed
      [3, (enemy.features.size+enemy.actions.size).div(2)].max
    end
    
    # 成長処理の準備
    def setup_growup_calcurator
      print("成長処理の準備を開始\n") if $DEBUG
      growup_type_id = @growup_record.growup_type
      
      # 初回のみ成長タイプの判別を行う
      if growup_type_id.zero? then
        print("成長タイプの自動判別を開始\n") if $DEBUG
        growup_type_id = growup_type_categorize
        @growup_record.growup_type = growup_type_id
        print("成長タイプ[#{growup_type_id}]\n") if $DEBUG
        print("成長タイプの自動判別を終了\n\n") if $DEBUG
      end
      # 初回のみ成長速度の判別を行う
      growup_speed = @growup_record.growup_speed
      if growup_speed.zero? then
        print("成長速度の自動判別を開始\n") if $DEBUG
        growup_speed = calcurate_growup_speed
        @growup_record.growup_speed = growup_speed
        print("成長速度[#{growup_speed}]\n") if $DEBUG
        print("成長速度の自動判別を終了\n\n") if $DEBUG
      end
      
      klass = Enemy_GrowUp_System.const_get(GROWUP_TYPES[growup_type_id-1]).new
      @growup_type = klass
      print("成長処理の準備を終了\n\n") if $DEBUG
    end
    
    # 成長スコアの合計
    def growup_score_sum
      scores = [
        @battle_record.hp_damage,
        @battle_record.mp_damage,
        @battle_record.physical_damage,
        @battle_record.magical_damage,
        @battle_record.mp_payment,
        @battle_record.tp_payment
      ]
      growup_score_rate = @growup_type.growup_score_rate
      scores.zip(growup_score_rate).inject(0){|r,i|r+=i.first*i.last}
    end
    
    # 成長スコアから、現在の成長回数を算出
    def caluclate_current_growup_count
      print("成長スコアから現在の成長回数を算出\n") if $DEBUG
      growup_score = growup_score_sum
      growup_speed = @growup_record.growup_speed
      print("  成長スコア[#{growup_score}]\n") if $DEBUG
      print("  成長速度[#{growup_speed}]\n") if $DEBUG
      growup_score.div(mhp + mmp).div(growup_speed)
    end
    
    # 成長処理を行う
    def growup_chance
      print("成長処理を開始します\n") if $DEBUG
      growup_count = @growup_record.growup_count
      current_growup_count = caluclate_current_growup_count
      growup_speed = @growup_record.growup_speed
      while growup_count < current_growup_count do
        growup_count += 1
        print("[#{growup_count}]回目の成長処理を実行中\n") if $DEBUG
        
        growup_learn if growup_count.modulo(growup_speed).zero?
        print("基本成長を開始します\n") if $DEBUG
        growup
        print("基本成長を終了します\n\n") if $DEBUG
      end
      print("成長レコードへ成長回数を追記\n") if $DEBUG
      @growup_record.growup_count = growup_count
      print("成長処理を終了します\n\n") if $DEBUG
    end
    
    # 基本成長
    def growup
      print("基本成長を実行\n") if $DEBUG
      
      growup_params.each_with_index{|d, idx|
        r = @growup_record.basic_param(idx)
        @growup_record.basic_param= idx, r+d
        print("パラメータ[#{idx}]が[#{d}]成長\n") if $DEBUG
      }
      growup_count = @growup_record.growup_count
      growup_speed = @growup_record.growup_speed
      r_exp = @growup_record.exp
      r_exp += enemy.exp * (0.2 * growup_count * growup_speed)
      print("獲得経験値が上昇\n") if $DEBUG
      @growup_record.exp = r_exp
      r_gold = @growup_record.gold
      r_gold += enemy.gold * (0.4 * growup_count * growup_speed)
      print("獲得ゴールドが上昇\n") if $DEBUG
      @growup_record.gold = r_gold
      
      print("基本成長を終了\n\n") if $DEBUG
    end
    
    # スキル、特徴の習得
    def growup_learn
      s_limit = learn_skill_limit?
      f_limit = learned_feature_limit?
      
      case
        when s_limit && f_limit
          forget_skill
          forget_feature
          print("スキル・特徴を忘却\n") if $DEBUG
        when s_limit && !f_limit
          learn_feature
          return
        when !s_limit && f_limit
          learn_skill
          return
      end
      
      if [true,false].sample then
        learn_skill
        return
      else
        learn_feature
        return
      end
    end
    
    # 行動条件の生成
    def generate_action(skill_id)
      print("行動条件の生成を開始\n") if $DEBUG
      
      print("必要な情報を取得しています\n") if $DEBUG
      rating_max = enemy.actions.map{|a|a.rating}.max
      rating_zero = rating_max - 3
      # 行動条件生成用の内容を準備
      round_alive_turn = @battle_record.round_alive_turn
      receive_states = received_states
      action = RPG::Enemy::Action.new
      condition_codes = [0]
      condition_codes += [1,2] if round_alive_turn >= 3
      condition_codes += [4] unless receive_states.empty?
      condition_code = condition_codes.sample
      condition_param1, condition_param2 = 0, 0
      print("必要な情報を取得しました\n") if $DEBUG
      
      print("行動条件を生成します\n") if $DEBUG
      case condition_code
        when 1
          condition_param1 = 0
          condition_param2 = 1.upto(round_alive_turn).to_a.sample
        when 2
          condition_param1 = 10.upto(30).to_a.sample
          condition_param2 = 70.upto(100).to_a.sample
        when 4
          condition_param1 = receive_states.sample
      end
      rating = rating_zero+1.upto(rating_max).to_a.sample
      action.skill_id = skill_id
      action.rating = rating
      action.condition_type = condition_code
      action.condition_param1 = condition_param1
      action.condition_param2 = condition_param2
      
      print("行動条件の生成を終了\n\n") if $DEBUG
      return action
    end
    
    # 基本能力の成長値を算出
    def growup_params
      params = [mhp,mmp,atk,param(3),mat,mdf,agi,luk]
      basic_param_rate = @growup_type.basic_param_rate
      params.zip(basic_param_rate).map{|i|(i.first*i.last).round-i.first}
    end
    
    # 受けたことのあるステートを返す
    def received_states
      0.upto($data_states.size-1).map{|i|
        skill_id = @battle_record.receive_state(i)
      }.reject{|i|i.zero?}
    end
    
    # 覚えたスキルを返す
    def learned_skills
      0.upto(GrowUp_Record::LEARNED_SKILL_MAX-1).map{|i|
        skill_id = @growup_record.learned_skill(i)
      }.reject{|i|i.zero?}
    end
    
    # スキル枠の限界かどうかを返す
    def learn_skill_limit?
      learned_skills.size == GrowUp_Record::LEARNED_SKILL_MAX
    end
    
    # スキルを忘れる
    def forget_skill
      @growup_record.learned_skill= learned_skills.size-1, 0
    end
    
    # スキルを習得する
    def learn_skill
      print("スキルの習得を実行します\n") if $DEBUG
      skill_list = @growup_type.skill_select
      new_skill = (skill_list - learned_skills).sample
      unless new_skill.zero?
        @growup_record.learned_skill= learned_skills.size, new_skill
      end
      print("新たなスキル[#{new_skill}]を習得しました\n") if $DEBUG
    end
    
    # 覚えた特徴を返す
    def learned_features
      features = 0.upto(GrowUp_Record::LEARNED_FEATURE_MAX-1).map{|i|
        @growup_record.learned_feature(i)
      }.reject{|i|i.zero?}
    end
    
    # 特徴枠の限界かどうかを返す
    def learned_feature_limit?
      learned_features.size == GrowUp_Record::LEARNED_FEATURE_MAX
    end
    
    # 特徴を忘れる
    def forget_feature
      @growup_record.learned_feature= learned_features.size-1, 0
    end
    
    # 特徴を覚える
    def learn_feature
      print("特徴の習得を実行します\n") if $DEBUG
      new_feature = 1.upto(@growup_type.feature_sources.size).to_a.sample
      unless new_feature.zero? then
        @growup_record.learned_feature= learned_features.size, new_feature
      end
      print("新たな特徴[#{new_feature}]を習得しました\n") if $DEBUG
    end
    
    # 成長内容を反映：基本能力
    def upgrade_basic_params
      growup_params = 0.upto(7){|i|
        print("能力[#{i}]が") if $DEBUG
        print("[#{@growup_record.basic_param(i)}]成長しました\n") if $DEBUG
        @growup_enemy.params[i]+=@growup_record.basic_param(i)
      }
      print("獲得経験値が[#{@growup_record.exp}]増加しました\n") if $DEBUG
      @growup_enemy.exp + @growup_record.exp
      print("獲得ゴールドが[#{@growup_record.gold}]増加しました\n") if $DEBUG
      @growup_enemy.gold + @growup_record.gold
    end
    
    # 成長内容を反映：習得スキル
    def extend_actions
      print("覚えたスキルを反映します\n") if $DEBUG
      actions = []
      actions += learned_skills.map{|i|
        print("スキル[#{i}]を追加しました\n") if $DEBUG
        generate_action(i)
      } unless learned_skills.empty?
      @growup_enemy.instance_variable_set(:@growup_actions, actions)
      @growup_enemy.instance_eval do 
        def actions
          @actions + @growup_actions
        end
      end
      print("覚えたスキルを反映しました\n\n") if $DEBUG
    end
    
    # 成長内容を反映：習得特徴
    def extend_features
      print("覚えた特徴を反映します\n") if $DEBUG
      growup_types_feature_list = @growup_type.generate_feature
      growup_features = learned_features.map{|i|
        print("特徴[#{i-1}]を追加しました\n") if $DEBUG
        growup_types_feature_list[i-1]
      }
      @growup_enemy.instance_variable_set(:@growup_features, growup_features)
      @growup_enemy.instance_eval do
        def features
          @features + @growup_features
        end
      end
      print("覚えた特徴を反映しました\n\n") if $DEBUG
    end
    
  end
end


