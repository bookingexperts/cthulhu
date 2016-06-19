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

  it 'can destroy user while activerecord can not' do
    # it is impossible to destroy user directly because post is referencing it.
    assert_raises ActiveRecord::InvalidForeignKey do
      @post.user.destroy
    end
    Cthulhu.destroy! @post.user
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

  it 'can destroy post while activerecord can not' do
    # it is impossible to destroy post directly because comment is referencing
    # it.
    assert_raises ActiveRecord::InvalidForeignKey do
      @post.destroy
    end
    Cthulhu.destroy! @post
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

  it 'can destroy comment while activerecord leaves image as dependent is not set' do
    assert_no_difference -> { Image.count } do
      assert_difference -> { Comment.count }, -1 do
        @comment.destroy
      end
    end
    @comment = create :comment_with_image, post: @post
    assert_difference -> { Image.count }, -1 do
      Cthulhu.destroy! @comment
    end
  end

  it 'destroys user but nullify the comments' do
    assert_equal 2, User.count
    assert_equal 1, Post.count
    assert_equal 1, Comment.count
    assert_equal 2, Image.count
    Cthulhu.destroy! @comment.user,
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
