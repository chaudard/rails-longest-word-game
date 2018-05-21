require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    # @letters = ('A'..'Z').to_a.sample(10)
    @letters = generate_grid(10)
  end

  def score
    attempt = params[:attempt]
    grid = params[:grid]
    grid = get_attempt_up_tab(grid)
    results = run_game(attempt, grid, 0, 5)
    @score_result = results[:message]
  end

  private

  def english_word?(attempt)
    root = 'https://wagon-dictionary.herokuapp.com/'
    url = "#{root}#{attempt.downcase}"
    user_serialized = URI(url).read
    user = JSON.parse(user_serialized)
    return user["found"]
  end

  def get_attempt_up_tab(attempt)
    return attempt.upcase.split('')
  end

  def every_letter_in_the_grid?(grid, attempt)
    attempt_up_tab = get_attempt_up_tab(attempt)
    in_grid = attempt_up_tab.all? do |letter|
      grid.include?(letter)
    end
    return in_grid
  end

  def get_frequency_letters(array)
    frequency_letters = Hash.new(0)
    array.each do |letter|
      frequency_letters[letter] += 1
    end
    return frequency_letters
  end

  def use_good_letters_number?(grid, attempt)
    attempt_up_tab = get_attempt_up_tab(attempt)
    grid_frequency_letters = get_frequency_letters(grid)
    attempt_frequency_letters = get_frequency_letters(attempt_up_tab)
    result = true
    attempt_frequency_letters.each do |letter, frequency|
      result = result && (frequency <= grid_frequency_letters[letter])
    end
    return result
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    alphabet = ('A'..'Z').to_a
    grid = []
    grid_size.times do
      grid << alphabet.sample
    end
    return grid
  end

  MESSAGES = {
    english: "the given word is not an english word",
    grid: "the given word is not in the grid",
    number: "the given word has the correct letters but not in sufficient number",
    well: "Well done."
  }

  def get_score(attempt, time)
    return attempt.size.fdiv(time)
  end

  def get_score_and_message(grid, attempt, time)
    score_null = 0
    return { score: score_null, message: MESSAGES[:english] } unless english_word?(attempt)
    return { score: score_null, message: MESSAGES[:grid] } unless every_letter_in_the_grid?(grid, attempt)
    return { score: score_null, message: MESSAGES[:grid] } unless use_good_letters_number?(grid, attempt)
    result = { score: score_null, message: MESSAGES[:well] }
    result[:score] = get_score(attempt, time)
    return result
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    result = {} # should return time, score, message
    time = end_time - start_time
    result[:time] = time
    score_and_message = get_score_and_message(grid, attempt, time)
    result[:score] = score_and_message[:score]
    result[:message] = score_and_message[:message]
    return result
  end

end
