Comment.destroy_all
User.destroy_all
Category.destroy_all

10.times do |i|
  Category.create(name: "Category #{i}")
end

10.times do |i|
  user = User.create(name: "User #{i}", age: rand(18..60))
  5.times do |j|
    user.comments.create(message: "Comment #{j}")
  end
end

puts "Seed done"
