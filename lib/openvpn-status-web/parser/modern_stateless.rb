module OpenVPNStatusWeb
  module Parser
    class ModernStateless
      CLIENT_LIST_HEADERS = %i(
        name real_address virtual_address received_bytes sent_bytes
        connected_at connected_at_to_i user
      )
      ROUTING_TABLE_HEADERS = %i(
        virtual_address name real_address last_ref_at last_ref_at_to_i
      )

      DEFAULT_DATETIME_FORMAT = '%a %b %d %k:%M:%S %Y'

      def self.parse_status_log(text, sep)
        status = Status.new
        status.client_list = []
        status.routing_table = {}
        status.global_stats = []


        text.lines.each do |line|
          parts = line.strip.split(sep)
          type = parts.shift

          case type
            when 'CLIENT_LIST'
              status.client_list << parse_client(parts)
            when 'ROUTING_TABLE'
              route = parse_route(parts)
              status.routing_table[route.name] = route
            when 'GLOBAL_STATS'
              status.global_stats << parse_global(parts)
          end
        end

        status
      end

      private

      def self.parse_client(parts)
        client = CLIENT_LIST_HEADERS.each_with_index.inject({}) do |line, (item, i)|
          line[item] = parts[i]
          line
        end
        self.parse_connected_at client, :connected_at
        self.remove_port_from_addresses client

        OpenStruct.new(client)
      rescue => e
        byebug
      end

      def self.parse_route(parts)
        route = ROUTING_TABLE_HEADERS.each_with_index.inject({}) do |line, (item, i)|
          line[item] = parts[i]
          line
        end

        self.parse_connected_at route, :last_ref_at

        OpenStruct.new route
      rescue => e
        byebug
      end

      def self.parse_global(global)
        global
      rescue => e
        byebug
      end

      def self.parse_connected_at(data, attr)
        data[attr] = DateTime.strptime(data[attr], DEFAULT_DATETIME_FORMAT)
      end

      def self.remove_port_from_addresses(data)
        data[:real_address].gsub!(/(:\d+)$/, '')
        data[:virtual_address].gsub!(/(:\d+)$/, '')
      end
    end
  end
end
