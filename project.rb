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


usernames=Array.new
usernames<<"admin"
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

#Creates a function which takes in an argument and opens a file with that arguement
def readFile(filename)
	info = ""
	file = File.open(filename)
	file.each do |line|
		info = info +line
	end
	file.close
	$myinfo = info
end

#Home page
get '/' do
	info = ''
	len = info.length
	len1 = len
	readFile("name.txt") #Opens name.txt file
	@info = info + '' + $myinfo
	words=@info.split((/[^[[:word:]]]+/))
	len4=words.length
	len = @info.length
	len2 = len - 1
	len3 = len2-len1
	if len3>0
		len3 = len3-1
	end
	@words2 = len3.to_s
	@words1=len4.to_s

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
        redirect '/wrongaccount'
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
	@list2 = User.all.sort_by{|u| [u.id]} #Passes all user data to the list2 class
	erb :admincontrols
end

#Movies page
get '/movies' do
  @movies = Movie.all.sort_by{|m| [m.id]} #Passes all movie data to the movies class
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
  m.director = params[:director]
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
  review = ""
  file = File.open("Archives.txt", "a")
  review += "Title: " + params[:title] + " Content: " + params[:content] + " User: "+ $credentials[0] #Adds current review data to the review variable
  file.puts review #Appends the content of the review variable to the Archives.txt file
  file.close
  #Creates a new instance of the Review class and passes the data into it
  r = Review.new
  r.title = params[:title]
  r.content = params[:content]
  r.user = $credentials[0]
  r.save
  redirect '/movies'
end

#Individual User page
get '/user/:uzer' do
	@Userz = User.where(:username => params[:uzer]).to_a.first #Gets the data for the specified user
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
		@list2 = User.all.sort_by{|u| [u.id]}
		erb :admincontrols
	end
end

not_found do
	status 404
	redirect '/notfound'
end
