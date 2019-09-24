require 'watir'

# here we create a class and prescribe the parameters
class Account
  attr_reader :name, :currency, :balance
  attr_accessor :nature, :transactions
  def initialize(name, currency, balance)
    @name = name
    @currency = currency
    @balance = balance
  end
end

# here we create a method that will collect data in a loop
def main
  # first, open the bank page
  b = Watir::Browser.start "https://my.fibank.bg/oauth2-server/login?client_id=E_BANK"
  b.link(id: 'demo-link').click
  sleep 2

  # create a cycle for collecting information and add it to the array
  accounts = []
  b.table(id: 'dashboardAccounts').tbody.trs.each do |tr|
    name = tr.span('bo-bind' => 'row.iban').text
    currency = tr.span('bo-bind' => 'row.ccy').text
    balance = tr.span('bo-bind' => 'row.acyAvlBal | sgCurrency').text

    accounts << Account.new(name, currency, balance)
  end

  # add data from another table
    b.table(id: 'dashboardDeposits').tbody.trs.each do |tr|
      name = tr.span('bo-bind' => 'row.iban').text
      currency = tr.span('bo-bind' => 'row.ccy').text
      balance = tr.span('bo-bind' => 'row.acyAvlBal | sgCurrency').text

      accounts << Account.new(name, currency, balance)
end
  # output of data
   puts "Accounts: #{accounts.inspect}"
end

main
