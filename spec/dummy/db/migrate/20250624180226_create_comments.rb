class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.text :message

      t.timestamps
    end

    100.times do |i|
      Comment.create!(user_id: User.ids.sample, message: "Comment #{i}")
    end
  end
end
