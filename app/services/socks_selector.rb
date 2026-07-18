require 'new_relic/agent/method_tracer'
require 'net/http'

class SocksSelector
  include Service

  def initialize(tags, pageNum, pageSize, order)
    @tags = tags
    @pageNum = pageNum
    @pageSize = pageSize
    @order = order
  end

  def call
    @socks = [];
    if @tags.length > 0
      @socks = Sock.joins(sock_tags: :tag).where(tag: { name: @tags.map { |tag| tag.strip! ? tag.strip! : tag }}).distinct
    else
      @socks = Sock.all
    end
    if !@pageSize.nil?
      @socks = @socks.slice((@pageNum - 1) * @pageSize.to_i, @pageSize) || []
    end
    uri = URI.parse('https://link.nrug.nrkk.technology')
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      get_request = Net::HTTP::Get.new("/files/contents.json", 'Content-Type' => 'application/json')
      http.request(get_request)
    end
    return @socks.map { |sock| {
      "id": sock.sock_id,
      "name": sock.name,
      "description": sock.description,
      "price": sock.price,
      "count": sock.count,
      "imageUrl": [sock.image_url_1, sock.image_url_2]
    } }
  end

  class << self
    include ::NewRelic::Agent::MethodTracer
    add_method_tracer :call, 'SocksSelector/call'
  end
end