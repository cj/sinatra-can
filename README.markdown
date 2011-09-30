Sinatra::Can
============

Sinatra::Can is a lightweight wrapper for CanCan. It contains a partial implementation of the ActiveController helpers.

## Installing

To install this gem, just use the gem command:

    gem install sinatra-can

To use it in your project, just hit:

    require 'sinatra/can'

## Abilities

Abilities are defined using a block just like with Sinatra. Here's the canonical example, which gives permission for admin users to manage and for non-admins to read:

    ability do |user|
        can :manage, :all if user.admin?
        can :read, :all
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

Authorizing in CanCan is very neat. You just need a single line inside your helpers:

    def '/admin' do
      authorize! :admin, :all

      haml :admin
    end

If the user isn't authorized, CanCan will throw an CanCan::AccessDenied exception. In Sinatra is is easy to catch them.

    error CanCan::AccessDenied do
      haml :not_authorized
    end

## Conditions

There is a built-in condition called :can that can be used on your blocks. It returns 404 when the user has no access.

    get '/admin', :can => [ :admin, :all ] do
      haml :admin
    end

## Modular Style

To use this gem on Modular Style apps, you just need to register it:

    class MyApp < Sinatra::Base
      register Sinatra::Can

      ...
    end

## Future

CanCan provides a lot of helpers, so this is just the start. The code is quite simple and any help is welcome!
