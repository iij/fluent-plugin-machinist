#
# Copyright 2019- Naoya Kaneko
#

require "fluent/plugin/output"

module Fluent
  module Plugin
    class MachinistOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("machinist", self)

      def initialize
        super
        require "net/http"
        require "uri"
      end

      # authentication and access requirements
      config_param :endpoint_url, :string
      config_param :agent_id, :string
      config_param :api_key, :string
      config_param :use_ssl, :bool, :default => true
      config_param :verify_ssl, :bool, :default => true

      # name & value selection
      config_param :value_key, :string, :default => nil
      config_param :value_keys, :array, value_type: :string, :default => nil

      # specifying statistically
      ## namespace
      config_param :namespace, :string, :default => nil # namespace string (static)
      config_param :namespace_key, :string, :default => nil #TBD: use value for specified hash entry for namespace
      config_param :tags, :hash, :default => nil # specify tags hash (static)
      config_param :tag_keys, :array, value_type: :string, :default => nil # 

      def start
        super
      end

      def shutdown
        super
      end

      def process(tag, es)
        es.each do |time, record|
          handle_record(tag, time, record)
        end
      end

      def handle_record(tag, time, record)
        data = create_payload(tag, time, record)

        send_request(data)
      end

      def create_payload(tag, time, record)
        metrics = []
        @value_keys = [@value_key] if @value_key
        ns = if @namespace
               @namespace
             elsif @namespace_key
               record[@namespace_key]
             else
               nil
             end
        tags = if @tags
                 @tags
               elsif @tag_keys
                 @tag_keys.map{|key|
                   [key, record[key].to_s]
                 }.to_h
               else
                 nil
               end

        metrics += @value_keys.map{|key|
          metric = {
            :name => key,
            :value => record[key].to_f
          }
          metric[:namespace] = ns if ns
          metric[:tags] = tags if tags
          metric
        }

        json = {
          :agent_id => @agent_id,
          :api_key => @api_key,
          :metrics => metrics
        }

        return JSON.dump(json)
      end

      def send_request(data)
        url = URI(@endpoint_url)
        http = Net::HTTP.new(url.host, url.port)
        if @use_ssl
          http.use_ssl = true
          http.ca_file = OpenSSL::X509::DEFAULT_CERT_FILE
          unless @verify_ssl
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end

        req = Net::HTTP::Post.new(url)
        req["content-type"] = 'application/json'

        req.body = data
        res = http.request(req)

        unless res and res.is_a?(Net::HTTPSuccess)
          summary = if res
                      "#{res.code} #{res.message} #{res.body}"
                    else
                      "res=nil"
                    end
          $log.warn "failed to #{req.method} #{url} #{summary}"
        end
      rescue => e
        $log.warn "Net::HTTP.#{req.method.capitalize} raises exception : #{e.class}, '#{e.message}'"
        raise e
      end

    end
  end
end
