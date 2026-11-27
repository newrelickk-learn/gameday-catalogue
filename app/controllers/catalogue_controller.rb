class CatalogueController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @tags = (params[:tags] || "").split(",")
    @order = params[:order]
    @pageNum = (params[:page] || 1).to_i
    @pageSize = (params[:size] || 100).to_i

    @socks = SocksSelector.call(@tags, @pageNum, @pageSize, @order)
    render json: @socks
  end

  def size
    @tags = (params[:tags] || "").split(",")
    @socks = SocksCounter.call(@tags)
    render json: { "size": @socks[:size] }
  end

  # 詳細画面が開かない問題対応中
  def item
    @sock_id = params[:sock_id]
    @sock = SockGetter.call(@sock_id)
    if @sock[:error]
      render json: @sock, status: :internal_server_error
    else
      render json: @sock
    end
  end

  class << self
    include ::NewRelic::Agent::MethodTracer
    add_method_tracer :index, 'Custom/catalogue#index'
    add_method_tracer :size, 'Custom/catalogue#size'
    add_method_tracer :item, 'Custom/catalogue#item'
  end

end
