class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    drop_table :posts
    create_table :posts do |t|
      t.text :content,    null:false
      t.string :category
      t.string :locate
      t.date :date
      t.string :disaster, null:false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :posts, [:user_id, :created_at]
  end
end
