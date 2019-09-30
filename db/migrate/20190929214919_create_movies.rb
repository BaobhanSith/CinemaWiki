class CreateMovies < ActiveRecord::Migration[5.1]
  def up
    create_table :movies do |m| 
      m.string :title
      m.string :director
      m.string :genre
      m.string :release
      m.string :poster
    end
    Movie.create(title: "Sample Movie", director: "Reece Tait", genre: "Indie", release: "29th September 2019", poster: "https://www.google.com/url?sa=i&rct=j&q=&esrc=s&source=images&cd=&cad=rja&uact=8&ved=2ahUKEwiIhJf9gvfkAhVR5uAKHXBlDVwQjRx6BAgBEAQ&url=https%3A%2F%2Fwww.esquire.com%2Fentertainment%2Fmovies%2Fa26828212%2Fmarvel-avengers-endgame-poster-controversy-change%2F&psig=AOvVaw2GqO0TKANDb10GnF_n9dsn&ust=1569880547001300")
  end
  def down
    drop_table :movies
  end
end
