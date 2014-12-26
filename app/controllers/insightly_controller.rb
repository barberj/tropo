class InsightlyController < ApplicationController
  def new
  end

  def signup
    session['token'] = params['token']
    redirect_to new_insightly_path
  end

  def create
    puts 'hi'
    binding.pry
    puts 'hi'
  end
end
