
DocsDoctorWeb::Application.routes.draw do
  get "users/sign_in" => redirect('/users/auth/github'), via: [:get, :post]
  get "users/sign_up" => redirect('/users/auth/github'), via: [:get, :post]

  devise_for  :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks",  registrations: "users"}

  if Rails.env.development?
    mount UserMailer::Preview => 'mail_view'
  end

  root        :to => "pages#index"

  resources   :doc_methods
  resources   :users
  get         "/users/unsubscribe/:account_delete_token" => "users#token_delete", as: :token_delete_user
  delete      "/users/unsubscribe/:account_delete_token" => "users#token_destroy"

  resources   :repo_subscriptions
  resources   :issue_assignments


  mount Resque::Server.new, :at => "/docsdoctor/resque" if Q.env.resque?


  # format: false gives us rails 3.0 style routes so angular/angular.js is interpreted as
  # user_name: "angular", name: "angular.js" instead of using the "js" as a format
  scope format: false do
    resources :repos, only: %w[index new create]

    scope '*full_name' do
      constraints full_name: %r{[-_.a-zA-Z0-9]+/[-_.a-zA-Z0-9]+} do
        get '/',            to: 'repos#show',        as: 'repo'
        put '/',            to: 'repos#update',      as:  nil
        get '/edit',        to: 'repos#edit',        as: 'edit_repo'
        get '/subscribers', to: 'subscribers#show',  as: 'repo_subscribers'
      end
    end
  end

end
