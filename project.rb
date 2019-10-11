require 'sinatra'
require 'sinatra/activerecord'
set	:bind,'0.0.0.0'

#Creates connection to database
ActiveRecord::Base.establish_connection( 
  :adapter => 'sqlite3', 
  :database => 'cinewiki.db' 
)

#Creates the users class
class User < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true              
  validates :password, presence: true 
end

#Creates the movies class
class Movie < ActiveRecord::Base
  validates :title, presence: true
  validates :director, presence: true
  validates :genre, presence: true
  validates :release, presence: true
  validates :poster, presence: true
end

#Creates the review class
class Review < ActiveRecord::Base
  validates :title, presence: true
  validates :content, presence: true
  validates :user, presence: true
end




helpers do
  def protected
    if authorized? #Checks if the current user has edit permissions
      return
    end
    redirect '/denied'
  end

  def authorized?
    if $credentials != nil
      @Userz = User.where(:username => $credentials[0]).to_a.first #Gets the currently logged in user
      if @Userz
        if @Userz.edit == true #Checks if edit permission is true
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end
end


$myinfo = 'info'
@info = ''

#Create the array for all the usernames
usernames=Array.new
usernames<<"admin"
#Creates a function which takes in an argument and opens a file with that arguement
def readFile(filename)
	info = ""
	characters=0 #counts the number of characters
	words=0 #counts the number of words
	file = File.open(filename)
	file.each do |line|
		info=info+line
		#Eliminates the HTML tags from the text editor and creates the array for all the words
		wordss=line.gsub(/<\/?[^>]*>/,"")
		#Eliminates the endlines from the HTML code
		wordss=wordss.gsub("&nbsp;","")
		#Created the array for all the characters
		wordss1=line.gsub(/<\/?[^>]*>/,"")
		wordss1=wordss1.gsub("&nbsp;","")
		#Changes the characters array by eliminating all the spaces and splitting it into words
		wordss1=wordss1.split(" ")
		for word in wordss1
			#Counts each word's length and adds the length to the characters variable 
			characters=characters+word.length
		end
		#Splits the words array into words by eliminating all the other characters , including the question marks, exclamation marks, commas etc.
		wordss=wordss.split(/[^[[:word:]]]+/)
		#Adds the number of words to the words variable 
		words=words+wordss.length
		
	end
	file.close
	$myinfo = info # saves the information from the file into a global variable
	$characters=characters #  saves the number of characters from the file into a global variable
	$words=words # saves the number of words from the file into a global variable
end

#Home page
get '/' do
  readFile("name.txt") #Opens name.txt file
  @info = $myinfo
  erb :home
end

#About page
get '/about' do
  erb :about
end

#Create Movies page
get '/createmovie' do
  protected
  erb :createmovie
end

#Edit page
get'/edit'do
  info=""
  file = File.open("name.txt") #Opens the name.txt file
  file.each do |line|
    info = info + line #Adds each line to the info variable
  end
  file.close
  @info = info
  protected
  erb :edit
end

put'/edit' do
  info = "#{params[:message]}" #Extracts the current content of the message text area and saves it in the info variable
  @info = info
  file = File.open("name.txt", "w") #Opens the name.txt file for writing
  file.puts@info #Puts the content of the info class in the file
  file.close
  redirect'/'
end

#Reset button resets the content of the edit page
get '/reset' do
  erb :edit
end

#Login page
get '/login' do
  erb :login
end

post '/login' do 
  $credentials = [params[:username],params[:password]] #Sets the current credentials to the info from the form
  @Users = User.where(:username => $credentials[0]).to_a.first #Searches for a matching username in the database
  if @Users
    if @Users.password == $credentials[1] 
      #Takes the current credentials and time and passes them into a file which has been oppened for appending
      info = ""
      file = File.open("UserLog.txt", "a")
      time = Time.new
      info += "User: " + $credentials[0] + " tried to log on at " + time.inspect + "\n"
      file.puts info
      file.close
      redirect '/'
    else 
      $credentials = ['','']
      redirect '/wrongaccount' 
    end 
  else 
    $credentials = ['','']
    redirect '/noaccount'
  end
end 

#Wrong Account page
get '/wrongaccount' do
  erb :wrongaccount
end

#Wrong Username page
get '/wrongusername' do
  erb :wrongusername
end

#Register page
get '/register' do
  erb :register
end

post '/register' do
  #Creates a new user and sets the username and password for it to the data coming in
  n = User.new 
  n.username = params[:username]  
  n.password = params[:password]
  if n.username == "admin" and n.password == "pass" #Checks if the user is the admin account and gives it the edit permission
    n.edit = true 
  end 	 	
  if usernames.include? n.username #Checks to see if username is already in use
    n.destroy
    redirect '/wrongusername'
  else
    usernames<<n.username
    n.save
  end 
  redirect '/'
end 

#Logout page
get '/logout' do
  $credentials = [""]
  redirect '/'
end

#Not Found page
get '/notfound' do
  erb :notfound
end

#No Account page
get '/noaccount' do
  erb :noaccount
end

#Denied page
get '/denied' do
  erb :denied
end

#Admin Controls page
get '/admincontrols' do
  protected
  @users = User.all.sort_by{|u| [u.id]} #Passes all user data to the list2 class
  @movies = Movie.all.sort_by{|m| [m.id]} #Passes all the movie data to the movies class
  @reviews = Review.all.sort_by{|m| [m.id]} #Passes
  erb :admincontrols
end

