class Product < ApplicationRecord
  enum status: {
    created: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, _suffix: true

  # Relations
  ##

  belongs_to :lato_user, class_name: 'Lato::User'

  # Scopes
  ##

  scope :lato_index_sort, ->(column, order) do
    return joins(:lato_user).order("lato_users.last_name #{order}, lato_users.first_name #{order}") if column == :lato_user_id

    order("#{column} #{order}")
  end
end
