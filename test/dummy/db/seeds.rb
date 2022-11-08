# Product
##

100.times do |index|
  Product.create!(
    code: Faker::Code.nric,
    status: Product.statuses.keys.sample
  )
end
