class SimulationController < ApplicationController
  require './damage_functions/calc_flood_damage'
  require './damage_functions/calc_quake_damage_rc'
  require './damage_functions/calc_quake_damage_s'
  require './damage_functions/calc_quake_damage_h'
  require './damage_functions/get_quake_info'
  require './damage_functions/calc_wind_damage'

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
      if @result_flood.blank?
        @depth = 0
      else
        @depth = @result_flood["Depth"]
      end
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

      calc_wind_damage

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
end
