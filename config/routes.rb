Rails.application.routes.draw do
  concern :paginatable do
    get '(page/:page)', :action => :index, :on => :collection, :as => ''
  end

  resources :stories, :concerns => :paginatable, only: [ :index, :show ]
  resources :top_hits, :concerns => :paginatable, only: :index
  resources :almost_stories, :concerns => :paginatable, only: :index

  resources :search_stories

  root "stories_front_page#index"
end
