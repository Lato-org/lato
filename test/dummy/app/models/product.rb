class Product < ApplicationRecord
  enum status: {
    created: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, _suffix: true
end
