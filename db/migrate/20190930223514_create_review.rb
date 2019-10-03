class CreateReview < ActiveRecord::Migration[6.0]
  def up
    create_table :reviews do |r|
      r.string :title
      r.string :content
      r.string :user
    end
    Review.create(title: "Test Movie", content: "Eh, it was alright.", user: "Test User")
  end

  def down
    drop_table :reviews
  end
end
