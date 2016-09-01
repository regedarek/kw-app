module Reservations
  class StatePresenter
    def initialize(state)
      @state = state
    end

    def self.to_options
      [
        ['zarezerwowany', :reserved],
        ['wypozyczony', :holding],
        ['zarchiwizowany', :archived]
      ]
    end

    def to_s
      case @state
      when :reserved
        'zarezerwowany'
      when :archived
        'zarchiwizowany'
      when :holding
        'w posiadaniu'
      else
        'nie wiem'
      end
    end
  end
end
