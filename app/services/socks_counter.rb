class SocksCounter
  include Service
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def initialize(tags)
    @tags = tags
  end

  def call
    
    ::NewRelic::Agent.add_custom_attributes({
      'socks_counter.tags_count' => @tags.length,
      'socks_counter.has_tags' => @tags.length > 0
    })

    @socks = [];
    if @tags.length > 0
      @socks = Sock.all.filter {
        |sock| @tags.find { |tag| tag == Tag.find(SockTag.find_by(sock_id: sock.sock_id).tag_id).name }
      }
    else
      @socks = Sock.all
    end
    
    result_size = @socks.size
    
    ::NewRelic::Agent.add_custom_attributes({
      'socks_counter.result_size' => result_size
    })

    return { size: result_size }
  end
  
  # メソッドをトレース対象として追加
  add_transaction_tracer :call, category: :task, name: 'SocksCounter#call'

end