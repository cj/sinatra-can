require 'cancan/ability'
require 'cancan/exceptions'
require 'cancan/rule'

module Sinatra
  # Sinatra::Can is a lightweight wrapper for CanCan. It contains a partial implementation of the ActiveController helpers.
  module Can
    helpers do
      # The can? method receives an action and an object as parameters and checks if the current user is allowed, as declared on the Ability. This method is a helper that can be used inside blocks:
      #
      #   can? :destroy, @project
      #
      # And in views too, of course
      #
      #   <% if can? :create, Project %>
      #     <%= link_to "New Project", new_project_path %>
      #   <% end %>
      def can?(*args)
        current_ability.can?(*args)
      end

      # The cannot? methods works just like the can?, except it's the opposite.
      #
      #   cannot? :edit, @project
      def cannot?(*args)
        current_ability.cannot?(*args)
      end

      # Authorizing in CanCan very neat. You just need a single line inside your helpers:
      #
      #     def '/admin' do
      #       authorize! :admin, :all
      #
      #       haml :admin
      #     end
      #
      # If the user isn't authorized, CanCan will throw an CanCan::AccessDenied exception. In Sinatra is is easy to catch them.
      #
      #     error CanCan::AccessDenied do
      #       haml :not_authorized
      #     end
      def authorize!(who, what)
        current_ability.authorize!(who, what, :message => 'Not Authorized')
      end

      # Returns the current ability
      def current_ability
        @current_ability ||= ::Ability.new(current_user)
      end

      # Returns the current user
      def current_user
        @current_user ||= instance_eval(&current_user_block) if current_user_block
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

    # Returns the current block defining an user
    def current_user_block
      @current_user_block
    end
  end

  register Can
end
