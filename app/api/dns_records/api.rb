module DnsRecords
  class Api < Grape::API
    require_relative '../validators/ipv4_address.rb'
    include Defaults

    helpers do
      # Public: Gets a list of excluded hostnames, not present in the filter,
      # and count their occurrences.
      #
      # records - Array of records.
      # domains - Array of domains.
      #
      # Returns Hash.
      def excluded_records(records, domains)
        res = records.reject { |r| domains.include?(r[1]) }.map { |e| e[1] }
        res.group_by { |x| x }.map { |k, v| { hostname: k, matching_dns_records: v.size } }
      end

      # Public: Gets a list of IP addresses and their matching DnsRecord IDs
      # from records.
      #
      # records - Array of records.
      # domains - Array of domains.
      #
      # Returns Hash.
      def wanted_records(records, domains)
        _records = records.select { |m| domains.include?(m[1]) }
        _records = _records.each_cons(2).select { |a, b| a.last == b.last }
        _records = _records.group_by(&:last).keys.map do |v|
          { record_id: v.first, ip_address: v.last }
        end
        _records
      end
    end

    namespace :dns_records do
      desc "Gets DNS records."
      params do
        optional :include, type: String, documentation: { example: 'foo.com,bar.com' }
        optional :exclude, type: String, documentation: { example: 'baz.com' }
        requires :page, type: Integer, documentation: { example: 'page=1' }
      end

      paginate per_page: 5, max_per_page: 5

      get do
        if wanted_domains = params[:include]&.presence
          included_ips = Record.ips_for_domains(wanted_domains.split(","))
        end

        if rejected_domains = params[:exclude]&.presence
          excluded_ips = Record.ips_for_domains(rejected_domains.split(","))
        end

        if included_ips || excluded_ips
          dns_records = DnsRecord.matching_records(included_ips, excluded_ips)

          data  = {
            matches: wanted_records(dns_records, wanted_domains),
            non_matches: excluded_records(dns_records, wanted_domains)
          }

          total = data[:matches].size
        else
          results = paginate(::DnsRecord.all)
          hash    = ::DnsRecordSerializer.new(results).serializable_hash
          data    = hash[:data]
          total   = results.total_count
        end

        render total: total,
          page: params[:page],
          data: data
      end

      desc "Creates DNS records."
      params do
        requires :ip, ipv4_address: true, type: String, documentation: { example: '1.1.1.1' }
        requires :hostnames, type: Array, documentation: { example: ["example1.com", "example2.com"] }
      end

      post do
        record = Record.where(
          record_type: Record.record_types[:a],
          value: permitted_params[:ip]
        ).first_or_create

        permitted_params[:hostnames].each do |hostname|
          domain = Domain.where(name: hostname).first_or_create
          DnsRecord.where(record: record, domain: domain).first_or_create
        end

        record
      end
    end
  end
end
