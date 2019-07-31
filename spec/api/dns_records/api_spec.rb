require 'rails_helper'

describe DnsRecords::Api do
  context 'GET /api/v1/dns_records' do
    let!(:record)  { create :record }
    let!(:domains) { create_list :domain, 10 }

    before do
      domains.each do |domain|
        create :dns_record, domain: domain, record: record
      end
    end

    context 'failure' do
      before { get '/api/v1/dns_records' }

      it 'shows errors' do
        expect(response.status).to eq(400)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq "page is missing"
      end
    end

    context 'no filter' do
      before  { get '/api/v1/dns_records?page=1' }
      subject { response }

      it { is_expected.to have_http_status(:success) }

      let(:body) { JSON.parse(subject.body) }

      it "includes the total number of records" do
        expect(body).to have_key("total")
        expect(body["total"]).to be_an(Integer)
        expect(body["total"]).to eq DnsRecord.count
      end

      it "includes the page number" do
        expect(body).to have_key("page")
        expect(body["page"]).to be_an(Integer)
        expect(body["page"]).to eq 1
      end

      it "includes the DNS records, domain and IP addresses" do
        expect(body).to have_key("data")
        expect(body["data"]).not_to be_empty
      end
    end

    context 'filtering' do
      let(:ip1) { create(:record, value: '1.1.1.1') }
      let(:ip2) { create(:record, value: '2.2.2.2') }
      let(:ip3) { create(:record, value: '3.3.3.3') }
      let(:ip4) { create(:record, value: '4.4.4.4') }
      let(:ip5) { create(:record, value: '5.5.5.5') }

      let(:domain1) { create(:domain, name: 'lorem.com') }
      let(:domain2) { create(:domain, name: 'ipsum.com') }
      let(:domain3) { create(:domain, name: 'dolor.com') }
      let(:domain4) { create(:domain, name: 'amet.com') }
      let(:domain5) { create(:domain, name: 'sit.com') }

      before do
        create(:dns_record, domain: domain1, record: ip1)
        create(:dns_record, domain: domain2, record: ip1)
        create(:dns_record, domain: domain3, record: ip1)
        create(:dns_record, domain: domain4, record: ip1)
        create(:dns_record, domain: domain2, record: ip2)
        create(:dns_record, record: ip3, domain: domain2)
        create(:dns_record, record: ip3, domain: domain3)
        create(:dns_record, record: ip3, domain: domain4)
        create(:dns_record, record: ip4, domain: domain2)
        create(:dns_record, record: ip4, domain: domain3)
        create(:dns_record, record: ip4, domain: domain5)
        create(:dns_record, record: ip4, domain: domain4)

        get '/api/v1/dns_records?page=1&include=ipsum.com,dolor.com&exclude=sit.com'
      end

      subject { response }

      it { is_expected.to have_http_status(:success) }

      let(:body) { JSON.parse(subject.body) }

      it "includes the total number of records" do
        expect(body).to have_key("total")
        expect(body["total"]).to be_an(Integer)
        expect(body["total"]).to eq 2
      end

      let(:data) { body["data"] }

      it "includes an array with matching records" do
        expect(data).to have_key("matches")
        expect(data["matches"]).to be_an(Array)
        _ip1 = data["matches"].detect { |d| d["ip_address"] == "1.1.1.1" }
        _ip2 = data["matches"].detect { |d| d["ip_address"] == "3.3.3.3" }
        expect(_ip1).not_to be_nil
        expect(_ip1).to have_key("record_id")
        expect(_ip2).not_to be_nil
        expect(_ip2).to have_key("record_id")
      end

      it "includes non-matching records" do
        expect(data).to have_key("non_matches")
        amet  = data["non_matches"].detect { |d| d["hostname"] == "amet.com" }
        lorem = data["non_matches"].detect { |d| d["hostname"] == "lorem.com" }
        expect(amet).not_to be_nil
        expect(amet["matching_dns_records"]).to eq 2
        expect(lorem).not_to be_nil
        expect(lorem["matching_dns_records"]).to eq 1
      end
    end
  end
end
