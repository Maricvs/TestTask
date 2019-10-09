require 'watir'
require 'date'
require 'nokogiri'

require_relative 'account'
require_relative 'transaction'

class Fibank
  MAIN_URL = 'https://my.fibank.bg/oauth2-server/login?client_id=E_BANK'

  def initialize
    @browser = Watir::Browser.start(MAIN_URL)
    @accounts = []
  end

  def execute
    connect
    collect_accounts
    collect_transactions
    print_result
  end

  private

  def connect
    @browser.link(id: 'demo-link').click
    sleep 2
  end

  def collect_accounts
    html = fetch_accounts
    parse_accounts(html)
  end

  def collect_transactions
    @accounts.each do |account|
      html = fetch_transactions(account)
      parse_transactions(account, html)
    end
  end

  def fetch_accounts
    Nokogiri.parse(@browser.html).css('table#dashboardAccounts tbody tr')
  end

  def fetch_transactions(account)
    go_home
    sleep 2
    select_account(account)

    Nokogiri.parse(@browser.html)
  end

  def parse_accounts(html)
    html.each do |tr|
      name = tr.xpath('.//p[@bo-bind="row.acDesc"]').text
      currency = tr.xpath('.//span[@bo-bind="row.ccy"]').text
      balance = tr.xpath('.//span[@bo-bind="row.acyAvlBal | sgCurrency"]').text.gsub(' ', '').to_f
      @accounts << Account.new(name, currency, balance)
    end
  end

  def parse_transactions(account, html)
    html.css('table#accountStatements tbody tr').each do |tr|
      date = tr.xpath('.//span[@bo-bind="row.dateTime | sgDate"]').text
      description = tr.xpath('.//*[@bo-bind="row.trname"]').text
      amount = to_amount(tr.xpath('.//span[@bo-bind="row.drAmount | sgCurrency"]').text)
      if amount == 0.0
        amount = to_amount(tr.xpath('.//span[@bo-bind="row.crAmount | sgCurrency"]').text)
      else
        amount *= -1
      end

      transaction = Transaction.new(date, description, amount, account)
      account.transactions << transaction
    end
    sleep 2
  end

  def to_amount(str_amount)
    str_amount.gsub(' ', '').to_f
  end

  def select_account(account)
    @browser.table(id: 'dashboardAccounts').tbody.p('bo-bind' => 'row.acDesc', text: account.name).following_sibling(tag_name: 'a').click
    sleep 2
    @browser.a(translate: 'PAGES.ACCOUNTS_TAB.STATEMENT').click
    sleep 1
    @browser.div('prop-name' => 'Iban').span(class: 'filter-option').click
    @browser.div('prop-name' => 'Iban').span(text: /#{Regexp.escape(account.name)}/).click
    @browser.div('prop-name' => 'FromDate').text_field.set((Date.today - 60).strftime('%d/%m/%Y'))
    @browser.button(id: 'button').click
    sleep 2
  end

  def go_home
    @browser.span('translate-once' => 'MENU.MAIN.HOME.NAME').click
  end

  def print_result
    @accounts.each do |account|
      puts "Account: #{account.name} (#{account.currency}), balance: #{account.balance}"
      if account.transactions.count > 0
        puts "Transactions in the last two months:"
        account.transactions.each do |transaction|
          puts "\t* #{transaction.date} - #{transaction.description}. Amount: #{transaction.amount} #{transaction.account.currency}"
        end
      else
        puts "No transactions"
      end
      puts "\n"
    end
  end
end

Fibank.new.execute
