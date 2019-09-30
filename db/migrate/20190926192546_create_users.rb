class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t| 
      t.string :username 
      t.string :password 
      t.boolean :edit 
      t.timestamps null: false 
    end
    User.create(username: "admin", password:"pass",edit: true)
  end

  def down
    drop_table :users
  end 
end
