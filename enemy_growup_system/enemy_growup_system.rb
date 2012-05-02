#-*- encoding: utf-8 -*-
# for RGSS3 powored by Ruby1.9.2
# coded by saronpasu.

=begin :nodoc:
  
  Enemy GrowUp System.
  
  author: saronpasu
  version: 0.0.1
  license: ruby's license
  for:
    rpgtkool vx ace(rpgmaker vx ace)
  
  エネミー成長システム
  
  ■概要説明■
    このスクリプトを適用すると、エネミーが成長するようになります
    成長ルールについては後述します
    このスクリプトはゲーム内容に変則性を持たせることを主な目的としています
    わかりやすく言うと、「カオス化」します
    
    エネミーは受けたダメージの総量に基づいて、成長を行います
    従って、敵を倒せば倒すほど、敵が強くなります
    
    詳しく書くと長くなるので readme.txt に移しました
    
  
=end

$saronpasu_rgss3 = {} if $saronpasu_rgss3.nil?
$saronpasu_rgss3[:enemy_growup_system] = true


# ソースコードを Kernel#require(source) して使う人用
# エディタに貼り付けて使うタイプの人は、コメントアウトしたままで使って下さい
=begin
require 'battle_record'
require 'growup_record'
require 'growup_type'
require 'growup_calclator'
=end

# GlobalSettings
module Enemy_GrowUp_System
  module Content_Manager
    # 戦闘レコードの初期化
    def create_battle_record
      Table.new(
        $data_enemies.size,
        Battle_Record::receive_state_addr +
        $data_states.size
      )
    end
    
    # 戦闘レコードのサイズ変更
    # (データベースへ新たなエネミーを追加した際に実行して下さい)
    def resize_battle_record(table)
      table.resize(
        $data_enemies.size,
        Battle_Record::receive_state_addr +
        $data_states.size
      )
    end
    
    # 初期化用にエイリアスメソッドを準備しておく
    alias_method :reset_battle_record, :create_battle_record
    
    # 成長レコードの初期化
    def create_growup_record
      Table.new(
        $data_enemies.size,
        GrowUp_Record::learned_feature_addr() +
        GrowUp_Record::LEARNED_FEATURE_MAX+1
      )
    end
    
    # 成長レコードのサイズ変更
    # (データベースへ新たなエネミーを追加した際に実行して下さい)
    def resize_growup_record(table)
      table.resize(
        $data_enemies.size,
        GrowUp_Record::learned_feature_addr() +
        GrowUp_Record::LEARNED_FEATURE_MAX+1
      )
    end
    
    # 初期化用にエイリアスメソッドを準備しておく
    alias_method :reset_growup_record, :create_growup_record
    
    # 指定エネミーの成長タイプを変更する
    # タイプはID番号かSymbolまたはStringで指定する
    def set_growup_type(enemy_id, growup_type)
      growup_record = Enemy_GrowUp_System::GrowUp_Record.new(
        $game_troop.growup_record, enemy_id
      )
      type = 0
      case growup_type
        when 0, :Basic_enemy, /Basic/
          type = 0
        when 1, :Offenser, /Offense/
          type = 1
        when 2, :Magic, /Magic/
          type = 2
        when 3, :Diffencer, /Diffencer/
          type = 3
        when 4, :Recoverer, /Recover/
          type = 4
        when 5, :Supporter, /Supporter/
          type = 5
        when 6, :Blocker, /Blocker/
          type = 6
        when 7, :Special, /Special/
          type = 7
        when 8, :Featurer, /Feature/
          type = 8
      end
      growup_record.growup_type= type
    end
    
    # 指定エネミーを成長させる
    def enemy_growup(enemy_id, count = 1)
      growup_record = Enemy_GrowUp_System::GrowUp_Record.new(
        $game_troop.growup_record, enemy_id
      )
      growup_record.growup_count -= count
      enemy = Game_Enemy.new(1, enemy_id)
      enemy.extend(Enemy_GrowUp_System::GrowUp_Calculator)
      enemy.setup_growup_calcurator
      enemy.growup_chance
      enemy.instance_variable_set(:@growup_type, nil)
    end
  end
end

