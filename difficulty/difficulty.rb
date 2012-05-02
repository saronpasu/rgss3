#-*- encoding: utf-8 -*-

=begin :rdoc:
  Game Difficulty Setting.
  author: saronpasu
  version: 0.3.5
    for rpgtkool vx ace(rpgmaker vx ace)
  lisence: ruby's license
  
  ■更新履歴■
  0.2.4       FSM登録
  0.2.6       RGSS_LAB's 033 に対応
  0.2.8       RGSS_LAB's 106 に対応
  0.3.0       RGSS LAB's 一部のScript との競合を解消
  0.3.4       DEICIDE ALMA STR_15 に対応
  0.3.5       DEICIDE ALMA アナライズ に対応
  

  ■説明■
    難易度設定に応じて、エネミーに個体差をつけます
  
  :About:
    Difficulty setting for battle.
    generate unique-enemy by difficulty-setting.

  ■使い方■
    $game_system.set_difficulty(difficulty) を呼び出し
    難易度を Game_System に設定してください。
  
    難易度をカスタマイズする場合は、
    Difficulty::{Hard|Normal|Easy}@rate または
    Difficulty::Rate::{HIGH|MID|LOW} の値を調整してください。
  
  :How to Use:
    set difficulty of Hard.
      $game_system.set_difficulty(:hard)
  
    for customize)
      setting to
        instance_variable "Difficulty::Hard#@rate"
        constants "Difficulty::Rate"
        
  ■補足説明■
  RGSS研究所のスクリプトと共用する場合は、
  RGSS研究所のスクリプトを << 読み込ませた後に >>、
  このスクリプトを読みこませるようにして下さい
  
=end

$saronpasu_rgss3 = {} if $saronpasu_rgss3.nil?
$saronpasu_rgss3[:game_system_difficulty] = true

class Game_System
  attr_accessor :difficulty

  module Difficulty
    HARD   =  1
    NORMAL =  0
    EASY   = -1
  end

  def hard?
    return @difficulty.eql?(Difficulty::HARD)
  end

  def normal?
    return (@difficulty.eql?(Difficulty::NORMAL) or @difficulty.nil?)
  end

  def easy?
    return @difficulty.eql?(Difficulty::EASY)
  end

  # 難易度設定を行う関数
  # Symbol か String か 定数で指定する
  # difficulity into Symbol or String or Constant
  def set_difficulty(difficulty)
    case difficulty
      when Difficulty::HARD, :hard, /hard|Hard|HARD/
        difficulty = Difficulty::HARD
      when Difficulty::NORMAL, :normal, /normalNormal|NORMAL/
        difficulty = Difficulty::NORMAL
        # difficulty = Difficulty::HARD
      when Difficulty::EASY, :easy, /easylEasy|EASY/
        difficulty = Difficulty::EASY
      else
        difficulty = Difficulty::NORMAL
        # difficulty = Difficulty::HARD
    end
    @difficulty = difficulty
  end
end

module VoCab
  Difficulty         = "難易度"
  Hard               = "ハード(難しい)"
  Normal             = "ノーマル(普通)"
  Easy               = "イージー(簡単)"
end

module Difficulty
=begin
  個体差の影響度の基本値
    カスタマイズを行う際は、この値を編集して下さい
    
    HIGH(影響を大きく受ける)  初期変動率: ±50%
    MID(影響をやや受ける)     初期変動率: ±25%
    LOW(影響を少し受ける)     初期変動率: ±10%
    NONE(影響を受けない)      未使用
    BASE(基本値)              内部処理用
