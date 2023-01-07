class SimulationController < ApplicationController
  private

  def calc_quake_damage_RC
    shindo_rc_all = (@keisoku_shindo - @lambda_all) / @xi_all
    @d_q_all = Distribution::Normal.cdf(shindo_rc_all)
    # 全半一部損の被害率を計算

    @v1 = 10**((@keisoku_shindo - 2.68) / 1.72)
    # 司・翠川（１９９９）より地表最大速度計算
    if @hierarchy < 5
      v_severe_4 = (Math.log(@v1 - 10) - @lambda_1) / @xi_1
      @d_q_severe_4 = Distribution::Normal.cdf(v_severe_4)
      # ４階までの全壊率の計算
      v_severe_moderate_4 = (Math.log(@v1 - 10) - @lambda_a) / @xi_a
      @d_q_severe_moderate_4 = Distribution::Normal.cdf(v_severe_moderate_4)
      # ４階までの全半壊率の計算
      @d_q_moderate_4 = @d_q_severe_moderate_4 - @d_q_severe_4
      # ４階までの半壊率の計算

      @d_q_part = @d_q_all - @d_q_severe_moderate_4
      # 一部損率の計算

      quake_damage = @building_price * (0.8 * @d_q_severe_4 + 0.5 * @d_q_moderate_4 + 0.2 * @d_q_part)
      # 全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の場合は０.２とする。
      @quake_damage = quake_damage.ceil.to_s(:delimited)

    elsif (@hierarchy >= 5) && (@hierarchy < 7)
      v_severe_4 = (Math.log(@v1 - 10) - @lambda_1) / @xi_1
      @d_q_severe_4 = Distribution::Normal.cdf(v_severe_4)
      # ４階までの全壊率の計算
      v_severe_moderate_4 = (Math.log(@v1 - 10) - @lambda_a) / @xi_a
      @d_q_severe_moderate_4 = Distribution::Normal.cdf(v_severe_moderate_4)
      # ４階までの全半壊率の計算
      @d_q_moderate_4 = @d_q_severe_moderate_4 - @d_q_severe_4
      # ４階までの半壊率の計算

      v_severe_6 = (Math.log(@v1 - 10) - @lambda_2) / @xi_2
      @d_q_severe_6 = Distribution::Normal.cdf(v_severe_6)
      # ６階までの全壊率の計算
      v_severe_moderate_6 = (Math.log(@v1 - 10) - @lambda_b) / @xi_b
      @d_q_severe_moderate_6 = Distribution::Normal.cdf(v_severe_moderate_6)
      # ６階までの全半壊率の計算
      @d_q_moderate_6 = @d_q_severe_moderate_6 - @d_q_severe_6
      # ６階までの半壊率の計算

      @d_q_part =
        (@d_q_all - @d_q_severe_moderate_4) * 4 / @hierarchy +
        (@d_q_all - @d_q_severe_moderate_6) * (@hierarchy - 4) / @hierarchy
      # 一部損率の計算（建物階層で按分）

      quake_damage =
        (@building_price * (0.8 * @d_q_severe_4 + 0.5 * @d_q_moderate_4) * 4 / @hierarchy) +
        (@building_price * (0.8 * @d_q_severe_6 + 0.5 * @d_q_moderate_6) * (@hierarchy - 4) / @hierarchy) +
        @building_price * 0.2 * @d_q_part
      # 建物階層で按分。全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の被害率０.２とする。
      @quake_damage = quake_damage.ceil.to_s(:delimited)

    elsif @hierarchy >= 7
      v_severe_4 = (Math.log(@v1 - 10) - @lambda_1) / @xi_1
      @d_q_severe_4 = Distribution::Normal.cdf(v_severe_4)
      # ４階までの全壊率の計算
      v_severe_moderate_4 = (Math.log(@v1 - 10) - @lambda_a) / @xi_a
      @d_q_severe_moderate_4 = Distribution::Normal.cdf(v_severe_moderate_4)
      # ４階までの全半壊率の計算
      @d_q_moderate_4 = @d_q_severe_moderate_4 - @d_q_severe_4
      # ４階までの半壊率の計算

      v_severe_6 = (Math.log(@v1 - 10) - @lambda_2) / @xi_2
      @d_q_severe_6 = Distribution::Normal.cdf(v_severe_6)
      # ６階までの全壊率の計算
      v_severe_moderate_6 = (Math.log(@v1 - 10) - @lambda_b) / @xi_b
      @d_q_severe_moderate_6 = Distribution::Normal.cdf(v_severe_moderate_6)
      # ６階までの全半壊率の計算
      @d_q_moderate_6 = @d_q_severe_moderate_6 - @d_q_severe_6
      # ６階までの半壊率の計算

      v_severe_7 = (Math.log(@v1 - 10) - @lambda_3) / @xi_3
      @d_q_severe_7 = Distribution::Normal.cdf(v_severe_7)
      # 7階以上の全壊率の計算
      v_severe_moderate_7 = (Math.log(@v1 - 10) - @lambda_c) / @xi_c
      @d_q_severe_moderate_7 = Distribution::Normal.cdf(v_severe_moderate_7)
      # 7階以上の全半壊率の計算
      @d_q_moderate_7 = @d_q_severe_moderate_7 - @d_q_severe_7
      # 7階以上の半壊率の計算

      @d_q_part =
        (@d_q_all - @d_q_severe_moderate_4) * 4 / @hierarchy +
        (@d_q_all - @d_q_severe_moderate_6) * 2 / @hierarchy +
        (@d_q_all - @d_q_severe_moderate_7) * (@hierarchy - 6) / @hierarchy
      # 一部損率の計算（建物階層で按分）

      quake_damage = (@building_price * (0.8 * @d_q_severe_4 + 0.5 * @d_q_moderate_4) * 4 / @hierarchy) +
      (@building_price * (0.8 * @d_q_severe_6 + 0.5 * @d_q_moderate_6) * 2 / @hierarchy) +
      (@building_price * (0.8 * @d_q_severe_7 + 0.5 * @d_q_moderate_7) * (@hierarchy - 6) / @hierarchy) +
      @building_price * 0.2 * @d_q_part
      # 建物階層で按分。全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の被害率０.２とする。
      @quake_damage = quake_damage.ceil.to_s(:delimited)
    end
  end

  def calc_params_quake_model_RC
    # 一部損・全半損の累積被害率は佐伯・翠川(2001)による。
    @lambda_all = 5.472
    @xi_all = 0.584

    # 全半損被害率計算は Miyakoshi et al(1997),神奈川県地震被害想定調査報告書（2015）
    # 愛知県東海地震・東南海地震・南海地震等被害予測調査報告書(2003)に基づく.
    if @build_year < 1972
      @lambda_1 = 4.98
      @xi_1 = 0.568
      @lambda_a = 4.68
      @xi_a = 0.444
      @lambda_2 = 4.98
      @xi_2 = 0.568
      @lambda_b = 4.57
      @xi_b = 0.579
      @lambda_3 = 4.98
      @xi_3 = 0.568
      @lambda_c = 4.32
      @xi_c = 0.430
    end

    if (@build_year >= 1972) && (@build_year < 1982)
      @lambda_1 = 5.15
      @xi_1 = 0.586
      @lambda_a = 4.95
      @xi_a = 0.434
      @lambda_2 = 5.15
      @xi_2 = 0.560
      @lambda_b = 4.63
      @xi_b = 0.597
      @lambda_3 = 4.79
      @xi_3 = 0.464
      @lambda_c = 4.38
      @xi_c = 0.466
    end

    if @build_year >= 1982
      @lambda_1 = 6.07
      @xi_1 = 0.792
      @lambda_a = 5.41
      @xi_a = 0.607
      @lambda_2 = 5.67
      @xi_2 = 0.604
      @lambda_b = 5.03
      @xi_b = 0.581
      @lambda_3 = 5.20
      @xi_3 = 0.514
      @lambda_c = 4.63
      @xi_c = 0.449
    end
  end

end
