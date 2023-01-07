class SimulationController < ApplicationController
  private

  def calc_wind_damage
    if @structure == "RC造"
      d = 0.1 * 0.3
    elsif @structure == "鉄骨造"
      d = 0.2 * 0.35
    else
      d = 0.3 * 0.5
    end

    w_damage = d * @building_price
    @wind_damage = w_damage.ceil.to_s(:delimited)
  end

  # def calc_wind_damage
  #  if @structure = "RC造"
  #    m = 1
  #  elsif @structure = "鉄骨造"
  #    m = 2
  #  else
  #    m = 3
  #  end

  #  d = Date.today
  #  y = d.year.to_f - @build_year

  # 伊勢湾台風のデータ（https://www.data.jma.go.jp/stats/data/bosai/report/1959/19590926/19590926.htmlに基づき、
  # 最大瞬間風速は55.3m,最大風速は45.4m/sとする。
  # 乱流強度はIEC規格(https://www.jstage.jst.go.jp/article/jweasympo/38/0/38_229/_pdf)に基づき
  # 0.11とする。よって最大風速を記録した際の風速の標準偏差は定義より0.11 * 45.4 = 4.994とする

  #  r_c = Math::E ** (1.04 * Math.log(55.3) - 1.12 * Math.log(45.4) + 5.94 * Math.log(4.994) + 1.11 * m + 0.12 * y - 24.72)

  #  r_h = Math::E ** (4.14 * Math.log(55.3) - 2.70 * Math.log(45.4) + 5.43 * Math.log(4.994) + 0.20 * m - 0.02 * y - 24.95)

  #  r_d = Math::E ** (6.97 * Math.log(55.3) - 3.44 * Math.log(45.4) + 3.47 * Math.log(4.994) + 1.46 * m + 0.07 * y - 31.65)

  #  w_damage = (r_c * 1 + r_h * 0.5 + r_d * 0.2) * @building_price
  #  @wind_damage = w_damage.ceil.to_s(:delimited)
  # end
end
