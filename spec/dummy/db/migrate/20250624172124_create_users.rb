class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end

    50.times do |i|
      User.create(name: "User #{i}", age: rand(18..60))
    end
  end
end
