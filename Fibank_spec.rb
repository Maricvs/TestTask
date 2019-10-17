require 'nokogiri'
require 'rspec'

require_relative './Fibank'

describe Fibank do
  describe '#parse_accounts' do
    let(:account) { Fibank.new.parse_accounts(html) }
    let(:html) { Nokogiri::HTML(File.open("accounts.html")) }

    it 'returns Accounts count' do
      expect(account.count).to eq(2)
    end

    it 'parse Accounts data example' do
      expect(account[0].to_hash).to eq({
        :name =>      "fibank EUR",
        :currency =>  "EUR",
        :balance =>   0.0
      })
    end
  end

  describe '#parse_transactions' do
    let(:account) { Account.new("example", "CUR", 0.0) }
    let(:html) { Nokogiri::HTML(File.open("transactions.html")) }

    it 'returns Transactions count' do
      Fibank.new.parse_transactions(account, html)
      expect(account.transactions.count).to eq(4)
    end

    it 'parse Transactions dara example' do
      Fibank.new.parse_transactions(account, html)
      expect(account.transactions[0].to_hash).to eq({
        :amount =>      1000.0,
        :date =>        "23/08/2019",
        :description => "Received transfer in BGN"
      })
    end
  end
end
