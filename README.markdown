Sinatra::Can
============

Sinatra::Can is a lightweight wrapper for the CanCan authorization library. It contains a partial implementation of CanCan's Rails helpers, but in Sinatra.

Check out CanCan if you don't know it: https://github.com/ryanb/cancan/

## Installing

To install this gem, just use the gem command:

    gem install sinatra-can

To use it in your project, just require it:

    require 'sinatra/can'

## Abilities

Abilities are defined using a block just like with Sinatra. Here's the canonical example, which gives permission for admin users to manage and for non-admins to read:

    ability do |user|
      can :manage, :all if user.admin?
      can :read, :all
    end

You can use regular CanCan syntax, since our gem is just a wrapper:

    ability do |user|
      if user.is_admin?
        can :kick, User do |victim|
          !victim.is_admin?
        end
      end
    end

Alternatively, you can use a class named Ability, which is useful if you're porting a project from Rails to Sinatra. That's the regular CanCan way:

    class Ability
      include CanCan::Ability

      def initialize(user)
        can :manage, :all if user.admin?
        can :read, :all
      end
    end

## Current User

You can pass the current user with a simple block:

    user do
      User.find(:id => session[:id])
    end

## Checking Abilities

The can? method receives an action and an object as parameters and checks if the current user is allowed, as declared in the Ability. This method is a helper that can be used inside blocks:

    can? :destroy, @project
    cannot? :edit, @project

And in views too:

    <% if can? :create, Project %>
      <%= link_to "New Project", new_project_path %>
    <% end %>

## Authorizing

Authorizing in CanCan is very neat. You just need a single line inside your helpers:

    def '/admin' do
      authorize! :admin, :all

      haml :admin
    end

If the user isn't authorized, your app will return a RESTful 403 error, but you can also instruct it to redirect to other pages by defining this setting at your Sinatra configuration.

    set :not_auth, '/login'

Or directly in the authorize! command itself:

    authorize! :admin, :all, :not_auth => '/login'

Sinatra lacks controllers, but you can use "before" blocks to restrict groups of routes with wildcards (or even regular expressions). In this case you'll only be able to access the page if your user is authorize to ":manage" some "Customers".

    before '/customers/*' do
      authorize! :manage, Customers
    end

## Conditions

There is a built-in condition called :can that can be used in your blocks. It returns 404 when the user has no access.

    get '/admin', :can => [ :admin, :all ] do
      haml :admin
    end

## Modular Style

To use this gem in Modular Style apps, you just need to register it:

    class MyApp < Sinatra::Base
      register Sinatra::Can

      ...
    end

## Future

CanCan provides a lot of helpers, so this is just the start. The code is quite simple and any help is welcome!
