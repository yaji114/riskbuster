class SimulationController < ApplicationController
  private

  def calc_params_quake_model_S
    # 一部損・全半損の累積被害率は佐伯・翠川(2001)による。
    @lambda_all = 5.472
    @xi_all = 0.584

    # 被害率計算は Miyakoshi et al(1997),神奈川県地震被害想定調査報告書（2015）
    # 愛知県東海地震・東南海地震・南海地震等被害予測調査報告書(2003)に基づく.
    if @build_year < 1982
      @lambda_1 = 4.73
      @xi_1 = 0.615
      @lambda_a = 4.49
      @xi_a = 0.620
      @lambda_2 = 4.70
      @xi_2 = 0.712
      @lambda_b = 4.05
      @xi_b = 0.688
      @lambda_3 = 4.28
      @xi_3 = 0.561
      @lambda_c = 3.94
      @xi_c = 0.597
    end

    if @build_year >= 1982
      @lambda_1 = 5.29
      @xi_1 = 0.417
      @lambda_a = 5.21
      @xi_a = 0.671
      @lambda_2 = 5.35
      @xi_2 = 0.610
      @lambda_b = 4.86
      @xi_b = 0.795
      @lambda_3 = 4.98
      @xi_3 = 0.525
      @lambda_c = 4.30
      @xi_c = 0.590
    end
  end

  def calc_quake_damage_S
    shindo_s_all = (@keisoku_shindo - @lambda_all) / @xi_all
    @d_q_all = Distribution::Normal.cdf(shindo_s_all)
    # 全半一部損の被害率を計算

    @v1 = 10**((@keisoku_shindo - 2.68) / 1.72)
    # 司・翠川（１９９９）より地震最大速度計算
    if @hierarchy < 3
      v_severe_2 = (Math.log(@v1 - 10) - @lambda_1) / @xi_1
      @d_q_severe_2 = Distribution::Normal.cdf(v_severe_2)
      # 2階までの全壊率の計算
      v_severe_moderate_2 = (Math.log(@v1 - 10) - @lambda_a) / @xi_a
      @d_q_severe_moderate_2 = Distribution::Normal.cdf(v_severe_moderate_2)
      # 2階までの全半壊率の計算
      @d_q_moderate_2 = @d_q_severe_moderate_2 - @d_q_severe_2
      # 2階までの半壊率の計算

      @d_q_part = @d_q_all - @d_q_severe_moderate_2

      quake_damage = @building_price * (0.8 * @d_q_severe_2 + 0.5 * @d_q_moderate_2 + 0.2 * @d_q_part)
      # 全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の場合は０.２とする。
      @quake_damage = quake_damage.ceil.to_s(:delimited)

    elsif (@hierarchy >= 3) && (@hierarchy < 5)
      v_severe_2 = (Math.log(@v1 - 10) - @lambda_1) / @xi_1
      @d_q_severe_2 = Distribution::Normal.cdf(v_severe_2)
      # 2階までの全壊率の計算
      v_severe_moderate_2 = (Math.log(@v1 - 10) - @lambda_a) / @xi_a
      @d_q_severe_moderate_2 = Distribution::Normal.cdf(v_severe_moderate_2)
      # 2階までの全半壊率の計算
      @d_q_moderate_2 = @d_q_severe_moderate_2 - @d_q_severe_2
      # 2階までの半壊率の計算

      v_severe_4 = (Math.log(@v1 - 10) - @lambda_2) / @xi_2
      @d_q_severe_4 = Distribution::Normal.cdf(v_severe_4)
      # 4階までの全壊率の計算
      v_severe_moderate_4 = (Math.log(@v1 - 10) - @lambda_b) / @xi_b
      @d_q_severe_moderate_4 = Distribution::Normal.cdf(v_severe_moderate_4)
      # 4階までの全半壊率の計算
      @d_q_moderate_4 = @d_q_severe_moderate_4 - @d_q_severe_4
      # 4階までの半壊率の計算

      @d_q_part =
        (@d_q_all - @d_q_severe_moderate_2) * 2 / @hierarchy +
        (@d_q_all - @d_q_severe_moderate_4) * (@hierarchy - 2) / @hierarchy
      # 一部損率の計算（建物階層で按分）

      quake_damage =
        (@building_price * (0.8 * @d_q_severe_2 + 0.5 * @d_q_moderate_2) * 2 / @hierarchy) +
        (@building_price * (0.8 * @d_q_severe_4 + 0.5 * @d_q_moderate_4) * (@hierarchy - 2) / @hierarchy) +
        @building_price * 0.2 * @d_q_part
      # 建物階層で按分。全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の被害率０.２とする。
      @quake_damage = quake_damage.ceil.to_s(:delimited)

    elsif @hierarchy >= 5
      v_severe_2 = (Math.log(@v1 - 10) - @lambda_1) / @xi_1
      @d_q_severe_2 = Distribution::Normal.cdf(v_severe_2)
      # 2階までの全壊率の計算
      v_severe_moderate_2 = (Math.log(@v1 - 10) - @lambda_a) / @xi_a
      @d_q_severe_moderate_2 = Distribution::Normal.cdf(v_severe_moderate_2)
      # 2階までの全半壊率の計算
      @d_q_moderate_2 = @d_q_severe_moderate_2 - @d_q_severe_2
      # 2階までの半壊率の計算

      v_severe_4 = (Math.log(@v1 - 10) - @lambda_2) / @xi_2
      @d_q_severe_4 = Distribution::Normal.cdf(v_severe_4)
      # 4階までの全壊率の計算
      v_severe_moderate_4 = (Math.log(@v1 - 10) - @lambda_b) / @xi_b
      @d_q_severe_moderate_4 = Distribution::Normal.cdf(v_severe_moderate_4)
      # 4階までの全半壊率の計算
      @d_q_moderate_4 = @d_q_severe_moderate_4 - @d_q_severe_4
      # 4階までの半壊率の計算

      v_severe_5 = (Math.log(@v1 - 10) - @lambda_3) / @xi_3
      @d_q_severe_5 = Distribution::Normal.cdf(v_severe_5)
      # ５階以上の全壊率の計算
      v_severe_moderate_5 = (Math.log(@v1 - 10) - @lambda_c) / @xi_c
      @d_q_severe_moderate_5 = Distribution::Normal.cdf(v_severe_moderate_5)
      # ５階以上の全半壊率の計算
      @d_q_moderate_5 = @d_q_severe_moderate_5 - @d_q_severe_5
      # ５階以上の半壊率の計算

      @d_q_part =
        (@d_q_all - @d_q_severe_moderate_2) * 2 / @hierarchy +
        (@d_q_all - @d_q_severe_moderate_4) * 2 / @hierarchy +
        (@d_q_all - @d_q_severe_moderate_5) * (@hierarchy - 4) / @hierarchy
      # 一部損率の計算（建物階層で按分）

      quake_damage = (@building_price * (0.8 * @d_q_severe_2 + 0.5 * @d_q_moderate_2) * 2 / @hierarchy) +
      (@building_price * (0.8 * @d_q_severe_4 + 0.5 * @d_q_moderate_4) * 2 / @hierarchy) +
      (@building_price * (0.8 * @d_q_severe_5 + 0.5 * @d_q_moderate_5) * (@hierarchy - 4) / @hierarchy) +
      @building_price * 0.2 * @d_q_part
      # 建物階層で按分。全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の被害率０.２とする。
      @quake_damage = quake_damage.ceil.to_s(:delimited)
    end
  end

end
