require 'test_helper'

describe Cthulhu::Destroyer do

  before do
    @post = create :post_with_image
    @comment = create :comment_with_image, post: @post
  end

  it 'destroys user' do
    assert_equal 2, User.count
    assert_equal 1, Post.count
    assert_equal 1, Comment.count
    assert_equal 2, Image.count
    Cthulhu.destroy! @post.user
    assert_equal 1, User.count
    assert_equal @comment.user.id, User.last.id
    assert_equal 0, Post.count
    assert_equal 0, Comment.count
    assert_equal 0, Image.count
  end

  it 'destroys post' do
    assert_equal 2, User.count
    assert_equal 1, Post.count
    assert_equal 1, Comment.count
    assert_equal 2, Image.count
    Cthulhu.destroy! @post
    assert_equal 2, User.count
    assert_equal 0, Post.count
    assert_equal 0, Comment.count
    assert_equal 0, Image.count
  end

  it 'destroys comment' do
    assert_equal 2, User.count
    assert_equal 1, Post.count
    assert_equal 1, Comment.count
    assert_equal 2, Image.count
    Cthulhu.destroy! @comment
    assert_equal 2, User.count
    assert_equal 1, Post.count
    assert_equal 0, Comment.count
    assert_equal 1, Image.count
    assert_equal Image.last.imagable, @post
  end

  it 'destroys user but nullify the comments' do
    assert_equal 2, User.count
    assert_equal 1, Post.count
    assert_equal 1, Comment.count
    assert_equal 2, Image.count
    Cthulhu.destroy! @comment.user,
      blacklisted: [],
      not_to_be_crawled: [],
      overrides: {
        User => {
          comments: {
            dependent: :nullify
          },
          uploaded_images: {
            dependent: :nullify
          }
        }
      }
    assert_equal 1, User.count
    assert_equal @post.user.id, User.last.id
    assert_equal 1, Post.count
    assert_equal 1, Comment.count
    assert_equal 2, Image.count
    assert_nil @comment.reload.user
  end

end