=end
  module Rate
    HIGH =  50
    MID  =  25
    LOW  =  10
    NONE =   0
    BASE = 100
  end

  # 難易度システムの共通部分
  class Base
    attr_accessor :difficulty
    attr_accessor :rate
    
    # 基準値(100%)を返す
    def base
      Rate::BASE
    end
    
    # 変化なし(0%)を返す
    def none
      Rate::NONE
    end
    
    # 影響率：高(50%)を返す
    def high
      rand(Rate::HIGH)
    end
    
    # 影響率：中(25%)を返す
    def mid
      rand(Rate::MID)
    end
    
    # 影響率：低(10%)を返す
    def low
      rand(Rate::LOW)
    end
    
    private :base, :none, :high, :mid, :low
    
    # 難易度に応じて、強さを元に個体差の異なるエネミーを生成
    def generate_enemy(original)
      clone = original.dup
      params = []
      0.upto(7) do |i|
        params.push((original.params[i] * (@rate[i] / 100.0)).to_i)
      end
      exp = (original.exp * (@rate[8] / 100)).to_i
      gold = (original.exp * (@rate[9] / 100)).to_i
      clone.instance_variable_set(:@params, params)
      clone.instance_variable_set(:@exp, exp)
      clone.instance_variable_set(:@gold, gold)
      return clone
    end
    
    # 難易度に応じて、ドロップ率を変動させる
    def generate_drop_items(original)
      clone = original.dup
      clone.each do |i|
        denominator = i.denominator * (@rate[10] / 100.0)
        i.instance_variable_set(:@denominator, denominator)
      end
      return clone
    end
  end
  
  # 難易度「ハード」用クラス
  # カスタマイズする際には、@rate に加える修正内容を変更してください
  class Hard < Base
    def initialize
      @difficulty = :hard
      @rate = [
        base + high, # mhp 最大HPの変動率(高)
        base + mid,  # mmp 最大MPの変動率(中)
        base + low,  # atk 攻撃力の変動率(低)
        base + low,  # def 防御力の変動率(低)
        base + low,  # mat 魔法力の変動率(低)
        base + low,  # mdf 魔法防御の変動率(低)
        base,        # agi 敏捷性の変動率(変化なし)
        base + mid,  # luk 運の変動率(中)
        base - mid,  # exp 戦闘報酬　経験値の変動率(中)
        base - mid,  # gold 戦闘報酬　ゴールドの変動率(中)
        base - low,  # drop_denominator ドロップ率の変動率(低)
        base - mid,  # encounter_step エンカウント率の変動率(中)
      ]
    end
  end
  
  # 難易度「ノーマル」用クラス
  # カスタマイズする際には、@rate に加える修正内容を変更してください
  class Normal < Base
    def initialize
      @difficulty = :normal
      @rate = [
        base,        # mhp 最大HPの変動率(変化なし)
        base,        # mmp 最大MPの変動率(変化なし)
        base,        # atk 攻撃力の変動率(変化なし)
        base,        # def 防御力の変動率(変化なし)
        base,        # mat 魔法力の変動率(変化なし)
        base,        # mdf 魔法防御の変動率(変化なし)
        base,        # agi 敏捷性の変動率(変化なし)
        base,        # luk 運の変動率(変化なし)
        base,        # exp 戦闘報酬　経験値の変動率(変化なし)
        base,        # gold 戦闘報酬　ゴールドの変動率(変化なし)
        base,        # drop_denominator ドロップ率の変動率(変化なし)
        base,        # encounter_step エンカウント率の変動率(変化なし)
      ]
    end
  end
  
  # 難易度「イージー」用クラス
  # カスタマイズする際には、@rate に加える修正内容を変更してください
  class Easy < Base
    def initialize
      @difficulty = :easy
      @rate = [
        base - mid,  # mhp 最大HPの変動率(中)
        base - low,  # mmp 最大MPの変動率(低)
        base - low,  # atk 攻撃力の変動率(低)
        base - low,  # def 防御力の変動率(低)
        base - low,  # mat 魔法力の変動率(低)
        base - low,  # mdf 魔法防御の変動率(低)
        base,        # agi 敏捷性の変動率(変化なし)
        base - mid,  # luk 運の変動率(中)
        base + high, # exp 戦闘報酬　経験値の変動率(高)
        base + high, # gold 戦闘報酬　ゴールドの変動率(高)
        base + mid,  # drop_denominator ドロップ率の変動率(中)
        base + mid,  # encounter_step エンカウント率の変動率(中)
      ]
    end
  end
