require 'cancan/ability'
require 'cancan/exceptions'
require 'cancan/rule'

module Sinatra
  module Can
    helpers do
      def can?(*args)
        current_ability.can?(*args)
      end

      def cannot?(*args)
        current_ability.cannot?(*args)
      end

      def authorize!(who, what)
        current_ability.authorize!(who, what, :message => 'Not Authorized')
      end

      def current_ability
        @current_ability ||= ::Ability.new(current_user)
      end

      def current_user
        @current_user ||= instance_eval(&current_user_block) if current_user_block
      end
    end

    def current_user_block
      @current_user_block
    end

    def user(&block)
      @current_user_block = block
    end
  end

  register Can
end
