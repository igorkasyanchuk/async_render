class Report
  def initialize(user)
    @user = user
  end

  def generate
    res = ActiveRecord::Base.connection.execute("SELECT pg_sleep(0.005), * FROM generate_series(1,5);")
    [
      users: User.count,
      categories: Category.count
    ]
  end
end
