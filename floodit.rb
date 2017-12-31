#Allowing use of installed ruby gems.
require "console_splash"
require "colorize"

# Displays the splash screen until user presses ENTER key.
def splash_screen()
  system "clear"
  splash = ConsoleSplash.new()
  splash.write_header("Welcome to Flood-It", "Omar Iltaf", "1.0")
  splash.write_center(-10, "<Press ENTER to continue.>")
  splash.write_horizontal_pattern("* ")
  splash.write_vertical_pattern("*")
  splash.splash
  puts
  gets
end

#Displays the main menu and takes in then returns user input.
def main_menu(best_score)
  system "clear"
  puts "Main menu:"
  puts "s = Start game"
  puts "c = Change size"
  puts "q = Quit"
  if (best_score == 0) then
    puts "No games played yet"
  else
    puts "Best game: #{best_score} turns"
  end  
  print "Please enter your choice: "
  input = gets.chomp
  return input
end

#Creates and returns a 2D array, of the appropriate size, to represent the game board.
#Elements of the 2D array are assigned randomly selected colours.
def get_board(width, height)
  board = Array.new(height) {Array.new(width)}
  colours = [:red, :blue, :green, :yellow, :cyan, :magenta]
  (0...board.length).each do |i|
    (0...board[i].length).each do |j|
      random = rand colours.length
      board[i][j] = colours[random]
    end
  end
  return board
end

#Displays the game board with the corresponding colours of blocks.
def display_board(board)
  system "clear"
  String.disable_colorization = false
  (0...board.length).each do |i|
    (0...board[i].length).each do |j|
      print "  ".colorize(:background => board[i][j])
    end
    puts
  end
end

#Updates the game board once the user has selected a colour in the play_game method.
#Blocks are updated individually.
#Methods are called recursively depending on the current position of the block (starts at top left corner).
#Blocks in the corners or edges of the game board can only take specific arguments.
#Only works if the current colour of the block and the selected colour are not the same.
def update_board(row, column, board, current_colour, new_colour)
  if (current_colour != new_colour) then
    if (board[row][column] == current_colour) then
      board[row][column] = new_colour
      if (row == 0 && column == 0) then
        update_board(row+1, column, board, current_colour, new_colour)
        update_board(row, column+1, board, current_colour, new_colour)
      elsif (row == 0 && column == board[row].length-1) then
        update_board(row+1, column, board, current_colour, new_colour)
        update_board(row, column-1, board, current_colour, new_colour)
      elsif (row == board.length-1 && column == 0) then
        update_board(row-1, column, board, current_colour, new_colour)
        update_board(row, column+1, board, current_colour, new_colour)
      elsif (row == board.length-1 && column == board[row].length-1) then
        update_board(row, column-1, board, current_colour, new_colour)
        update_board(row-1, column, board, current_colour, new_colour)
      elsif (row == 0) then
        update_board(row+1, column, board, current_colour, new_colour)
        update_board(row, column-1, board, current_colour, new_colour)
        update_board(row, column+1, board, current_colour, new_colour)
      elsif (row == board.length-1) then
        update_board(row, column-1, board, current_colour, new_colour)
        update_board(row-1, column, board, current_colour, new_colour)
        update_board(row, column+1, board, current_colour, new_colour)
      elsif (column == 0) then
        update_board(row+1, column, board, current_colour, new_colour)
        update_board(row-1, column, board, current_colour, new_colour)
        update_board(row, column+1, board, current_colour, new_colour)
      elsif (column == board[row].length-1) then
        update_board(row+1, column, board, current_colour, new_colour)
        update_board(row, column-1, board, current_colour, new_colour)
        update_board(row-1, column, board, current_colour, new_colour)
      else
        update_board(row+1, column, board, current_colour, new_colour)
        update_board(row-1, column, board, current_colour, new_colour)
        update_board(row, column+1, board, current_colour, new_colour)
        update_board(row, column-1, board, current_colour, new_colour)
      end
    end
  end
  return board    
end

#Checks if all blocks on the board are the same colour.
#If so it returns true, otherwise it returns false.
def check_board?(board)
  completed = true
  (0...board.length).each do |i|
    (0...board[i].length).each do |j|
      if (board[i][j] != board[0][0]) then
        completed = false
      end
    end
  end
  return completed
end

#Checks how many blocks on the board have the same colour as the block in the top left corner.
#Returns an integer percentage value.
def board_completion(board)
  total_blocks = board.length * board[0].length
  count = 0
  (0...board.length).each do |i|
    (0...board[i].length).each do |j|
      if (board[i][j] == board[0][0]) then
        count += 1
      end
    end
  end
  completion = ((count/total_blocks.to_f) * 100).to_i
  return completion
end

#Handles the running of the game itself.
#Allows user to select colour or quit.
#Board completion and number of turns are displayed here.
#Upon winning, a message is displayed and then returns to the main method.
def play_game(board, best_score)
  turns = 0
  completed = false
  loop do
    display_board board
    puts "Number of turns: #{turns}"
    completion = board_completion board
    puts "Current completion: #{completion}%"
    if (completed == true) then
      puts "You won after #{turns} turns"
      gets
      if (best_score == 0) then
        best_score = turns
      elsif (turns < best_score) then
        best_score = turns
      end
      return best_score
    end
    print "Choose a colour: "
    input = gets.chomp
    if (input == "q") then
      return best_score
    elsif (input == "r") then
      new_colour = :red
    elsif (input == "b") then
      new_colour = :blue
    elsif (input == "g") then
      new_colour = :green
    elsif (input == "y") then
      new_colour = :yellow
    elsif (input == "c") then
      new_colour = :cyan
    elsif (input == "m") then
      new_colour = :magenta
    else
      next
    end
    turns += 1
    board = update_board 0, 0, board, board[0][0], new_colour
    completed = check_board? board
  end
end

#Handles the overall running of the program.
#Program runs in a loop until user enters "q" in the main menu.
#Important values are stored here then passed into appropriate methods.
def main()
  columns = 14
  rows = 9
  best_score = 0
  splash_screen
  loop do
    response = main_menu best_score
    if (response == "q") then
      break
    elsif (response == "c") then
      print "Width (Currently #{columns})? "
      columns = gets.chomp.to_i
      print "Height (Currently #{rows})? "
      rows = gets.chomp.to_i
      best_score = 0
    elsif (response == "s") then
      board = get_board columns, rows
      best_score = play_game board, best_score
    end
  end
end

#Runs the program.
main