require 'cancan/ability'
require 'cancan/exceptions'
require 'cancan/rule'

module Sinatra
  # Sinatra::Can is a lightweight wrapper for CanCan. It contains a partial implementation of the ActiveController helpers.
  module Can
    # Helpers for Sinatra
    module Helpers
      # The can? method receives an action and an object as parameters and checks if the current user is allowed, as declared on the Ability. This method is a helper that can be used inside blocks:
      #
      #   can? :destroy, @project
      #
      # And in views too, of course
      #
      #   <% if can? :create, Project %>
      #     <%= link_to "New Project", new_project_path %>
      #   <% end %>
      def can?(action, subject, options = {})
        current_ability.can?(action, subject, options)
      end

      # The cannot? methods works just like the can?, except it's the opposite.
      #
      #   cannot? :edit, @project
      #
      # Works in views and controllers.
      def cannot?(action, subject, options = {})
        current_ability.cannot?(action, subject, options)
      end

      # Authorizing in CanCan very neat. You just need a single line inside your helpers:
      #
      #     def '/admin' do
      #       authorize! :admin, :all
      #
      #       haml :admin
      #     end
      #
      # If the user isn't authorized, your app will return a RESTful 403 error, but you can also instruct it to redirect to other pages by defining this setting at your Sinatra configuration.
      #
      #     set :not_auth, '/login'
      # 
      # Or directly in the authorize! command itself:
      #
      #     authorize! :admin, :all, :not_auth => '/login'
      #
      def authorize!(action, subject, options = {})
        current_ability.authorize!(action, subject, options.merge(:message => 'Not Authorized'))
      rescue CanCan::AccessDenied => ex
        error 403 unless options[:not_auth] || settings.respond_to?(:not_auth)
        redirect options[:not_auth] if options[:not_auth]
        redirect settings.not_auth if settings.respond_to?(:not_auth)
      end

      # Returns the current ability
      def current_ability
        @current_ability ||= LocalAbility.new(current_user) if LocalAbility.include?(CanCan::Ability)
        @current_ability ||= ::Ability.new(current_user)
      end

      # Evaluates the `user do...end` block and returns the current user
      def current_user
        @current_user ||= instance_eval(&self.class.current_user_block) if self.class.current_user_block
      end
    end

    # Use this block to pass the current user to CanCan. You have access to all Sinatra variables inside it.
    #
    #   user do
    #     User.find(:id => session[:id])
    #   end
    def user(&block)
      @current_user_block = block
    end

    # Sets a condition that can be used on route blocks.
    #
    #   get '/admin', :can => [ :admin, :all ] do
    #     haml :admin
    #   end
    set(:can) { |a,b| condition { can? a, b } }

    # Contains the Ability object
    LocalAbility = Class.new

    # Use this block to create abilities. You can use the same syntax as in CanCan:
    #
    #   ability do |user|
    #     can :delete, Article do |article|
    #       article.creator == user
    #     end
    #     can :edit, Article
    #   end
    def ability(&block)
      LocalAbility.send :include, CanCan::Ability
      LocalAbility.send :define_method, :initialize, &block
    end

    def current_user_block
      @current_user_block
    end

    def self.registered(app)
      app.helpers Helpers
    end
  end

  register Can
end
