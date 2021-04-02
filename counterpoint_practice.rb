# example: cantus_firmus = [0, 1, 3, 2, 3, 4, 5, 4, 2, 1, 0]
# w/ half-steps accounted: [0, 2, 5, 4, 5, 7, 9, 7, 4, 2, 0]

# valid_intervals = [-12, -7, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 7, 8, 12]
# valid_notes = [-12, -10, -8, -7, -5, -3, -1, 0, 2, 4, 5, 7, 9, 11, 12, 14, 16]

#rules:

# mandatory
# - allowable intervals: 1 2 3 4 5 7 12, +8 (followed only by downward motion)
# - allowable notes: 0, 2, 4, 5, 7, 9, 11, 12 (etc.)
# - first and final notes must be 0
# - penultimate note must be -1 or 2
# - there must be a single highest note that is above the starting/ending note. It may not be the leading tone (VII or 11 (10 in some modes?)). Must occure on a strong beat
# - range of notes should be a 10th (17 or 16 chromatic pitches at most depending on mode) or less
# - no more than 4 leaps in a row
# - "No series of three notes may define a 7th or larger dissonance"
# - when using two leaps in the same direction, the second must be smaller than the first (a fair rule would be only once possible per cantus firmus)
# "If the final is approached from below, then the leading tone must be raised in a minor key (Dorian, Hypodorian, Aeolian, Hypoaeolian), but not in Phrygian or Hypophrygian mode. Thus, in the Dorian mode on D, a C♯ is necessary at the cadence"


# flexible
# - stepwise motion is preferable to leaps
# - avoid two consecutive leaps in the same direction
# - when a step follows a leap, it should move opposite the leap
# - prefer variety
# - active tones should resolve (IV => III, VII => I, VI => V, etc.)
# - range of notes should preferably be an octave (13 chromatic pitches) or less
# - avoid repetitions and sequences
# - no more than 3 leaps in a row
# - about 8-16 notes total
# - high note should be toward middle of line

class CantusFirmusScore
  attr_accessor :original_valid_movements, :notes, :length, :current_available_movements, :current_note_position

  def initialize
    @length = 8
    @notes = []
    @length.times do
      @notes << 0
    end
    @iterations = 1

    @current_note_position = 0
    @current_available_movements = []
    @mode = "ionian"
    @possible = true
  end

  def determine_original_valid_movements
    if @mode == "ionian"
      @original_valid_movements = {
        -12=>{:steps=>[2], :leaps=>[4, 5, 7, 12]}, 
        -10=>{:steps=>[-2, 2], :leaps=>[3, 5, 7, 12]}, 
        -8=>{:steps=>[-2, 1], :leaps=>[-4, 3, 5, 7, 8, 12]}, 
        -7=>{:steps=>[-1, 2], :leaps=>[-5, -3, 4, 7, 12]}, 
        -5=>{:steps=>[-2, 2], :leaps=>[-7, -5, -3, 4, 5, 7, 12]}, 
        -3=>{:steps=>[-2, 2], :leaps=>[-7, -5, -4, 3, 5, 7, 8, 12]}, 
        -1=>{:steps=>[1], :leaps=>[]}, 
        0=>{:steps=>[-1, 2], :leaps=>[-12, -7, -5, -3, 4, 5, 7, 12]}, 
        2=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 3, 5, 7, 12]}, 
        4=>{:steps=>[-2, 1], :leaps=>[-12, -7, -5, -4, 3, 5, 7, 8, 12]}, 
        5=>{:steps=>[-1, 2], :leaps=>[-12, -5, -3, 4, 7]}, 
        7=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 4, 5, 7]}, 
        9=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -4, 3, 5, 7]}, 
        11=>{:steps=>[1], :leaps=>[]}, 
        12=>{:steps=>[-1, 2], :leaps=>[-12, -7, -5, -3, 4]}, 
        14=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3]}, 
        16=>{:steps=>[-2], :leaps=>[-12, -7, -5, -4]}
      }
    end
  end

  def determine_current_available_movements
    @current_available_movements[@current_note_position] = @original_valid_movements[@notes[@current_note_position]].dup
  end

  def execute_movement
    # p @notes
    if rand(1..100) <= 33 && @current_available_movements[@current_note_position][:leaps][0]
      leap
    else
      if @current_available_movements[@current_note_position][:steps][0]
        step
      else
        leap
      end
    end

    @notes[@current_note_position+1] = @notes[@current_note_position] + @executed_movement
  end

  def step
    @executed_movement = @current_available_movements[@current_note_position][:steps].sample
    @current_available_movements[@current_note_position][:steps] = @current_available_movements[@current_note_position][:steps] - [@executed_movement]
  end

  def leap
    leap_selected  = false
    while leap_selected == false
      leap_offered = @current_available_movements[@current_note_position][:leaps].sample
      if leap_offered.abs() < rand(1..13) # this condition lowers the probability of larger leaps being chosen
        leap_selected = true
      end
    end
    @executed_movement = leap_offered
    @current_available_movements[@current_note_position][:leaps] = @current_available_movements[@current_note_position][:leaps] - [@executed_movement]
  end

  def available_movement_check
    if @current_available_movements[@current_note_position][:steps][0] || @current_available_movements[@current_note_position][:leaps][0]
      return true
    else
      return false
    end
  end

  def iterate
    while @current_note_position < ( @length - 1 )
      if available_movement_check == true
        execute_movement
        @current_note_position += 1
        determine_current_available_movements
        @current_available_movements = CantusFirmusFilter.filter(@current_available_movements, @current_note_position, @notes)
      else
        @current_note_position -= 1
        @iterations += 1
        if @current_note_position < 0
          p "no possible note combination"
          @possible = false
          break
        end
      end
    end
  end
  
  def build_cantus_firmus
    determine_original_valid_movements
    determine_current_available_movements
    while CantusFirmusValidator.valid?(@notes) == false && @possible == true
      iterate
      @current_note_position -= 1
    end

    if @possible == true
      p @notes
      p "#{@iterations} iterations"
      CantusFirmusValidatorWithPrintStatements.valid?(@notes)
    end
  end

  def build_a_lot(length, tmt)
    this_many_times = tmt
    this_many_times.times do
      @length = (length)
      @notes = []
      @length.times do
        @notes << 0
      end
      @iterations = 1

      @current_note_position = 0
      @current_available_movements = []

      build_cantus_firmus
    end
  end
