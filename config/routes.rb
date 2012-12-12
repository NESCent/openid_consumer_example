OpenIDConsumer::Application.routes.draw do

  # from ruby-openid
  root :to => "consumer#index"
  match ':controller(/:action(/:id))(.:format)'
end
