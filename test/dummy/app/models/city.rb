class City < ActiveRecord::Base
  markable_as [ :favorite, :hated ]
end