end

class CantusFirmusFilter
  def self.filter(movements, position, notes)
    @movements = movements
    @position = position
    @notes = notes

    self.opposite_direction_step_filter
    self.penultimate_filter
    self.ultimate_filter
    self.step_repetition_filter
    self.consecutive_leap_filter
    self.palindrome_filter
    self.note_repetition_filter

    return @movements
  end

  def self.opposite_direction_step_filter
    #checks whether the previous movement was a large leap
    if (@notes[@position-1] - @notes[@position]).abs() >= 5
      previous_movement = @notes[@position] - @notes[@position - 1]
      @movements[@position][:steps] = @movements[@position][:steps].select { |move| move.negative? != previous_movement.negative?}
    end
  end

  def self.penultimate_filter
    if @position == (@notes.length - 3)
      @movements[@position][:steps] = @movements[@position][:steps].select { |move| (@notes[@position] + move) <= 2 && (@notes[@position] + move) >= -2}
      @movements[@position][:leaps] = []
      if @notes[@position].abs() >= 5
        @movements[@position][:steps] = @movements[@position][:steps].select { |move| @notes[@position].negative? != (@notes[@position] + move).negative? }
      end
    end
  end

  def self.ultimate_filter
    if @position == @notes.length - 2
      @movements[@position][:leaps] = []
      @movements[@position][:steps] = @movements[@position][:steps].select { |move| @notes[@position] + move == 0 }
    end
  end

  def self.step_repetition_filter
    if self.positive_step_repetition_check
      # p "positive step repetition filter"
      # p @position
      # p @notes
      # p @movements[@position]
      # p "becomes..."
      @movements[@position][:steps] = @movements[@position][:steps].select { |move| move.negative? == true}
      @movements[@position][:leaps] = @movements[@position][:leaps].select { |move| move.negative? == true}
      # p @movements[@position]
    elsif self.negative_step_repetition_check
      @movements[@position][:steps] = @movements[@position][:steps].select { |move| move.negative? == false}
      @movements[@position][:leaps] = @movements[@position][:leaps].select { |move| move.negative? == false}
    end
  end

  #not included in self.filter
  def self.positive_step_repetition_check
    #checks for four positive steps in a row
    @position >= 4 && 
    (@notes[@position - 4] + 1 == @notes[@position - 3] || @notes[@position - 4] + 2 == @notes[@position - 3]) && 
    (@notes[@position - 3] + 1 == @notes[@position - 2] || @notes[@position - 3] + 2 == @notes[@position - 2]) && 
    (@notes[@position - 2] + 1 == @notes[@position - 1] || @notes[@position - 2] + 2 == @notes[@position - 1]) && 
    (@notes[@position - 1] + 1 == @notes[@position] || @notes[@position - 1] + 2 == @notes[@position])
  end

  #not included in self.filter
  def self.negative_step_repetition_check 
    #checks for five negative steps in a row
    @position >= 5 && 
    (@notes[@position - 5] - 1 == @notes[@position - 4] || @notes[@position - 5] - 2 == @notes[@position - 4]) && 
    (@notes[@position - 4] - 1 == @notes[@position - 3] || @notes[@position - 4] - 2 == @notes[@position - 3]) && 
    (@notes[@position - 3] - 1 == @notes[@position - 2] || @notes[@position - 3] - 2 == @notes[@position - 2]) && 
    (@notes[@position - 2] - 1 == @notes[@position - 1] || @notes[@position - 2] - 2 == @notes[@position - 1]) && 
    (@notes[@position - 1] - 1 == @notes[@position] || @notes[@position - 1] - 2 == @notes[@position])
  end

  def self.consecutive_leap_filter
    if @position >= 1 && (@notes[@position] - @notes[@position - 1]).abs() >= 3

      @movements[@position][:leaps] = @movements[@position][:leaps].select { |move| move != -(@notes[@position] - @notes[@position - 1])} #filters out leaps exactly opposite to the previous

      if @position >= 2 && (@notes[@position - 1] - @notes[@position - 2]).abs() >= 3 #filters out three leaps in a row

        @movements[@position][:leaps] = []

      elsif (@notes[@position] - @notes[@position - 1]).abs() >= 5
        #filters out equal or larger leaps in the same direction as a previous leaps
        @movements[@position][:leaps] = @movements[@position][:leaps].select { |move| move.negative? != (@notes[@position] - @notes[@position - 1]).negative? || move.abs() < (@notes[@position] - @notes[@position - 1]).abs() }
      end
    end
  end

  def self.palindrome_filter
    if @position >= 3 && @notes[@position] == @notes[@position - 2]
      if (@notes[@position] - @notes[@position - 3]).abs() <= 2
        @movements[@position][:steps] = @movements[@position][:steps].select { |move| (@notes[@position] + move) != @notes[@position - 3] }
      else
        @movements[@position][:leaps] = @movements[@position][:leaps].select { |move| (@notes[@position] + move) != @notes[@position - 3] }
      end
    end
  end

  def self.note_repetition_filter
  end
    #three leaps may not occur in a row
    #large leap (5th or more) cannot be followed by a leap

