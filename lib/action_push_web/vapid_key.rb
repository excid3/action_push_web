# frozen_string_literal: true

module ActionPushWeb
  class VapidKey
    def self.from(public_key:, private_key:)
      key = new
      key.set! public_key: public_key, private_key: private_key
      key
    end

    attr_reader :curve

    def initialize(pkey = nil)
      @curve = pkey || OpenSSL::PKey::EC.generate("prime256v1")
    end

    def public_key
      Base64.urlsafe_encode64(curve.public_key.to_bn.to_s(2))
    end

    def public_key_for_push_header
      public_key.delete("=")
    end

    def private_key
      Base64.urlsafe_encode64(curve.private_key.to_s(2))
    end

    def public_key=(key)
      set! public_key: key
    end

    def private_key=(key)
      set! private_key: key
    end

    def set!(public_key: nil, private_key: nil)
      public_key = public_key.nil? ? curve.public_key : OpenSSL::PKey::EC::Point.new(group, to_big_num(public_key))
      private_key = private_key.nil? ? curve.private_key : to_big_num(private_key)

      asn1 = OpenSSL::ASN1::Sequence([
        OpenSSL::ASN1::Integer.new(1),
        # Not properly padded but OpenSSL doesn't mind
        OpenSSL::ASN1::OctetString(private_key.to_s(2)),
        OpenSSL::ASN1::ObjectId("prime256v1", 0, :EXPLICIT),
        OpenSSL::ASN1::BitString(public_key.to_octet_string(:uncompressed), 1, :EXPLICIT)
      ])

      @curve = OpenSSL::PKey::EC.new(asn1.to_der)
    end

    def group
      curve.group
    end

    def curve_name
      group.curve_name
    end

    def to_h
      { public_key: public_key, private_key: private_key }
    end
    alias to_hash to_h

    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} #{to_h.map { |k, v| ":#{k}=#{v}" }.join(' ')}>"
    end

    private

    def to_big_num(key)
      OpenSSL::BN.new(Base64.urlsafe_decode64(key), 2)
    end
  end
end
