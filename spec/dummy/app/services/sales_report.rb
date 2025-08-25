class SalesReport
  def call
    res = ActiveRecord::Base.connection.execute("SELECT pg_sleep(0.005), * FROM generate_series(1,5);")
    [
      total: User.count * 100
    ]
  end
end