end

class CantusFirmusValidator
  def self.valid?(notes)
    @notes = notes
    return self.penultimate_check && self.range_check && self.climax_check && leap_percentage_check && self.note_repetition_check && self.pair_repetition_check && self.triplet_repetition_check
  end

  def self.penultimate_check
    if @notes[-2] > -3 && @notes[-2] < 3 && @notes[-2] != 0
      return true
    else
      return false
    end
  end

  def self.climax_check
    highest_note = 2 #starting value assures climax is at least a third above starting pitch
    climax_presence = false

    i = 0
    while i < @notes.length
      if @notes[i] > highest_note
        highest_note = @notes[i]
        p
        if ((i + 1) / @notes.length.to_f) > 0.25 && ((i + 1) / @notes.length.to_f) < 0.75 #checks if climax is toward middle
          climax_presence = true
        else
          climax_presence = false
        end
      elsif @notes[i] == highest_note
        climax_presence = false
      end 
      i += 1
    end

    if highest_note == 11     #checks for leading tone
      climax_presence = false
    end

    return climax_presence
  end

  def self.range_check
    if (@notes.max - @notes.min) < 13
      return true
    else
      return false
    end
  end
  
  def self.leap_percentage_check
    leaps = 0
    i = 0
    while i < (@notes.length - 1)
      if ((@notes[i+1] - @notes[i]).abs()) >= 3
        leaps += 1
      end
      i += 1
    end

    if leaps.to_f / @notes.length.to_f <= 0.33
      return true
    else
      return false
    end
  end

  def self.note_repetition_check
    note_count = {}
    @notes.each do |note|
      if note_count[note]
        note_count[note] += 1
      else
        note_count[note] = 1
      end
    end

    acceptable_repetitions = true
    note_count.keys.each do |key|
      if (note_count[key].to_f / @notes.length.to_f) > 0.25
        acceptable_repetitions = false
      end
    end
    return acceptable_repetitions
  end

  def self.pair_repetition_check
    i = 0
    acceptable_repetitions = true
    while i < (@notes.length - 3)
      if [@notes[i], @notes[i+1]] == [@notes[i+2], @notes[i+3]]
        acceptable_repetitions = false
      end
      i += 1
    end
    return acceptable_repetitions
  end

  def self.triplet_repetition_check
    i = 0
    acceptable_repetitions = true
    while i < (@notes.length - 5)
      if [@notes[i], @notes[i+1], @notes[i+2]] == [@notes[i+3], @notes[i+4], @notes[i+5]]
        acceptable_repetitions = false
      end
      i += 1
    end
    return acceptable_repetitions
  end
