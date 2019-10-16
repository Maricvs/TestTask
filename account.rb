class Account
  attr_reader :transactions, :name, :currency, :balance

  def initialize(name, currency, balance)
    @name = name
    @currency = currency
    @balance = balance
    @transactions = []
  end

  def to_hash
    {
      "name":     @name,
      "currency": @currency,
      "balance":  @balance,
    }
  end
end
