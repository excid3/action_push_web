# frozen_string_literal: true

module ActionPushWeb
  class Request
    DEFAULT_EXPIRATION = 12.hours.to_i
    DEFAULTS = {
      ttl: 4.weeks.to_i,
      urgency: "normal"
    }

    attr_reader :options, :payload, :uri, :vapid_options

    def initialize(**options)
      @uri ||= URI.parse(options.delete(:endpoint))
      @options = options.with_defaults(DEFAULTS)
      @vapid_options = @options.delete(:vapid)
      @payload = encrypt(@options.delete(:message))
    end

    def perform
      if options[:connection]
        http = options[:connection]
      else
        http = Net::HTTP.new(uri.host, uri.port, *proxy_options)
        http.use_ssl = true
        http.ssl_timeout = options[:ssl_timeout] unless options[:ssl_timeout].nil?
        http.open_timeout = options[:open_timeout] unless options[:open_timeout].nil?
        http.read_timeout = options[:read_timeout] unless options[:read_timeout].nil?
      end

      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = payload

      if http.is_a?(Net::HTTP::Persistent)
        response = http.request(uri, request)
      else
        response = http.request(request)
        verify_response(response)
      end

      response
    end

    def proxy_options
      return [] unless @options[:proxy]
      proxy_uri = URI.parse(@options[:proxy])
      [ proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password ]
    end

    def headers
      {
        "Content-Type" => "application/octet-stream",
        "Ttl" => options.fetch(:ttl).to_s,
        "Urgency" => options.fetch(:urgency).to_s,
        "Content-Encoding" => "aes128gcm",
        "Content-Length" => payload.length.to_s,
        "Authorization" => vapid_header
      }
    end

    def vapid_header
      vapid_key = VapidKey.from(**vapid_options.slice(:public_key, :private_key))
      jwt_payload = {
        aud: "#{uri.scheme}://#{uri.host}",
        exp: Time.now.to_i + vapid_options.fetch(:expiration) { DEFAULT_EXPIRATION },
        sub: vapid_options.fetch(:subject)
      }
      jwt = JWT.encode(jwt_payload, vapid_key.curve, "ES256", { typ: "JWT", alg: "ES256" })
      p245ecdsa = vapid_key.public_key_for_push_header
      "vapid t=#{jwt},k=#{p245ecdsa}"
    end

    def verify_response(response)
      if response.is_a?(Net::HTTPGone) # 410
        raise ExpiredSubscription.new(response, uri.host)
      elsif response.is_a?(Net::HTTPNotFound) # 404
        raise InvalidSubscription.new(response, uri.host)
      elsif response.is_a?(Net::HTTPUnauthorized) || response.is_a?(Net::HTTPForbidden) || # 401, 403
            response.is_a?(Net::HTTPBadRequest) && response.message == "UnauthorizedRegistration" # 400, Google FCM
        raise Unauthorized.new(response, uri.host)
      elsif response.is_a?(Net::HTTPRequestEntityTooLarge) # 413
        raise PayloadTooLarge.new(response, uri.host)
      elsif response.is_a?(Net::HTTPTooManyRequests) # 429, try again later!
        raise TooManyRequests.new(response, uri.host)
      elsif response.is_a?(Net::HTTPServerError) # 5xx
        raise PushServiceError.new(response, uri.host)
      elsif !response.is_a?(Net::HTTPSuccess) # unknown/unhandled response error
        raise response.new(response, uri.host)
      end
    end

    def encrypt(message, group_name: "prime256v1", hash: "SHA256", salt: Random.new.bytes(16))
      p256dh, auth = options.fetch(:p256dh), options.fetch(:auth)

      server = OpenSSL::PKey::EC.generate(group_name)
      server_public_key_bn = server.public_key.to_bn

      group = OpenSSL::PKey::EC::Group.new(group_name)
      client_public_key_bn = OpenSSL::BN.new(Base64.urlsafe_decode64(p256dh), 2)
      client_public_key = OpenSSL::PKey::EC::Point.new(group, client_public_key_bn)

      prk = OpenSSL::KDF.hkdf(
        server.dh_compute_key(client_public_key),
        salt: Base64.urlsafe_decode64(auth),
        info: "WebPush: info\0" + client_public_key_bn.to_s(2) + server_public_key_bn.to_s(2),
        hash: hash,
        length: 32
      )

      content_encryption_key = OpenSSL::KDF.hkdf(
        prk,
        salt: salt,
        info: "Content-Encoding: aes128gcm\0",
        hash: hash,
        length: 16
      )

      nonce = OpenSSL::KDF.hkdf(
        prk,
        salt: salt,
        info: "Content-Encoding: nonce\0",
        hash: hash,
        length: 12
      )

      ciphertext = encrypt_text(message, key: content_encryption_key, nonce: nonce)

      serverkey16bn = convert16bit(server_public_key_bn)
      rs = ciphertext.bytesize
      raise ArgumentError, "encrypted payload is too big" if rs > 4096

      aes128gcmheader = "#{salt}" + [ rs ].pack("N*") + [ serverkey16bn.bytesize ].pack("C*") + serverkey16bn
      aes128gcmheader + ciphertext
    end

    def encrypt_text(text, key:, nonce:, cipher_name: "aes-128-gcm")
      cipher = OpenSSL::Cipher.new(cipher_name)
      cipher.encrypt
      cipher.key = key
      cipher.iv = nonce
      cipher_text = cipher.update(text)
      padding = cipher.update("\2\0")
      cipher_text + padding + cipher.final + cipher.auth_tag
    end

    def convert16bit(key)
      [ key.to_s(16) ].pack("H*")
    end
  end
end
