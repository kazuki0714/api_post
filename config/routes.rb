Rails.application.routes.draw do
  get '/' => "users#new"
  post '/users/create' => "users#create"
  get 'users/index' => "users#index"
end
