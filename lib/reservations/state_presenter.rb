module Reservations
  class StatePresenter
    def initialize(state)
      @state = state
    end

    def self.to_options
      [
        ['dostepny', :available],
        ['zarezerwowany', :reserved],
        ['wypozyczony', :holding],
        ['zarchiwizowany', :archived]
      ]
    end

    def to_s
      case @state
      when :availible
        'dostepny'
      when :reserved
        'zarezerwowany'
      when :archived
        'zarchiwizowany'
      when :holding
        'wypozyczony'
      else
        'nie wiem'
      end
    end
  end
end
