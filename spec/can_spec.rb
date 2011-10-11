require 'rspec'
require 'rack/test'
require 'sinatra'
require 'sinatra/can'

describe 'sinatra-can' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    class User
      def initialize(name = "guest")
        @name = name
      end

      def name
        @name
      end

      def is_admin?
        @name == "admin"
      end
    end

    ability do |user|
      can :edit, :all if user.is_admin?
      can :read, :all
    end

    app.set :dump_errors, true
    app.set :raise_errors, true
    app.set :show_exceptions, false
  end

  it "should allow management to the admin user" do
    app.user { User.new('admin') }
    app.get('/1') { can?(:edit, :all).to_s }
    get '/1'
    last_response.body.should == 'true'
  end

  it "shouldn't allow management to the guest" do
    app.user { User.new('guest') }
    app.get('/2') { cannot?(:edit, :all).to_s }
    get '/2'
    last_response.body.should == 'true'
  end

  it "should act naturally when authorized" do
    app.user { User.new('admin') }
    app.error(CanCan::AccessDenied) { 'not authorized' }
    app.get('/3') { authorize!(:edit, :all); 'okay' }
    get '/3'
    last_response.body.should == 'okay'
  end

  it "should raise errors when not authorized" do
    app.user { User.new('guest') }
    app.get('/4') { authorize!(:edit, :all); 'okay' }
    get '/4'
    last_response.status.should == 403
  end

  it "should respect the 'user' block" do
    app.user { User.new('testing') }
    app.get('/5') { current_user.name }
    get '/5'
    last_response.body.should == "testing"
  end

  it "shouldn't allow a rule if it's not declared" do
    app.user { User.new('admin') }
    app.get('/6') { can?(:destroy, :all).to_s }
    get '/6'
    last_response.body.should == "false"
  end

  it "should throw 403 errors upon failed conditions" do
    app.user { User.new('admin') }
    app.get('/7', :can => [ :create, User ]) { 'ok' }
    get '/7'
    last_response.status.should == 403
  end

  it "should accept conditions" do
    app.user { User.new('admin') }
    app.get('/8', :can => [ :edit, :all ]) { 'ok' }
    get '/8'
    last_response.status.should == 200
  end

  it "should accept settings.not_auth and redirect when not authorized" do
    app.user { User.new('guest') }
    app.set(:not_auth, '/login' )
    app.get('/login') { 'login here' }
    app.get('/9') { authorize! :manage, :all }
    get '/9'
    follow_redirect!
    last_response.body.should == 'login here'
  end
end