end

class Game_Enemy
  include Difficulty
  
  # 個体別のエネミー情報の格納用
  attr_accessor :unique_enemy
  
  # initialize を再定義
  alias_method :original_initialize, :initialize
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    difficulty = nil
    
    # $game_system から、難易度設定を取得し
    # 難易度インスタンスを生成
    # 難易度が未設定の場合は、難易度「ノーマル」とする
    case
      when $game_system.hard?
        difficulty = Difficulty::Hard.new
      when $game_system.normal?
        difficulty = Difficulty::Normal.new
        # difficulty = Difficulty::Hard.new
      when $game_system.easy?
        difficulty = Difficulty::Easy.new
      else
        difficulty = Difficulty::Normal.new
        # difficulty = Difficulty::Hard.new
    end
    # msgbox_p difficulty if $TEST # for test.
    
    # 難易度に応じて、オリジナルから強さの異なるユニークエネミーを複製
    # generate unique enemy by difficulty-setting.
    @unique_enemy = difficulty.generate_enemy(enemy)
    
    # 難易度に応じて、オリジナルから異なるドロップ率を設定
    # set item-drop-rate by difficulty-setting.
    drop_items = @unique_enemy.instance_variable_get(:@drop_items)
    unique_drop_items = difficulty.generate_drop_items(drop_items)
    @unique_enemy.instance_variable_set(:@drop_items, unique_drop_items)
    
    @original_name = enemy.name
    @letter = ""
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    # @hp = mhp
    # @mp = mmp
    
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
  end
  
  alias_method :original_enemy, :enemy
  # $data_enemies[@enemy_id] の代わりに、@unique_enemy を返す
  def enemy
    return @unique_enemy
  end
  
  if $rgsslab then
    # RGSS研究所さんのスクリプト(033/106)との競合に対応
    # Resolve conflict of RGSS_LAB's library.
    alias_method :rgss_labs_param_base, :param_base
    def param_base(param_id)
      difficulty = nil
    
      # $game_system から、難易度設定を取得し
      # 難易度インスタンスを生成
      # 難易度が未設定の場合は、難易度「ノーマル」とする
      case
        when $game_system.hard?
          difficulty = Difficulty::Hard.new
        when $game_system.normal?
          difficulty = Difficulty::Normal.new
          # difficulty = Difficulty::Hard.new
        when $game_system.easy?
          difficulty = Difficulty::Easy.new
        else
          difficulty = Difficulty::Normal.new
          # difficulty = Difficulty::Hard.new
      end
      (rgss_labs_param_base(param_id)*(difficulty.rate[param_id] / 100.0)).to_i
    end
  end
end

class Game_Player
  include Difficulty
  
  # make_encounter_count を再定義
  alias_method :original_make_encounter_count, :make_encounter_count
  
  # 難易度に応じて、マップ毎のエンカウント歩数を調整
  # make encounter count by difficulty-setting.
  def make_encounter_count
    difficulty = nil
    case
      when $game_system.hard?
        difficulty = Difficulty::Hard.new
      when $game_system.normal?
        difficulty = Difficulty::Normal.new
        # difficulty = Difficulty::Hard.new
      when $game_system.easy?
        difficulty = Difficulty::Easy.new
      else
        difficulty = Difficulty::Normal.new
        # difficulty = Difficulty::Hard.new
    end
    # msgbox_p(difficulty) if $TEST # for test.
    n = ($game_map.encounter_step * (difficulty.rate[11] / 100.0)).to_i
    @encounter_count = rand(n) + rand(n) + 1
  end
end

