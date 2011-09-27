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

    class Ability
      include CanCan::Ability

      def initialize(user)
        user ||= User.new
        if user.is_admin?
          can :manage, :all
        else
          can :read, :all
        end
      end
    end

    app.set :dump_errors, true
    app.set :raise_errors, true
    app.set :show_exceptions, false
  end

  it "should allow management to the admin user" do
    app.user { User.new('admin') }
    app.get('/1') { can?(:manage, :all).to_s }
    get '/1'
    last_response.body.should == 'true'
  end

  it "shouldn't allow management to the guest" do
    app.user { User.new('guest') }
    app.get('/2') { cannot?(:manage, :all).to_s }
    get '/2'
    last_response.body.should == 'true'
  end

  it "should act naturally when authorized" do
    app.user { User.new('admin') }
    app.error(CanCan::AccessDenied) { 'not authorized' }
    app.get('/3') { authorize!(:manage, :all); 'okay' }
    get '/3'
    last_response.body.should == 'okay'
  end

  it "should raise errors when not authorized" do
    app.user { User.new('guest') }
    app.error(CanCan::AccessDenied) { 'not authorized' }
    app.get('/4') { authorize!(:manage, :all); 'okay' }
    get '/4'
    last_response.body.should == 'not authorized'
  end

  it "should respect the 'user' block" do
    app.user { User.new('testing') }
    app.get('/5') { current_user.name }
    get '/5'
    last_response.body.should == "testing"
  end
end
