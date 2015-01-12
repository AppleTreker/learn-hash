class Template < Sinatra::Base
  BSBar::Item.new(:home, '/') # (See bar_builder.rb)
  get '/' do
    erb :home
  end

  BSBar::Item.new(:game, '/game') # (See bar_builder.rb)
  get '/game' do
    erb :game
  end

  BSBar::Item.new(:concept, '/concept') # (See bar_builder.rb)
  get '/concept' do
    erb :concept
  end
end