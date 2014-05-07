require 'factory_girl'
require 'faker'
require 'formatador'

def create_from_factory(factory,count,klass = nil)
  klass = factory if klass.nil?
  count.times do |i|
    Formatador.redisplay_progressbar(i + 1, count, {:label => "Populating #{factory.to_s.pluralize}..."})
    attr = FactoryGirl.attributes_for(factory)
    object = klass.to_s.classify.constantize.new(attr)
    object.save if object.valid?
  end
end

namespace :mailr do

  desc "Populates with fake data"
  task :populate_fake => :environment do

    User.connection
    create_from_factory(:fake_user, 20, :user)

  end

end
  # def generates_real_results(bet)
  #   middle = rand(0..5)
  #   sign = rand(0..1)
  #   result1 = rand(middle-1..middle+1)
  #   result2 = rand(middle-1..middle+1)
  #   bet.result1 = result1
  #   bet.result2 = result2
  # end

    # create_from_factory(:moderator,5,:user)
    # create_from_factory(:place,10)

    # create_from_factory(:match_played,15,:match)
    # create_from_factory(:match_not_played,15,:match)
    # create_from_factory(:match_is_playing,5,:match)

    # uc = User.count
    # mc = Match.count
    # c = uc * mc
    # count = 1

    # Match.all.each do |m|
    #   # puts "Match #{m.result1} #{m.result2}"
    #   if m.has_results?
    #     middle1 = m.result1
    #     middle2 = m.result2
    #   else
    #     middle1 = rand(0..3)
    #     middle2 = rand(0..3)
    #   end
    #   place_id = rand(1..9)
    #   sign = rand(0..2)
    #   User.all.each do |u|
    #     Formatador.redisplay_progressbar(count, c, {:label => "Populating bets..."})
    #     bet = rand(0..5)
    #     if bet > 1
    #       result1 = rand(middle1-sign..middle1+sign)
    #       result1 = result1 < 0 ? 0 : result1
    #       result2 = rand(middle2-sign..middle2+sign)
    #       result2 = result2 < 0 ? 0 : result2
    #       # puts "#{result1} #{result2}"
    #       u.bets.create!(match: m, result1: result1, result2: result2)
    #     end
    #     count += 1
    #   end
    # end

    # Formatador.redisplay_progressbar(1, 1, {:label => "Propagating results..."})
    # Match.has_results.each { |m| m.touch }
