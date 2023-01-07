class SimulationController < ApplicationController
  private

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
end
