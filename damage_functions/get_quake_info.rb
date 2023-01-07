class SimulationController < ApplicationController
  private

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
end
