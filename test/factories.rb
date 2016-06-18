FactoryGirl.define do

  sequence(:word_sequence) { |n| "foo#{n + 1}" }

  factory :user do
    name { generate(:word_sequence) }
  end

  factory :image do
    association :uploader, factory: :user
    file { generate(:word_sequence) }
  end

  factory :post do
    title 'title of my post'
    content 'content of my post'
    association :user
  end

  factory :post_with_image, parent: :post do
    after :build do |record|
      record.images = [build(:image, imagable: record, uploader: record.user)]
    end
  end

  factory :comment do
    association :post
    content 'my comment'
    association :user
  end

  factory :comment_with_image, parent: :comment do
    after :build do |record|
      record.images = [build(:image, imagable: record, uploader: record.user)]
    end
  end

end
