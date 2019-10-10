sql_places = "ALTER TABLE places ADD FULLTEXT (name, description, address)"
ActiveRecord::Base.connection.execute(sql_places)
sql_foods = "ALTER TABLE foods ADD FULLTEXT (name)"
ActiveRecord::Base.connection.execute(sql_foods)
# User.create!(name: "Administrator",
#   email: "admin@gmail.com",
#   password: "admin123",
#   password_confirmation: "admin123",
#   gender: 1,
#   avatar: "",
#   role: 1,
#   lock_at: 0)


# provinces = []
# 20.times do |n|
#   name = Faker::Address.city
#   parent_id = n > 5 ? Faker::Number.between(1, 5) : nil
#   provinces << Province.create!(name: name,
#     parent_id: parent_id)
# end
