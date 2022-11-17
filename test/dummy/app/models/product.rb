class Product < ApplicationRecord
  enum status: {
    created: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, _suffix: true

  attr_reader :actions

  # Relations
  ##

  belongs_to :lato_user, class_name: 'Lato::User'

  # Scopes
  ##

  scope :lato_index_order, ->(column, order) do
    return joins(:lato_user).order("lato_users.last_name #{order}, lato_users.first_name #{order}") if column == :lato_user_id

    order("#{column} #{order}")
  end

  scope :lato_index_search, ->(search) do
    joins(:lato_user).where("lower(code) LIKE :search OR lower(lato_users.first_name) LIKE :search OR lower(lato_users.last_name) LIKE :search", search: "%#{search.downcase.strip}%")
  end

  # Hooks
  ##

  before_create do
    self.status ||= :created
  end

  # Helpers
  ##

  def lifetime
    Time.now - created_at
  end

  def status_color
    return 'warning' if created_status?
    return 'primary' if in_progress_status?
    return 'success' if completed_status?
    return 'danger' if cancelled_status?

    'secondary'
  end
end
