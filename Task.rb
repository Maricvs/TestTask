require 'watir'
require 'date'
require 'nokogiri'

# Task 3
class Account
  attr_reader :transactions, :name

  def initialize(name, currency, balance)
    @name = name
    @currency = currency
    @balance = balance
    @transactions = []
  end
end

# Task 5
class Transaction
  def initialize(date, description, amount, currency, account_name)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end
end

def main
  # Task 1
  b = Watir::Browser.start "https://my.fibank.bg/oauth2-server/login?client_id=E_BANK"
  b.link(id: 'demo-link').click
  sleep 3

  # Task 2
  accounts = []
  b.table(id: 'dashboardAccounts').tbody.trs.each do |tr|
    name = tr.p('bo-bind' => 'row.acDesc').text
    currency = tr.span('bo-bind' => 'row.ccy').text
    balance = tr.span('bo-bind' => 'row.acyAvlBal | sgCurrency').text.gsub(' ', '').to_f

    accounts << Account.new(name, currency, balance)
  end

  puts "Task 2-3. Accounts: #{accounts.inspect}"

  # Task 4
  transactions = []
  # To stop while loop
  trs_index = 0
  trs_count = b.table(id: 'dashboardAccounts').tbody.trs.count
  while trs_index < trs_count
    tr = b.table(id: 'dashboardAccounts').tbody.trs[trs_index]
    # To remember which account the transaction relates to
    account_name = tr.p('bo-bind' => 'row.acDesc').text
    account_currency = tr.span('bo-bind' => 'row.ccy').text
    # Movement to the statement page
    tr.span('bo-bind' => 'row.iban').click
    sleep 3
    b.a(translate: 'PAGES.ACCOUNTS_TAB.STATEMENT').click
    sleep 1
    # Account selection for extract
    b.div('prop-name' => 'Iban').span(class: 'filter-option').click
    b.div('prop-name' => 'Iban').li('data-original-index' => trs_index.to_s).click
    # Task 6
    b.div('prop-name' => 'FromDate').text_field.set((Date.today - 60).strftime('%d/%m/%Y'))

    b.button(id: 'button').click
    sleep 3

    # Transaction information collection
    b.table(id: 'accountStatements').tbody.trs.each do |tr|
      date = tr.span('bo-bind' => 'row.dateTime | sgDate').text
      description = tr.element('bo-bind' => 'row.trname').text
      amount = tr.span('bo-bind' => 'row.drAmount | sgCurrency').text.gsub(' ', '').to_f
      if amount == 0.0
        amount = tr.span('bo-bind' => 'row.crAmount | sgCurrency').text.gsub(' ', '').to_f
      else
        amount = amount * -1
      end

      # Task 7
      transaction = Transaction.new(date, description, amount, account_currency, account_name)
      account = accounts.detect { |acc| acc.name == account_name }
      account.transactions << transaction
      transactions << transaction
    end
    sleep 3
    # To the main page for the next cycle
    b.span('translate-once' => 'MENU.MAIN.HOME.NAME').click
    sleep 3

    trs_index += 1
  end

  puts "Transactions: #{transactions.inspect}"
  puts "Accounts with their Transactions: #{accounts.inspect}"
end

main

# Task 8
def noko

  b = Watir::Browser.start "https://my.fibank.bg/oauth2-server/login?client_id=E_BANK"
  b.link(id: 'demo-link').click
  sleep 3

  parsed_doc = Nokogiri.parse(b.html)

  account_xpath = 'table#dashboardAccounts tbody tr'
  accounts = []
  parsed_doc.css(account_xpath).each do |tr|
    name = tr.xpath('.//p[@bo-bind="row.acDesc"]').text
    currency = tr.xpath('.//span[@bo-bind="row.ccy"]').text
    balance = tr.xpath('.//span[@bo-bind="row.acyAvlBal | sgCurrency"]').text.gsub(' ', '').to_f

    accounts << Account.new(name, currency, balance)
  end

  puts "Nokogiri: Task 2-3. Accounts: #{accounts.inspect}"

  transactions = []
  trs_index = 0
  trs_count = parsed_doc.css(account_xpath).count
  while trs_index < trs_count
    tr = parsed_doc.css(account_xpath)[trs_index]
    account_name = tr.xpath('.//p[@bo-bind="row.acDesc"]').text
    account_currency = tr.xpath('.//span[@bo-bind="row.ccy"]').text

    b.table(id: 'dashboardAccounts').tbody.trs[trs_index].span('bo-bind' => 'row.iban').click
    sleep 3
    b.a(translate: 'PAGES.ACCOUNTS_TAB.STATEMENT').click
    sleep 1

    b.div('prop-name' => 'Iban').span(class: 'filter-option').click
    b.div('prop-name' => 'Iban').li('data-original-index' => trs_index.to_s).click
    b.div('prop-name' => 'FromDate').text_field.set((Date.today - 60).strftime('%d/%m/%Y'))

    b.button(id: 'button').click
    sleep 3

    tmp_doc = Nokogiri.parse(b.html)
    tmp_doc.css('table#accountStatements tbody tr').each do |tr|
      date = tr.xpath('.//span[@bo-bind="row.dateTime | sgDate"]').text
      description = tr.xpath('.//*[@bo-bind="row.trname"]').text
      amount = tr.xpath('.//span[@bo-bind="row.drAmount | sgCurrency"]').text.gsub(' ', '').to_f
      if amount == 0.0
        amount = tr.xpath('.//span[@bo-bind="row.crAmount | sgCurrency"]').text.gsub(' ', '').to_f
      else
        amount = amount * -1
      end

      transaction = Transaction.new(date, description, amount, account_currency, account_name)
      account = accounts.detect { |acc| acc.name == account_name }
      account.transactions << transaction
      transactions << transaction
    end
    sleep 3

    b.span('translate-once' => 'MENU.MAIN.HOME.NAME').click
    sleep 3

    trs_index += 1
  end

  puts "Nokogiri: Transactions: #{transactions.inspect}"
  puts "Nokogiri: Accounts with their Transactions: #{accounts.inspect}"
end

noko
