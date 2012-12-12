SimpleCms::Application.routes.draw do

  # from ruby-openid
  root :to => "login#index"
  match ':controller(/:action(/:id))(.:format)'
end
