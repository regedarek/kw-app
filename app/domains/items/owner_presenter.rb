module Items
  class OwnerPresenter
    def initialize(owner)
      @owner = owner
    end

    def self.to_options
      [
        ['Klub', 0],
        ['Narciarze', 1],
        ['Wspinacze', 2],
        ['Instruktorzy', 3]
      ]
    end

    def to_s
      case @owner.to_sym
      when :kw
        'Klub'
      when :sww
        'Wspinacze'
      when :snw
        'Narciarze'
      when :instructors
        'Instruktorzy'
      else
        'nie wiem'
      end
    end
  end
end