class Game_Enemy < Game_Battler
  include Enemy_GrowUp_System
  
  attr_accessor :battle_record, :growup_record, :growup_type, :growup_enemy
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias_method :original_initialize, :initialize
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = mhp
    @mp = mmp
    
    return if $BTEST
    
    # added
    # 戦闘レコードをセットアップ
    @battle_record = Battle_Record.new($game_troop.battle_record, enemy_id)
    # for DEBUG
    print("エネミー[#{enemy.name}]の戦闘レコードをセットアップ\n") if $DEBUG
    
    # 成長レコードをセットアップ
    @growup_record = GrowUp_Record.new($game_troop.growup_record, enemy_id)
    # for DEBUG
    print("エネミー[#{enemy.name}]の成長レコードをセットアップ\n") if $DEBUG
    
    # RGSS研究所さんのスクリプト(033/106)との競合に対応
    # Resolve conflict of RGSS_LAB's library.
    if $rgsslab then
      enemy_level_initialize      if $rgsslab["敵レベル実装"]
      @hp = mhp
      @mp = mmp
      item_steal_initialize       if $rgsslab["アイテムスティール"]
      append_parameter_initialize if $rgsslab["パラメータの追加"]
    else
      @hp = mhp
      @mp = mmp
    end
    # DEICIDE ALMA レーネさんのアナライズとの競合に対応
    if $renne_rgss3 &&
      $renne_rgss3[:ememy_analyze] &&
      enemy.respond_to?(:analyze_data) then
      @analyze_data = enemy.analyze_data.dup
    end
    
    unless @growup_record.growup_count.zero? then
      print("エネミー[#{enemy.name}]の成長内容を反映します\n") if $DEBUG
      
      @growup_enemy = $data_enemies[@enemy_id].clone
      @growup_enemy = @unique_enemy if $saronpasu_rgss3[:game_system_difficulty]
      
      self.extend(Enemy_GrowUp_System::GrowUp_Calculator)
      setup_growup_calcurator
      extend_actions unless learned_skills.size.zero?
      extend_features unless learned_features.size.zero?
      print("エネミー[#{enemy.name}]の成長内容を反映しました\n\n") if $DEBUG
    end
  end
  
  alias_method :original_enemy, :enemy
  def enemy
    return $data_enemies[@enemy_id] if $BTEST
    if @growup_enemy then
      @growup_enemy
    else
      $data_enemies[@enemy_id]
    end
  end
  
  alias_method :original_param_base, :param_base
  def param_base(param_id)
    if @growup_record && !$BTEST then
      enemy.params[param_id] + @growup_record.basic_param(param_id)
    else
      enemy.params[param_id]
    end
  end
  
  def make_damage_value(user, item)
    super(user, item)
    
    return if $BTEST
    
    # for DEBUG
    print("エネミー[#{@enemy_id}]の戦闘レコードへの追記を開始\n") if $DEBUG
    
    if @result.success && item.damage.to_hp? && !item.damage.recover? then
      # HPダメージを戦闘レコードの累計へ加算
      @battle_record.hp_damage += @result.hp_damage
      # for DEBUG
      print("HPダメージ[#{@result.hp_damage}]を加算\n") if $DEBUG
      # 物理ダメージを戦闘レコードの累計へ加算
      @battle_record.physical_damage += @result.hp_damage if item.physical?
      # for DEBUG
      if $DEBUG && item.physical?
        print("物理ダメージ[#{@result.hp_damage}]を加算\n")
      end
      # 魔法ダメージを戦闘レコードの累計へ加算
      @battle_record.magical_damage += @result.hp_damage if item.magical?
      # for DEBUG
      if $DEBUG && item.magical?
        print("魔法ダメージ[#{@result.hp_damage}]を加算\n")
      end
      # 属性ダメージを戦闘レコードの累計へ加算(物理は除く)
      unless !item.damage.element_id.eql?(1) then
        record = @battle_record.elemental_damage += item.damage.element_id,
          @result.hp_damage
        # for DEBUG
        print("属性ダメージ[#{@result.hp_damage}]を加算\n") if $DEBUG
      end
    elsif @result.success && item.damage.to_mp? && item.damage.recove? then
      # MPダメージを戦闘レコードの累計へ加算
      @battle_record.mp_damage += @result.mp_damage
      # for DEBUG
      print("MPダメージ[#{@result.mp_damage}]を加算\n") if $DEBUG
      # 物理ダメージを戦闘レコードの累計へ加算
      @battle_record.physical_damage += @result.mp_damage if item.physical?
      # for DEBUG
      if $DEBUG && item.physical?
        print("物理ダメージ[#{@result.mp_damage}]を加算\n")
      end
      # 魔法ダメージを戦闘レコードの累計へ加算
      @battle_record.magical_damage += @result.mp_damage if item.magical?
      # for DEBUG
      if $DEBUG && item.physical?
        print("魔法ダメージ[#{@result.mp_damage}]を加算\n")
      end
      # 属性ダメージを戦闘レコードの累計へ加算(物理は除く)
      unless !item.damage.element_id.eql?(1) then
        record = @battle_record.elemental_damage += item.damage.element_id,
          @result.mp_damage
        # for DEBUG
        print("属性ダメージ[#{@result.mp_damage}]を加算\n") if $DEBUG
      end
    end
    # for DEBUG
    print("エネミー[#{@enemy_id}]の戦闘レコードへの追記を終了\n\n") if $DEBUG
    
  end
  
  #--------------------------------------------------------------------------
  # ● コラプス効果の実行
  #--------------------------------------------------------------------------
  alias_method :original_perform_collapse_effect ,:perform_collapse_effect
  def perform_collapse_effect
    case collapse_type
    when 0
      @sprite_effect_type = :collapse
      Sound.play_enemy_collapse
    when 1
      @sprite_effect_type = :boss_collapse
      Sound.play_boss_collapse1
    when 2
      @sprite_effect_type = :instant_collapse
    end
    
    return if $BTEST
    
    # for DEBUG
    print("エネミー[#{@enemy_id}]の戦闘レコードへの追記を開始\n") if $DEBUG
    # added
    # 累計戦闘不能回数をカウント
    @battle_record.dead_count += 1
    # for DEBUG
    print("戦闘不能回数を加算\n") if $DEBUG
    # 累計生存ターン数を加算
    @battle_record.alive_turn += $game_troop.turn_count
    # for DEBUG
    print("累計生存ターン数を加算\n") if $DEBUG
    # 平均生存ターンを算出
    @battle_record.round_alive_turn_calcurate
    # for DEBUG
    print("平均生存ターンを算出\n") if $DEBUG
    print("エネミー[#{@enemy_id}]の戦闘レコードへの追記を終了\n\n") if $DEBUG
    @growup_enemy = $data_enemies[@enemy_id].clone
    
  end
  
  def pay_skill_cost(skill)
    super(skill)
    
    return if $BTEST
    
    unless skill_mp_cost(skill).zero? then
      # for DEBUG
      print("エネミー[#{@enemy_id}]の戦闘レコードへの追記を開始\n") if $DEBUG
      # MP消費値を戦闘レコードの累計へ加算
      @battle_record.mp_payment += skill_mp_cost(skill)
      # for DEBUG
      print("MP消費値[#{skill_mp_cost(skill)}]を加算\n") if $DEBUG
    end
    unless skill_tp_cost(skill).zero? then
      # TP消費値を戦闘レコードの累計へ加算
      @battle_record.tp_payment += skill_tp_cost(skill)
      # for DEBUG
      print("TP消費値[#{skill_tp_cost(skill)}]を加算\n") if $DEBUG
      print("エネミー[#{@enemy_id}]の戦闘レコードへの追記を終了\n\n") if $DEBUG
    end
    
  end
  
  def add_new_state(state_id)
    super(state_id)
    
    return if $BTEST
    
    # 戦闘不能以外のステートかつ、戦闘レコードに未登録の
    # ステートの場合、戦闘レコードに受けたことのあるステートとして追加する
    unless state_id == death_state_id then
      start_of_size = @battle_record.receive_state_addr
      max_of_size = start_of_size + $data_states.size-1
      count_of_size = start_of_size.upto(max_of_size).to_a
      record = count_of_size.map{|i|@battle_record.receive_state(i)}
      find_obj = record.find{|i|i.eql?(state_id)}
      @battle_record.receive_state = state_id, 1 unless find_obj.eql?(1)
    end
  end
end

class Game_Troop < Game_Unit
  include Enemy_GrowUp_System::Content_Manager
  
  attr_accessor :battle_record
  attr_accessor :growup_record
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias_method :original_initialize, :initialize
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    clear
    
    return if $BTEST
    
    # added
    # 戦闘レコードを初期化
    @battle_record = create_battle_record
    # 成長レコードを初期化
    @growup_record = create_growup_record
    
  end
  
  def on_battle_end
    super()
    
    return if $BTEST
    
    print("成長処理を開始\n") if $DEBUG
    
    growup_targets = troop.members.map{|i|
      i.enemy_id
    }.uniq.map{|j|
      members.find{|k|
        k.enemy_id.eql?(j)
      }
    }
    growup_targets.each do |target|
      print("エネミー[#{target.enemy_id}]の成長処理を開始\n") if $DEBUG
      target.extend(Enemy_GrowUp_System::GrowUp_Calculator)
      target.setup_growup_calcurator
      target.growup_chance
      target.instance_variable_set(:@growup_type, nil)
      print("エネミー[#{target.enemy_id}]の成長処理を終了\n\n") if $DEBUG
    end
    
    print("成長処理を終了\n\n") if $DEBUG
  end
end





