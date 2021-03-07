# example: cantus_firmus = [0, 1, 3, 2, 3, 4, 5, 4, 2, 1, 0]
# w/ half-steps accounted: [0, 2, 5, 4, 5, 7, 9, 7, 4, 2, 0]

#constant variables
# valid_intervals = [-12, -7, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 7, 8, 12]
# valid_notes = [-12, -10, -8, -7, -5, -3, -1, 0, 2, 4, 5, 7, 9, 11, 12, 14, 16]

#set up valid movements
# valid_movements = {}
# valid_notes.each do |note|
#   valid_movements[note] = []
#   valid_intervals.each do |interval|
#     if valid_notes.include?(note + interval)
#       valid_movements[note] << interval
#     end
#   end
# end

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

class CantusFirmus

  attr_accessor :original_valid_movements, :notes, :length, :current_available_movements, :current_note_position

  def initialize
    @length = 7
    @notes = []
    @length.times do
      @notes << 0
    end

    @valid_intervals = [-2, -1, 1, 2]
    @valid_notes = [-12, -10, -8, -7, -5, -3, -1, 0, 2, 4, 5, 7, 9, 11, 12, 14, 16] 
    @original_valid_movements = {-12=>[2], -10=>[-2, 2], -8=>[-2, 1], -7=>[-1, 2], -5=>[-2, 2], -3=>[-2, 2], -1=>[1], 0=>[-1, 2], 2=>[-2, 2], 4=>[-2, 1], 5=>[-1, 2], 7=>[-2, 2], 9=>[-2, 2], 11=>[1], 12=>[-1, 2], 14=>[-2, 2], 16=>[-2]}
    @current_note_position = 0
    @current_available_movements = []
  end

  def determine_all_available_movements
    note_position = 0
    (@length - 2).times do
      @current_available_movements[note_position] = @original_valid_movements[@notes[note_position-1]]
      note_position += 1
    end
  end

  def determine_current_available_movements
    @current_available_movements[@current_note_position] = @original_valid_movements[@notes[@current_note_position]]
  end

  def execute_movement
    p @current_available_movements
    p @current_note_position
    executed_movement = @current_available_movements[@current_note_position].sample
    @current_available_movements[@current_note_position] = @current_available_movements[@current_note_position] - [executed_movement]
    p executed_movement
    @notes[@current_note_position+1] = @notes[@current_note_position] + executed_movement
    p @notes
  end
  
  def cascade_movement
    while @current_note_position < ( @length - 2 )
      determine_current_available_movements
      execute_movement
      @current_note_position += 1
      p @notes
    end
  end

  def available_movement_check
    if @current_available_movements[@current_note_position][0]
      p "movements available"
      return true
    else
      p "no movements available"
      return false
    end
  end

  def penultimate_check
    if @notes[-2] == 2 || @notes[-2] == -1
      p "good penultimate note"
      return true
    else
      p "bad penultimate note"
      return false
    end
  end

  def penultimate_fix
    while penultimate_check == false
      @current_note_position -= 1
      while available_movement_check == false
        @current_note_position -= 1
      end
      execute_movement
      @current_note_position += 1
      cascade_movement
    end
  end

  def build_cantus_firmus
    cascade_movement
    penultimate_fix
  end

  def build_endlessly # (for testing)
    while true
      @current_note_position = 0
      @notes = []
      @length.times do
        @notes << 0
      end
      build_cantus_firmus
    end
  end

end

cantus_firmus = CantusFirmus.new
cantus_firmus.build_endlessly