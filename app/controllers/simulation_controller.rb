class SimulationController < ApplicationController
  def simulation
    @structure = params[:structure]
    @build_year = params[:build_year].to_f
    @hierarchy = params[:hierarchy].to_f
    @address = params[:address]
    get_geo_response
    if @result_geo[0]
      @lat = @result_geo[0]["geometry"]["coordinates"][1]
      @lon = @result_geo[0]["geometry"]["coordinates"][0]
      get_flood_response
      @depth = @result_flood["Depth"]
      @building_price = params[:building_price].to_f
      @building_price_disp = @building_price.ceil.to_s(:delimited)
      calc_flood_damage
      get_quake_response
      @t50_p10_si = @result_quake["features"][0]["properties"]["T50_P10_SI"]
      @keisoku_shindo = @t50_p10_si.to_f
      calc_shindo
      if @structure == "RC造"
        calc_params_quake_model_RC
        calc_quake_damage_RC
      elsif @structure == "鉄骨造"
        calc_params_quake_model_S
        calc_quake_damage_S
      else
        calc_params_quake_model_H
        calc_quake_damage_H
      end
    end
  end

  private

  def get_geo_response
    params = URI.encode_www_form({ q: "#{@address}" })
    uri_geo = URI.parse(
      "https://msearch.gsi.go.jp/address-search/AddressSearch?#{params}"
    )
    response_geo = Net::HTTP.get_response(uri_geo)
    @result_geo = JSON.parse(response_geo.body)
  end

  def get_flood_response
    uri_flood = URI.parse(
      "https://suiboumap.gsi.go.jp/shinsuimap/Api/Public/GetMaxDepth?lon=#{@lon}&lat=#{@lat}&CSVScale=0"
    )
    response_flood = Net::HTTP.get_response(uri_flood)
    @result_flood = JSON.parse(response_flood.body)
  end

  def calc_flood_damage
    if (@depth > 0) && (@depth < 0.5)
      d_f = 0.189
    elsif (@depth >= 0.5) && (@depth < 1)
      d_f = 0.253
    elsif (@depth >= 1) && (@depth < 2)
      d_f = 0.406
    elsif (@depth >= 2) && (@depth < 3)
      d_f = 0.592
    elsif @depth >= 3
      d_f = 0.8
    else
      d_f = 0
    end
    flood_damage = d_f * @building_price * @depth / 3 / @hierarchy
    # 1階層あたりの高さは3mと仮定して、階数で按分する。
    @flood_damage = flood_damage.ceil.to_s(:delimited)
  end

  def get_quake_response
    uri_quake = URI.parse(
      "https://www.j-shis.bosai.go.jp/map/api/pshm/Y2020/AVR/TTL_MTTL/meshinfo.geojson?position=#{@lon},#{@lat}&epsg=4612&attr=T50_P10_SI"# rubocop:disable all
    )
    response_quake = Net::HTTP.get_response(uri_quake)
    @result_quake = JSON.parse(response_quake.body)
  end

  def calc_shindo
    if (@keisoku_shindo >= 0.5) && (@keisoku_shindo < 1.5)
      @shindo = "1"
    elsif (@keisoku_shindo >= 1.5) && (@keisoku_shindo < 2.5)
      @shindo = "2"
    elsif (@keisoku_shindo >= 2.5) && (@keisoku_shindo < 3.5)
      @shindo = "3"
    elsif (@keisoku_shindo >= 3.5) && (@keisoku_shindo < 4.5)
      @shindo = "4"
    elsif (@keisoku_shindo >= 4.5) && (@keisoku_shindo < 5.0)
      @shindo = "5弱"
    elsif (@keisoku_shindo >= 5.0) && (@keisoku_shindo < 5.5)
      @shindo = "5強"
    elsif (@keisoku_shindo >= 5.5) && (@keisoku_shindo < 6.0)
      @shindo = "6弱"
    elsif (@keisoku_shindo >= 6.0) && (@keisoku_shindo < 6.5)
      @shindo = "6強"
    elsif @T50_P10_SI >= 6.5
      @shindo = "7"
    else
      @shindo = "0"
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
