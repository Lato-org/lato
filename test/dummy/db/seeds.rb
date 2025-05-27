# Lato::User
##

Lato::User.create!(
  first_name: 'Admin',
  last_name: 'Admin',
  email: 'admin@mail.com',
  password: 'Password1!',
  password_confirmation: 'Password1!',
  accepted_privacy_policy_version: 1,
  accepted_terms_and_conditions_version: 1
)

Lato::User.create!(
  first_name: 'Pippo',
  last_name: 'Franco',
  email: 'pippo.franco@mail.com',
  password: 'Password1!',
  password_confirmation: 'Password1!',
  accepted_privacy_policy_version: 1,
  accepted_terms_and_conditions_version: 1
)

Lato::User.create!(
  first_name: 'Mimmo',
  last_name: 'Abbondo',
  email: 'mimmo.abbondo@mail.com',
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
    lato_user_id: Lato::User.all.sample.id
  )
end
