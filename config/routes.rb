Jets.application.routes.draw do
  namespace :dexcom do
    get :auth_callback, to: 'partners/dexcom/auth#auth_callback'
  end
end