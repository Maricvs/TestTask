class Transaction
  attr_reader :date, :description, :amount, :account

  def initialize(date, description, amount, account)
    @date = date
    @description = description
    @amount = amount
    @account = account
  end

  def to_hash_trans
    {
      "date":        @date,
      "description": @description,
      "amount":      @amount
    }
  end
end
