class SimulationController < ApplicationController
  private

  def calc_params_quake_model_H
    # 全損半損一部損被害率を佐伯・翠川(2001)による。
    @lambda_all = 5.263
    @xi_all = 0.415

    # 木造（非耐火構造）の全半損被害率はMiyakoshi et al(1997)による。
    # ただし階層による区分は行わない。
    if @build_year < 1951
      @lambda_severe = 4.22
      @xi_severe = 0.558
      @lambda_severe_moderate = 3.26
      @xi_severe_moderate = 0.945

    elsif (@build_year >= 1951) && (@build_year < 1961)
      @lambda_severe = 4.38
      @xi_severe = 0.445
      @lambda_severe_moderate = 3.77
      @xi_severe_moderate = 0.674

    elsif (@build_year >= 1961) && (@build_year < 1971)
      @lambda_severe = 4.32
      @xi_severe = 0.467
      @lambda_severe_moderate = 3.72
      @xi_severe_moderate = 0.614

    elsif (@build_year >= 1971) && (@build_year < 1981)
      @lambda_severe = 4.67
      @xi_severe = 0.462
      @lambda_severe_moderate = 4.08
      @xi_severe_moderate = 0.551

    elsif @build_year >= 1981
      @lambda_severe = 5.12
      @xi_severe = 0.552
      @lambda_severe_moderate = 4.56
      @xi_severe_moderate = 0.624
    end
  end

  def calc_quake_damage_H
    shindo_h_all = (@keisoku_shindo - @lambda_all) / @xi_all
    @d_q_all = Distribution::Normal.cdf(shindo_h_all)
    # 全半一部損の被害率を計算

    shindo_h_severe = (@keisoku_shindo - @lambda_severe) / @xi_severe
    @d_q_severe = Distribution::Normal.cdf(shindo_h_severe)
    # 全損の被害率を計算

    shindo_h_severe_moderate = (@keisoku_shindo - @lambda_severe_moderate) / @xi_severe_moderate
    @d_q_severe_moderate = Distribution::Normal.cdf(shindo_h_severe_moderate)
    # 全半損の被害率を計算

    @d_q_moderate = @d_q_severe_moderate - @d_q_severe
    # 半損の被害率を計算

    @d_q_part = @d_q_all - @d_q_severe_moderate
    # 一部損被害率を計算

    quake_damage = @building_price * (0.8 * @d_q_severe + 0.5 * @d_q_moderate + 0.2 * @d_q_part)
    # 全壊の場合の被害率は0.8、半壊の場合は０.５、一部損の場合は０.２とする。
    @quake_damage = quake_damage.ceil.to_s(:delimited)
  end

end
