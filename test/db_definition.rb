class DbDefinition < ActiveRecord::Migration

  def change
    create_table :users do |t|
      t.string :name
    end
    create_table :images do |t|
      t.string :file
      t.references :imagable, polymorphic: true
      t.references :user, foreign_key: true
    end
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.references :user, foreign_key: true
    end
    create_table :comments do |t|
      t.text :content
      t.references :post, foreign_key: true
      t.references :user, foreign_key: true
    end
  end

end
