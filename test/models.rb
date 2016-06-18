#
#         users
#       /   |   \
#    posts  |    \
#    |   \  |     \
#     \ comments  |
#      \    |    /
#       \   |   /
#        \  |  /
#        images
#

class User < ActiveRecord::Base

  has_many :posts
  has_many :comments
  has_many :uploaded_images, class_name: 'Image', inverse_of: :uploader, foreign_key: :user_id

end

class Image < ActiveRecord::Base

  belongs_to :imagable, polymorphic: true, inverse_of: :images
  belongs_to :uploader, class_name: 'User', inverse_of: :uploaded_images, foreign_key: :user_id

  validates_presence_of :imagable

end

class Post < ActiveRecord::Base

  belongs_to :user
  has_many :images, as: :imagable, inverse_of: :imagable
  has_many :comments

end

class Comment < ActiveRecord::Base

  belongs_to :post
  belongs_to :user
  has_many :images, as: :imagable, inverse_of: :imagable

end
