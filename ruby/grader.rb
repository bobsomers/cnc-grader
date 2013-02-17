require 'sinatra'
require 'data_mapper'
require 'bcrypt'

enable :sessions

DataMapper::Logger.new($stdout, :debug)

DataMapper::setup(:default, 'sqlite:///Users/hendrix/cnc.db')

class User
  include DataMapper::Resource
  include BCrypt

  property :id,         Serial
  property :name,       String, :unique => true
  property :email,      String, :unique => true, :format => :email_address
  # TODO: examine teh BCryptHash datamapper type instead of String
  property :pw_hash,    String, :length => 60

  belongs_to :team, :required => false
  has n, :submission

  validates_length_of :name, :min => 1
  validates_length_of :email, :min => 1

  def password
    @password ||= Password.new(@pw_hash)
  end

  def password=(new_pw)
    @password = Password.create(new_pw)
    @pw_hash = @password
  end
end

class Submission
  include DataMapper::Resource

  property :id,         Serial
  property :time,       DateTime
  property :filename,   String
  property :result,     String
  property :note,       Text

  belongs_to :user
end

class Team
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String, :unique => true

  has n, :user

  validates_length_of :name, :min => 1
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  if session['user_id']
    @logged_in = true

    # TODO: pull this user's submissions from DB
    # Submission name format: Problem Name + File Name
    @submissions = []
    @submissions.push({ :name => 'Submission A', :pass => false })
    @submissions.push({ :name => 'Submission B', :pass => true })
  else
    # TODO: pull all user's submissions from a DB
    # Submission name format: Team Name + Problem Name
    @submissions = []
    @submissions.push({ :name => 'Submission A', :pass => false })
    @submissions.push({ :name => 'Submission B', :pass => true })
  end

  # TODO: pull scoreboard data from DB
  @scoreboard = []
  @scoreboard.push({ :name => 'Team A', :score => 5 })

  erb :landing
end

get '/problem' do
  if session['user_id']
    @logged_in = true
  end

  # TODO: pull current problem name from DB
  @problem = "ones"

  erb :problem
end

get '/settings' do
  if not session['user_id']
    # TODO: redirect to landing page
    redirect to('/login')
  end

  @username = session['username']
  @teamname = session['teamname']
end

get '/login' do
  erb :login
end

post '/login' do
  # TODO
  redirect to('/')
end

get '/logout' do
  # TODO
end

get '/signup' do
  # TODO
  erb :signup
end

post '/signup' do
  @user = User.new(:name => params['name'],
                  :email => params['email'])

  error = ! @user.valid?

  if ! params['password'] or params['password'].length == 0
    error = true
    @user.errors.add(:password, "Password must not be blank")
  elsif ! params['password_confirm'] or params['password_confirm'].length == 0
    error = true
    @user.errors.add(:password_confirm, "Password must not be blank")
  elsif params['password'] != params['password_confirm']
    error = true
    @user.errors.add(:password_confirm, "Passwords must match")
  end

  if error
    @error = "Please correct the following problems"
#    @user.errors.each do |err|
#      @error += "; "
#      @error += err.join("; ")
#    end
    erb :signup
  else
    @user.password = params['password']
    if @user.save
      session['user_id'] = @user.id
      redirect to('/')
    else
      @error = "Error creating user"
      @user.errors.each do |err|
        @error += "; "
        @error += err.join("; ")
      end
      erb :signup
    end
  end
end

class Form
  def initialize(obj)
    @obj = obj
  end

  def input(field, options={})
    options = { :type => "text", :label => "" }.merge(options)
    type = options[:type]
    label = options[:label]

    val = ""
    if @obj
      val = @obj[field]
    end

    html = <<EOF
<div class="input_row">
<label for="#{field}">#{label}</label>
<input type="#{type}" name="#{field}" value="#{val}"/>
EOF
    if @obj and @obj.errors[field] and @obj.errors[field].length > 0
      err = @obj.errors[field].join("; ")
      html += <<EOF
<div class="error">#{err}</div>
EOF
    end
    html += "</div>"
    html
  end

  def submit(options={})
    opts = { :label => "Submit" }.merge(options)
    "<input type=\"submit\" value=\"#{opts[:label]}\"/>"
  end
end

helpers do
  def form_for(obj, &block)
    block.call(Form.new(obj))
  end
end
