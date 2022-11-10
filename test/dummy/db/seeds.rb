# Lato::User
##

user = Lato::User.create!(
  first_name: 'Pippo',
  last_name: 'Franco',
  email: 'admin@mail.com',
  password: 'Password1!',
  password_confirmation: 'Password1!',
  accepted_privacy_policy_version: 1,
  accepted_terms_and_conditions_version: 1
)

# Product
##

100.times do |index|
  Product.create!(
    code: Faker::Code.nric,
    status: Product.statuses.keys.sample,
    lato_user_id: user.id
  )
end
