Sinatra::Cell
=============

Sinatra::Can is a lightweight wrapper for CanCan. It contains a partial implementation of the ActiveController helpers.

## Installing

To install this gem, just use the gem command:

    gem install sinatra-can

To use it in your project, just hit:

    require 'sinatra/can'

## Abilities

Abilities are defined just like you would in CanCan. Here's the canonical example, which gives permission for admin users to manage and for non-admins to read:

    class Ability
      include CanCan::Ability

      def initialize(user)
        user ||= User.new # guest user (not logged in)
        if user.admin?
          can :manage, :all
        else
          can :read, :all
        end
      end
    end

## Current User

You can pass the current user with a simple block:

    user do
      User.find(:id => session[:id])
    end

## Checking Abilities

The can? method receives an action and an object as parameters and checks if the current user is allowed, as declared on the Ability. This method is a helper that can be used inside blocks:

    can? :destroy, @project
    cannot? :edit, @project

And in views too:

    <% if can? :create, Project %>
      <%= link_to "New Project", new_project_path %>
    <% end %>

## Authorizing

Authorizing in CanCan very neat. You just need a single line inside your helpers:

    def '/admin' do
      authorize! :admin, :all

      haml :admin
    end

If the user isn't authorized, CanCan will throw an CanCan::AccessDenied exception. In Sinatra is is easy to catch them.

    error CanCan::AccessDenied do
      haml :not_authorized
    end

## Future

CanCan provides a lot of helpers, so this is just the start. The code is quite simple and any help is welcome!