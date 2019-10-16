require 'nokogiri'
require 'rspec'

require_relative './Fibank'
require_relative './account'
require_relative './transaction'

describe Fibank do
    it 'returns two items' do
      html = Nokogiri::HTML(File.open("accounts.html"))
      accounts = Fibank.new.parse_accounts(html)
      expect(accounts.count).to eq(2)
    end
  end
