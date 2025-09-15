module ActionPushWeb::PersistentRequest
  def perform
    if @options[:connection]
      http = @options[:connection]
    else
      http = Net::HTTP.new(uri.host, uri.port, *proxy_options)
      http.use_ssl = true
      http.ssl_timeout = @options[:ssl_timeout] unless @options[:ssl_timeout].nil?
      http.open_timeout = @options[:open_timeout] unless @options[:open_timeout].nil?
      http.read_timeout = @options[:read_timeout] unless @options[:read_timeout].nil?
    end

    req = Net::HTTP::Post.new(uri.request_uri, headers)
    req.body = body

    if http.is_a?(Net::HTTP::Persistent)
      response = http.request uri, req
    else
      resp = http.request(req)
      verify_response(resp)
    end

    resp
  end
end
