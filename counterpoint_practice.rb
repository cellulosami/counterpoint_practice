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
    @length = 12
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
    if @current_available_movements[@current_note_position][:steps][0] && @current_available_movements[@current_note_position][:leaps][0]
      if rand(1..100) > 25
        step
      else
        leap
      end
    elsif @current_available_movements[@current_note_position][:steps][0]
      step
    else
      leap
    end

    @notes[@current_note_position+1] = @notes[@current_note_position] + @executed_movement
  end

  def step
    @executed_movement = @current_available_movements[@current_note_position][:steps].sample
    @current_available_movements[@current_note_position][:steps] = @current_available_movements[@current_note_position][:steps] - [@executed_movement]
  end

  def leap
    @executed_movement = @current_available_movements[@current_note_position][:leaps].sample
    @current_available_movements[@current_note_position][:leaps] = @current_available_movements[@current_note_position][:leaps] - [@executed_movement]
  end

  def cascade_movement
    while @current_note_position < ( @length - 2 )
      determine_current_available_movements
      execute_movement
      @current_note_position += 1
      #p @notes
    end
  end

  def available_movement_check
    if @current_available_movements[@current_note_position][:leaps][0] || @current_available_movements[@current_note_position][:steps][0]
      return true
    else
      return false
    end
  end

  def iterate
    @current_note_position -= 1
    while available_movement_check == false
      @current_note_position -= 1
      if @current_note_position < 0
        p "no possible note combination"
        @possible = false
        break
      end
    end
    if @possible == true
      execute_movement
      @current_note_position += 1
      cascade_movement
      @iterations += 1
    end
  end

  def build_cantus_firmus
    determine_original_valid_movements
    cascade_movement
    while CantusFirmusValidator.valid?(@notes) == false && @possible == true
      iterate
    end
    if @possible == true
      p @notes
      p "#{@iterations} iterations"
      CantusFirmusValidatorWithPrintStatements.valid?(@notes)
    end
  end

  def build_a_lot
    1000.times do
      @length = 8
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



class CantusFirmusValidator
  def self.valid?(notes)
    @notes = notes
    return self.penultimate_check && self.range_check && self.climax_check && leap_percentage_check && self.note_repetition_check
  end

  def self.penultimate_check
    if @notes[-2] > -3 && @notes[-2] < 3 && @notes[-2] != 0
      return true
    else
      return false
    end
  end

  def self.climax_check
    highest_note = (@notes[0] + 2) #starting value assures climax is at least a third above starting pitch
    highest_note_index = 0
    climax_presence = false

    i = 0
    while i < @notes.length
      if @notes[i] > highest_note
        highest_note = @notes[i]
        p
        if (i / @notes.length.to_f) >= 0.25 && (i / @notes.length.to_f) <= 0.75 #checks if climax is toward middle
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

    if leaps.to_f / @notes.length.to_f < 0.33
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

    @acceptable_repetitions = true
    note_count.keys.each do |key|
      if (note_count[key].to_f / @notes.length.to_f) > 0.25
        @acceptable_repetitions = false
      end
    end
    return @acceptable_repetitions
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
    highest_note = (@notes[0] + 2) #starting value assures climax is at least a third above starting pitch
    highest_note_index = 0
    climax_presence = false

    i = 0
    while i < @notes.length
      if @notes[i] > highest_note
        highest_note = @notes[i]
        p
        if (i / @notes.length.to_f) >= 0.25 && (i / @notes.length.to_f) <= 0.75 #checks if climax is toward middle
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
    if leaps.to_f / @notes.length.to_f < 0.33
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

    @acceptable_repetitions = true
    note_count.keys.each do |key|
      if (note_count[key].to_f / @notes.length.to_f) > 0.25
        @acceptable_repetitions = false
        p "unacceptable repetitions"
      end
    end
    return @acceptable_repetitions
  end
end

cantus_firmus = CantusFirmusScore.new
cantus_firmus.build_cantus_firmus

#March 29
#need to add many more validations
#how do i keep track of undesirable features? to what extent do I allow them in generation?