get '/backup' do
  protected
  @users = User.all.sort_by{|u| [u.id]}
  @movies = Movie.all.sort_by{|m| [m.id]}
  @reviews = Review.all.sort_by{|r| [r.id]}
  userString = ""
  userEditString = ""
  movieString = ""
  reviewString = ""

  #Opens up the user text file and writes the content of the user table to it
  userFile = File.open("Users.txt", "w")
  @users.each do |user|
    if(user.edit)
      userEditString = "true"
    else
      userEditString = "false"
    end
    userString += user.username.to_s + "//" + user.password.to_s + "//" + userEditString + "//" + user.created_at.to_s + "\n"
  end
  userFile.puts userString
  userFile.close
  
  #Opens up the movie text file and writes the content of the user table to it
  movieFile = File.open("Movies.txt", "w")
  @movies.each do |movie|
    movieString += movie.title.to_s + "//" + movie.director.to_s + "//" + movie.genre.to_s + "//" + movie.release.to_s + "//" + movie.poster.to_s + "\n"
  end
  movieFile.puts movieString
  movieFile.close
  
  #Opens up the movie text file and writes the content of the user table to it
  reviewFile = File.open("Reviews.txt", "w")
  @reviews.each do |review|
    reviewString += review.title.to_s + "//" + review.content.to_s + "//" + review.user.to_s + "\n"
  end
  reviewFile.puts reviewString
  reviewFile.close

  redirect '/'
end

get '/restore' do
  protected

  #Deletes the content of the User table and restores it to the last backed up version
  User.delete_all
  userFile = File.open("Users.txt")
  userData = []
  userFile.each do |line|
    userData = line.split("//")
    u = User.new
    u.username = userData[0]
    u.password = userData[1]
    puts userData[2]
    if(userData[2].to_s == "true")
      puts "User can edit"
      u.edit = true
    else
      puts "User cannot edit"
      u.edit = false
    end
    u.save
  end
  userFile.close

  #Deletes the content of the Movie table and restores it to the last backed up version
  Movie.delete_all
  movieFile = File.open("Movies.txt")
  movieData = []
  movieFile.each do |line|
    movieData = line.split("//")
    m = Movie.new
    m.title = movieData[0]
    m.director = movieData[1]
    m.genre = movieData[2]
    m.release = movieData[3]
    m.poster = movieData[4]
    m.save
  end
  movieFile.close

  #Deletes the content of the Review table and restores it to the last backed up version
  Review.delete_all
  reviewFile = File.open("Reviews.txt")
  reviewData = []
  reviewFile.each do |line|
    reviewData = line.split("//")
    r = Review.new
    r.title = reviewData[0]
    r.content = reviewData[1]
    r.user = reviewData[2]
    r.save
  end
  reviewFile.close
  redirect '/logout'
end

#Movies page
get '/movies' do
  @movies = Movie.all.sort_by{|m| [m.title]} #Passes all movie data to the movies class
  erb :movies
end

#Create Movie page
get '/createmovie' do
  protected
  erb :createmovie
end

post '/createmovie' do
  #Creates a new instance of the movie class and passes in the data passed through the form before saving it
  m = Movie.new
  m.title = params[:title]
  m.director = "Christopher Nolan"
  m.genre = params[:genre]
  m.release = params[:release]
  m.poster = params[:poster]
  m.save
  redirect '/movies'
end

#Individual Movie page
get '/movies/:movie' do
  @Movies = Movie.where(:title => params[:movie]).to_a.first #Gets the current movie data
  @Reviews = Review.where(:title => params[:movie]).to_a #Gets all review data for the current movie
  erb :movie
end

#Create Review page
get '/createreview' do
  if $credentials
    if $credentials[0] != "" #Checks to see if user is logged in
      @moviez = Movie.all.sort_by{|m| [m.id]} #Passes in all movie data
      erb :createreview
    else
       redirect '/denied'
    end
  else
    redirect '/denied'
  end
end

post '/createreview' do
  #Creates a new instance of the Review class and passes the data into it
  r = Review.new
  r.title = params[:title].to_s
  r.content = params[:content].to_s
  r.user = $credentials[0].to_s
  r.save
  redirect '/movies'
end

#Individual User page
get '/user/:uzer' do
  @Userz = User.where(:username => params[:uzer]).to_a.first #Gets the data for the specified user
  @Reviewz = Review.where(:user => params[:uzer]).to_a #Gets all reviews submitted by the user
  if @Userz != nil
    erb :profile
  else
    redirect '/denied'
  end
end

#User Edit code
put '/user/:uzer' do
  n = User.where(:username => params[:uzer]).to_a.first
  n.edit = params[:edit] ? 1 : 0
  n.save
  redirect '/'
end

#Delete User code
get '/user/delete/:uzer' do
  protected
  n = User.where(:username => params[:uzer]).to_a.first
  if n.username == "admin"
    erb :denied
  else
    n.destroy
    usernames.delete(n.username)
    @users = User.all.sort_by{|u| [u.id]}
    @movies = Movie.all.sort_by{|m| [m.id]}
    @reviews = Review.all.sort_by{|r| [r.id]}
    erb :admincontrols
  end
end

#Delete Movie code
get '/movies/delete/:movie' do
  protected
  n = Movie.where(:title => params[:movie]).to_a.first
  @reviewz = Review.where(:title => params[:movie]).to_a
  @reviewz.each do |r|
    r.destroy
  end
  n.destroy
  @users = User.all.sort_by{|u| [u.id]}
  @movies = Movie.all.sort_by{|m| [m.id]}
  @reviews = Review.all.sort_by{|r| [r.id]}
  erb :admincontrols
end

#Delete Review Page
get '/movies/review/:id' do
  protected
  n = Review.where(:id => params[:id]).to_a.first
  n.destroy
  @users = User.all.sort_by{|u| [u.id]}
  @movies = Movie.all.sort_by{|m| [m.id]}
  @reviews = Review.all.sort_by{|r| [r.id]}
  erb :admincontrols
end

not_found do
  status 404
  redirect '/notfound'
end