end

class CantusFirmusValidatorWithPrintStatements
  def self.valid?(notes)
    @notes = notes
    return self.penultimate_check && self.climax_check && self.range_check && leap_percentage_check && self.note_repetition_check
  end

  def self.penultimate_check
    if @notes[-2] > -3 && @notes[-2] < 3 && @notes[-2] != 0
      p "good penultimate note"
      return true
    else
      p "bad penultimate note"
      return false
    end
  end

  def self.climax_check
    highest_note = 2 #starting value assures climax is at least a third above starting pitch
    climax_presence = false

    i = 0
    while i < @notes.length
      if @notes[i] > highest_note
        highest_note = @notes[i]
        p
        if ((i + 1) / @notes.length.to_f) > 0.25 && ((i + 1) / @notes.length.to_f) < 0.75 #checks if climax is toward middle
          climax_presence = true
        else
          climax_presence = false
        end
      elsif @notes[i] == highest_note
        climax_presence = false
      end 
      i += 1
    end

    if highest_note == 11     #checks for leading tone
      climax_presence = false
    end

    p "climax presence is #{climax_presence}"
    p "climax is #{highest_note}"
    return climax_presence
  end

  def self.range_check
    p "range is #{@notes.max - @notes.min} half-steps"
    if (@notes.max - @notes.min) < 13
      return true
    else
      return false
    end
  end
  
  def self.leap_percentage_check
    leaps = 0
    i = 0
    while i < (@notes.length - 1)
      if ((@notes[i+1] - @notes[i]).abs()) >= 3
        leaps += 1
      end
      i += 1
    end

    p "there are #{leaps} leaps"
    if leaps.to_f / @notes.length.to_f <= 0.33
      return true
    else
      return false
    end
  end

  def self.note_repetition_check
    note_count = {}
    @notes.each do |note|
      if note_count[note]
        note_count[note] += 1
      else
        note_count[note] = 1
      end
    end
    p "note count is #{note_count}"

    acceptable_repetitions = true
    note_count.keys.each do |key|
      if (note_count[key].to_f / @notes.length.to_f) > 0.25
        acceptable_repetitions = false
        p "unacceptable repetitions"
      end
    end
    return acceptable_repetitions
  end
end

cantus_firmus = CantusFirmusScore.new
cantus_firmus.build_cantus_firmus
cantus_firmus.build_a_lot(12, 100)

#March 29
#how do i keep track of undesirable features? to what extent do I allow them in generation?

#march 30
#instead of checking for all traits after generation, I need to check for some DURING generation in order to reduce load times. A few are listed in available_movement_check (line 127). I must refactor the execute/cascade/check to stop when the incomplete cantus firmus can already be shown to not work instead of building out the whole thing every time