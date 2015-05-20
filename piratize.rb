# Piratize.rb
# A module to piratize ruby objects including strings, arrays, hashes and ships
# Uses talk_like_a_pirate gem to translate strings to pirish

require 'talk_like_a_pirate'

class PartyRepelledError < StandardError ; end
class NoTreasureError < StandardError ; end
class WhatBeThisError < StandardError ; end

module Piratize
  
  def self.process ruby_object

    # if ruby object is a string, translate to pirish and take out substrings
    if (ruby_object.is_a?(String))

      # translate string to pirish using TalkLikeAPirate gem
      ruby_object = TalkLikeAPirate.translate(ruby_object)
  
      # take selected substrings out of string (coins, gold etc.)
      ruby_object = steal_from_string(ruby_object)

      return ruby_object

    # process arrays
    elsif (ruby_object.is_a?(Array))

      # loop through array and piratize each element 
      ruby_object.each_index do |i|
        ruby_object[i] = Piratize.process(ruby_object[i])
      end

      return ruby_object
  
    # process hashes
    elsif (ruby_object.is_a?(Hash))

      # loop through Hash and piratize values
      ruby_object.each do |key, value| 
        ruby_object[key] = Piratize.process(value)
      end
  
      return ruby_object
         
    # process all other objects, including ships
    else

      # if object responds to board!, then call board!
      if (ruby_object.respond_to?('board!'))

        # create random sized boarding party and board
        motleycrue = BoardingParty.new(rand(10))
        return ruby_object.board!(motleycrue)

      end
    end
  end

private #########################################
  
  # delete selected substrings from string
  def self.steal_from_string me_string
     me_string.gsub!(/gold|coins|coin|treasure/, "")
     return me_string
  end

end

module Ship

  def initialize size, treasure
    @size = size
    @treasure = treasure
    @sunk = false
  end

  def sink!
    @sunk = true
  end

  def sunk?
    @sunk
  end

  def display
    puts "Size is " + @size.to_s
    puts "Treasure is " + @treasure.to_s
    if (@sunk)
      puts "Ship is sunk."
    else
      puts "Ship is afloat."
    end
    
  end

  def board! boarding_party

    raise "boarding party must be an instance of BoardingParty" unless boarding_party.is_a?(BoardingParty)

    # if PartyRepelledError raised, replace instance with new instance of ShipWreck
    begin
      if boarding_party.size <= @size
        raise PartyRepelledError.new
      end
    rescue PartyRepelledError
      puts "rescuing from party repelled error..."
      return ShipWreck.new(self)
    end

    # if NoTreasureError raised, print out message
    begin
      if @treasure == 0
        raise NoTreasureError.new
      end
    rescue NoTreasureError
      puts("Ya, no treasure were found me 'earty!")
    end

    @treasure = 0
    return self

  end

end

class ShipWreck

  def initialize ship
    @original_ship = ship
    ship.sink!
  end

end

class BigShip

  include Ship

end

class BoardingParty

  def initialize size
    @size = size
    @treasure = 0
  end

  def size
    @size
  end

end

##################################################################################
# Driver test code
##################################################################################
test_String = "Hello world"
puts "Testing translation of strings..."
puts TalkLikeAPirate.translate(test_String)

# include is used instead of == for testing because TalkLikeAPirate 
#    sometimes adds extra pirate flavor to the end of strings
puts TalkLikeAPirate.translate(test_String).include? "Ahoy world"
puts Piratize.process(test_String).include? "Ahoy world"

puts TalkLikeAPirate.translate("Nice to meet you, gold !").include? "Nice t' meet ye, gold !"
puts TalkLikeAPirate.translate("Nice to meet you, bill !").include? "Nice t' meet ye, bill !"

puts "Using piratize module..."
puts Piratize.process("Nice to meet you, gold !").include? "Nice t' meet ye,  !"
puts Piratize.process("Nice to meet you, coins !").include? "Nice t' meet ye,  !"
puts Piratize.process("treasure you always, coin !").include? " ye always,  !"

puts "Testing ship sinking..."
bigship1 = BigShip.new(6, 0)
bigship1.sink!()
puts bigship1.sunk? == true

puts "Testing boarding of ship..."
motleycrue = BoardingParty.new(7)
bigship1.board!(motleycrue)

puts "Testing piratizing of arrays..."
array1 = ["treasure you always, coin !", "Nice to meet gold"]
puts Piratize.process(array1).to_s == '[" ye always,  !", "Nice t\' meet "]'

puts "Testing piratizing of hashes..."
hash1 = { "first_comment" => "I do not see any coins !", "second_comment" => "treasure is what we are after!" }
puts Piratize.process(hash1).to_s == '{"first_comment"=>"I d\' not see any  !", "second_comment"=>" be what our jolly crew be after!"}'

bigship2 = BigShip.new(rand(10), rand(10))
bigship3 = BigShip.new(rand(10), 0)

puts "Testing ship with no treasure"
Piratize.process(bigship3)

puts "Testing array of ships"
ship_array = [bigship2, bigship3]
puts "ship array before piratize is: " + ship_array.to_s
Piratize.process(ship_array)
puts "ship array AFTER piratize is: " + ship_array.to_s
