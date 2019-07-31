def assign_ip_to_domains_list(ip = '', domains = [])
  if ip.presence && domains.presence
    record = Record.where(value: ip, record_type: Record.record_types[:a])
      .first_or_create

    domains.each do |hostname|
      domain = Domain.where(name: hostname).first_or_create
      DnsRecord.where(domain: domain, record: record).first_or_create
    end
    puts " --> Assigned #{ip} to #{domains.join(", ")}."
  end
end

assign_ip_to_domains_list('1.1.1.1', %w(lorem.com ipsum.com dolor.com amet.com))
assign_ip_to_domains_list('2.2.2.2', %w(ipsum.com))
assign_ip_to_domains_list('3.3.3.3', %w(ipsum.com dolor.com amet.com))
assign_ip_to_domains_list('4.4.4.4', %w(ipsum.com dolor.com sit.com amet.com))
assign_ip_to_domains_list('5.5.5.5', %w(dolor.com sit.com))
